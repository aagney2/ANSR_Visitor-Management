const { onRequest } = require("firebase-functions/v2/https");
const axios = require("axios");
const FormData = require("form-data");

const KELSA_BASE = "https://kelsa.io";
const KELSA_EMAIL = "kelsaio1234@gmail.com";
const KELSA_TOKEN = "ifaDz2xxkC-yxGxoXujF";

const ALLOWED_ORIGINS = [
  "https://ansr-visitor-checkin.web.app",
  "https://ansr-visitor-checkin.firebaseapp.com",
  "http://localhost:5000",
];

function setCors(req, res) {
  const origin = req.headers.origin || "";
  if (ALLOWED_ORIGINS.includes(origin)) {
    res.set("Access-Control-Allow-Origin", origin);
  }
  res.set("Access-Control-Allow-Methods", "GET, POST, PUT, OPTIONS");
  res.set("Access-Control-Allow-Headers", "Content-Type, Accept");
  res.set("Access-Control-Max-Age", "3600");
}

const kelsaHeaders = {
  "Content-Type": "application/json",
  "Accept": "application/json",
  "X-User-Email": KELSA_EMAIL,
  "X-User-Token": KELSA_TOKEN,
};

// General API proxy
exports.api = onRequest(
  { region: "us-central1", invoker: "public" },
  async (req, res) => {
    setCors(req, res);
    if (req.method === "OPTIONS") { res.status(204).send(""); return; }

    let targetPath = req.path;
    if (targetPath.startsWith("/proxy")) {
      targetPath = targetPath.substring("/proxy".length);
    }

    try {
      const axiosConfig = {
        method: req.method.toLowerCase(),
        url: `${KELSA_BASE}${targetPath}`,
        headers: kelsaHeaders,
        params: req.query,
        timeout: 30000,
      };
      if (req.method === "POST" || req.method === "PUT") {
        axiosConfig.data = req.body;
      }
      const response = await axios(axiosConfig);
      res.status(response.status).json(response.data);
    } catch (error) {
      if (error.response) {
        res.status(error.response.status).json(error.response.data);
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }
);

// Full upload proxy: presigned → S3 → register (all server-side)
exports.upload = onRequest(
  { region: "us-central1", invoker: "public", memory: "256MiB" },
  async (req, res) => {
    setCors(req, res);
    if (req.method === "OPTIONS") { res.status(204).send(""); return; }
    if (req.method !== "POST") { res.status(405).json({ error: "POST only" }); return; }

    try {
      const { fileBase64, filename, contentType, pipelineId } = req.body;
      if (!fileBase64 || !filename || !contentType || !pipelineId) {
        res.status(400).json({ error: "Missing required fields" });
        return;
      }

      const fileBuffer = Buffer.from(fileBase64, "base64");

      // Step 1: Get presigned POST from Kelsa
      const presignedRes = await axios.get(
        `${KELSA_BASE}/api/v1/uploads/presigned_post`,
        {
          headers: kelsaHeaders,
          params: { pipeline_id: pipelineId, content_type: contentType, filename },
          timeout: 30000,
        }
      );

      const { url: s3Url, fields } = presignedRes.data;

      // Step 2: Upload to S3
      const form = new FormData();
      for (const [key, value] of Object.entries(fields)) {
        form.append(key, value);
      }
      form.append("file", fileBuffer, { filename, contentType });

      const s3Res = await axios.post(s3Url, form, {
        headers: form.getHeaders(),
        timeout: 60000,
        maxContentLength: 20 * 1024 * 1024,
        maxBodyLength: 20 * 1024 * 1024,
      });

      // Parse Location from S3 XML response
      const locationMatch = (s3Res.data || "").match(/<Location>(.*?)<\/Location>/);
      if (!locationMatch) {
        res.status(500).json({ error: "Could not parse S3 location" });
        return;
      }
      const fileUrl = decodeURIComponent(locationMatch[1]);

      // Step 3: Register upload in Kelsa
      const registerRes = await axios.post(
        `${KELSA_BASE}/api/v1/uploads`,
        {
          upload: {
            url: fileUrl,
            upload_type: "attachment",
            metadata: { size: fileBuffer.length },
            pipeline_id: parseInt(pipelineId),
          },
        },
        { headers: kelsaHeaders, timeout: 30000 }
      );

      const uploadId = registerRes.data.upload.id;

      res.status(200).json({
        url: fileUrl,
        size: fileBuffer.length,
        upload_id: uploadId,
      });
    } catch (error) {
      console.error("Upload error:", error.message);
      if (error.response) {
        res.status(error.response.status).json({
          error: error.response.data || error.message,
        });
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }
);
