# ANSR Visitor Management — User Manual

**Version 1.0**
**March 2026**

---

## Table of Contents

1. [Overview](#1-overview)
2. [Getting Started](#2-getting-started)
   - 2.1 [Installation](#21-installation)
   - 2.2 [Initial Setup — Printer Configuration](#22-initial-setup--printer-configuration)
3. [Visitor Check-In Flow](#3-visitor-check-in-flow)
   - 3.1 [Step 1: Welcome Screen](#31-step-1-welcome-screen)
   - 3.2 [Step 2: Phone Number Entry](#32-step-2-phone-number-entry)
   - 3.3 [Step 3: Returning Visitor Confirmation](#33-step-3-returning-visitor-confirmation)
   - 3.4 [Step 4: Purpose of Visit](#34-step-4-purpose-of-visit)
   - 3.5 [Step 5: Whom to Meet](#35-step-5-whom-to-meet)
   - 3.6 [Step 6: Visitor Details](#36-step-6-visitor-details)
   - 3.7 [Step 7: Review & Submit](#37-step-7-review--submit)
   - 3.8 [Step 8: Check-In Successful & Badge Printing](#38-step-8-check-in-successful--badge-printing)
4. [Visitor Check-Out Flow](#4-visitor-check-out-flow)
5. [Printer Settings](#5-printer-settings)
   - 5.1 [Auto-Discovery](#51-auto-discovery)
   - 5.2 [Manual IP Entry](#52-manual-ip-entry)
   - 5.3 [Removing a Saved Printer](#53-removing-a-saved-printer)
6. [Badge Details](#6-badge-details)
7. [Troubleshooting](#7-troubleshooting)
8. [FAQ](#8-faq)

---

## 1. Overview

ANSR Visitor Management is a mobile application designed for front-desk and reception use. It provides a streamlined, self-service check-in experience for visitors arriving at ANSR offices.

**Key Features:**
- Self-service visitor check-in with photo and signature capture
- Automatic badge printing via Brother QL-820NWB label printer
- QR code-based visitor check-out
- Returning visitor recognition — auto-fills previously entered details
- Real-time visitor data synced to **Kelsa** (the backend management platform)
- Employee directory lookup for "Whom to Meet" selection

**Supported Devices:**
- iPhone (iOS 13.0 and later)
- iPad (iPadOS 13.0 and later)
- Android (Android 5.0 and later)

**Supported Printer:**
- Brother QL-820NWB (connected via Wi-Fi)

---

## 2. Getting Started

### 2.1 Installation

- **iOS:** Download "ANSR Visitor Management" from the Apple App Store.
- **Android:** Download "ANSR Visitor Management" from the Google Play Store.

On first launch, the app will display the ANSR welcome screen. Before processing visitors, it is recommended to configure your badge printer (see Section 2.2).

### 2.2 Initial Setup — Printer Configuration

1. From the **Welcome Screen**, tap the **Settings icon** (gear icon, top-left corner).
2. The app will automatically scan the local network for Brother QL-820NWB printers.
3. Available printers will appear in a list showing their model name and IP address.
4. Tap a printer to select and save it.
5. A confirmation message will appear: *"Printer saved: [Model] @ [IP Address]"*.

> **Note:** Ensure the Brother QL-820NWB printer is powered on and connected to the same Wi-Fi network as the device running the app.

---

## 3. Visitor Check-In Flow

### 3.1 Step 1: Welcome Screen

When the app launches, the visitor sees the **Welcome Screen** with:
- The ANSR logo
- "Welcome to ANSR" heading
- "Visitor Management System" subtitle
- A large **"Check In"** button

**Action:** Tap **Check In** to begin the check-in process.

The welcome screen also has two icons in the top corners:
- **Settings** (top-left) — Opens printer settings
- **Check Out** (top-right) — Opens the visitor check-out scanner

---

### 3.2 Step 2: Phone Number Entry

The visitor is asked to enter their phone number.

**What the visitor sees:**
- "Enter your phone number" heading
- A phone input field with country code (+91)
- A numeric keypad
- A consent checkbox: *"I consent to have my information stored by ANSR for visitor management purposes."*
- A **Continue** button

**Actions:**
1. Enter the 10-digit phone number using the on-screen keypad.
2. Check the consent checkbox (required).
3. Tap **Continue**.

**What happens next:**
- The system searches for existing visitor records linked to this phone number.
- If a **returning visitor** is found → proceeds to the Returning Visitor screen.
- If a **new visitor** → proceeds directly to Purpose of Visit.

---

### 3.3 Step 3: Returning Visitor Confirmation

*This screen only appears for visitors who have checked in before.*

**What the visitor sees:**
- "Welcome Back" greeting with the visitor's name
- Previously saved photo (if available)
- Pre-filled details: Name, Email, Phone, Company, Location, Laptop Serial Number

**Actions:**
- **Confirm & Continue** — Accepts existing details and proceeds to Purpose of Visit.
- **Edit My Details** — Opens the Visitor Details form to update information.

---

### 3.4 Step 4: Purpose of Visit

The visitor selects the reason for their visit.

**What the visitor sees:**
- A grid of purpose tiles, which may include:
  - Visitor
  - Interview
  - New Joiner
  - Employee
  - Client
  - Contractor
  - Vendor
  - Meeting
  - Others

**Actions:**
1. Tap a purpose tile to select it (highlighted with a border).
2. Tap **Continue**.

---

### 3.5 Step 5: Whom to Meet

The visitor selects the employee they are visiting.

**What the visitor sees:**
- A search bar to filter employees by name
- A scrollable list of employees showing:
  - Name
  - Designation
- The selected employee is highlighted

**Actions:**
1. (Optional) Type in the search bar to filter the list.
2. Tap an employee to select them.
3. Tap **Continue**.

---

### 3.6 Step 6: Visitor Details

The visitor provides their personal details, photo, and signature.

**What the visitor sees:**
- **Form fields:**
  - Full Name *(required)*
  - Email
  - Company Name
  - Location
  - Laptop Serial Number
  - Badge Number
- **Photo capture section:** Tap to open the camera and take a photo.
- **Signature pad:** Draw signature on screen, with a Clear button and checkmark to confirm.

**Actions:**
1. Fill in the required fields (Full Name is mandatory).
2. Tap the photo area to capture a photo using the device camera.
3. Draw a signature on the signature pad and tap the checkmark to confirm.
4. Tap **Continue**.

> **Note:** Both photo and signature are required to proceed. For returning visitors, the previous photo will be shown but can be retaken by tapping it.

---

### 3.7 Step 7: Review & Submit

The visitor reviews all entered information before final submission.

**What the visitor sees:**
- **Personal Information** card: Name, Email, Phone, Company, Location
- **Visit Information** card: Purpose, Whom to Meet, Visitor Type (New/Returning)
- Photo preview
- Signature preview

**Actions:**
- **Submit Check-In** — Submits all data to Kelsa and creates the visitor record.
- **Back** — Returns to the previous screen to make edits.

A loading overlay appears during submission showing the progress.

---

### 3.8 Step 8: Check-In Successful & Badge Printing

After successful submission, the visitor sees a confirmation screen.

**What the visitor sees:**
- A green success screen with a checkmark
- "Check-In Successful!" message
- "Welcome, [Visitor Name]" greeting
- Visit details: Date & Time, Meeting with [Employee Name]
- Badge print status:
  - *"Printing badge..."* — Print in progress
  - *"Badge printed successfully!"* — Print complete
  - *"Print failed. Please check printer connection."* — Print error with **Retry** option

**Actions:**
- **Done** — Returns to the Welcome Screen.
- **New Check-In** — Starts a fresh check-in for the next visitor.
- **Retry** (if print failed) — Attempts to print the badge again.

> **Note:** Badge printing happens automatically if a printer is configured. The badge is printed on the Brother QL-820NWB using a 62mm continuous label roll.

---

## 4. Visitor Check-Out Flow

When a visitor is ready to leave, their badge QR code can be scanned to record the check-out time.

**How to access:** From the Welcome Screen, tap the **Check Out icon** (top-right corner).

**Steps:**
1. The device camera activates with a scanner overlay.
2. Hold the visitor's printed badge up to the camera.
3. The app reads the QR code on the badge.
4. A processing indicator appears while the check-out is recorded.
5. On success, a confirmation screen shows:
   - "Check-Out Successful!"
   - "Goodbye, [Visitor Name]"
   - Check-out date and time
6. Tap **Done** to return to the Welcome Screen.

**What is recorded:**
- The check-out date and time is saved to the visitor's record in Kelsa.
- The visitor's checkout status is updated to "Yes" in the system.

> **Note:** Only badges printed by this app can be scanned for check-out. The QR code contains a secure visitor identifier linked to the Kelsa record.

---

## 5. Printer Settings

Access printer settings by tapping the **Settings icon** (gear, top-left) on the Welcome Screen.

### 5.1 Auto-Discovery

- The app automatically scans the local Wi-Fi network for Brother printers when the settings screen opens.
- Discovered printers appear in a list with their model name, IP address, and connection type (Wi-Fi/Bluetooth/USB).
- Tap a printer to select and save it.
- Tap **Scan Again** to re-scan if the printer was powered on after opening settings.

### 5.2 Manual IP Entry

If auto-discovery doesn't find the printer:
1. Scroll down and tap **"Enter Printer IP Address Manually"**.
2. Enter the printer's IP address in the dialog.
3. Tap **Save**.

> **Tip:** You can find the printer's IP address by printing a configuration label from the printer itself (hold the Wi-Fi button for 5 seconds).

### 5.3 Removing a Saved Printer

- The currently saved printer is shown at the top of the settings screen in a green card.
- Tap the **delete icon** (trash icon) next to the saved printer to remove it.

---

## 6. Badge Details

When a visitor checks in and a printer is configured, a badge is automatically printed containing:

| Field | Description |
|-------|-------------|
| **Visitor Photo** | Captured during check-in (printed with halftone dithering for thermal print quality) |
| **Visitor Name** | Full name as entered |
| **Date & Time** | Check-in date and time |
| **Whom to Meet** | Name of the employee being visited |
| **Purpose** | Reason for the visit |
| **QR Code** | Unique code for check-out scanning |
| **ANSR Logo** | Company branding |

**Badge Dimensions:** 62mm wide continuous label (landscape orientation)
**Printer Model:** Brother QL-820NWB

---

## 7. Troubleshooting

### Badge not printing

| Issue | Solution |
|-------|----------|
| "Print failed" error | Check that the printer is powered on and connected to the same Wi-Fi network. Tap **Retry**. |
| Printer not found in auto-scan | Ensure the printer is on the same network. Try **Scan Again** or use **Manual IP Entry**. |
| "Wrong Roll Type" error | Ensure the printer has a **62mm red/black continuous roll** (QL RB roll) loaded. |
| Blank badge | Check that the label roll is not empty or jammed. |

### App issues

| Issue | Solution |
|-------|----------|
| Camera not opening | Ensure camera permission is granted in device Settings → ANSR Visitor Management → Camera. |
| QR scan not working for check-out | Ensure the badge QR code is clearly visible and not damaged. Hold the badge steady about 6-8 inches from the camera. |
| Employee list not loading | Check your internet connection. The employee directory is loaded from Kelsa. Tap **Retry** if an error appears. |
| App shows "Something went wrong" | Check internet connectivity. The app requires a stable connection to sync with Kelsa. |

### Network requirements

- The device must have an **active internet connection** to sync visitor data with Kelsa.
- The device and printer must be on the **same local Wi-Fi network** for printing.
- The following network access is required:
  - `https://kelsa.io` — Backend API
  - Local network — Printer discovery and communication

---

## 8. FAQ

**Q: Can multiple devices use the app at the same time?**
A: Yes. Multiple devices can run the app simultaneously, all syncing to the same Kelsa visitor management pipeline. Each device should have its own printer configured.

**Q: What happens if the printer is offline during check-in?**
A: The check-in is still recorded in Kelsa successfully. Only the badge print will fail, and you can retry printing from the success screen, or the visitor can proceed without a badge.

**Q: Can a visitor check in without a photo or signature?**
A: No. Both photo and signature are required fields for all visitors.

**Q: How does the app recognize returning visitors?**
A: When a phone number is entered, the app searches existing Kelsa records. If a match is found, the visitor's previously saved details are pre-filled, saving time.

**Q: Where is visitor data stored?**
A: All visitor data is stored securely in **Kelsa** (kelsa.io), which is GDPR-compliant and security-audited. The app itself does not store visitor data locally — it only saves printer configuration on the device.

**Q: Can I use a different printer model?**
A: The app is currently optimized for the **Brother QL-820NWB**. Other Brother QL-series printers on the same network may be detected but are not officially supported.

**Q: How do I update the app?**
A: Updates are delivered through the Apple App Store (iOS) and Google Play Store (Android). Enable automatic updates on your device, or check the store periodically for new versions.

**Q: What if a visitor loses their badge before check-out?**
A: A reception staff member can manually update the check-out time in the Kelsa dashboard at kelsa.io.

---

*For additional support, contact your system administrator or reach out to the ANSR IT team.*

*Powered by Kelsa — kelsa.io*
