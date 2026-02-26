# Cafe Niloufer E-Valet (Mobile App)

A **Flutter mobile app** for valet parking at Cafe Niloufer. Valet staff (drivers) use it to park and retrieve cars; supervisors (operators) use it to manage sessions, view reports, and see who is working with live stats.

**Drivers (valets) can:**
- **Log in and clock in/out** – go online, offline, or on break from the home screen
- **Park car** – tap Park car → scan QR or enter tag number (from valet card) → collect car from customer → go to basement → take car photo → submit → **Car parked successfully** → back to home
- **Get retrieval request** – when assigned by operator, a **bottom sheet** with car details appears (valid **45 seconds**); tap **Collect keys** → get car from basement → bring to main gate
- **Confirm arrival** – at main gate tap **Confirm arrival** → customer gets **WhatsApp** message (e.g. your car has arrived at main gate)
- **Handover** – when customer comes, hand over keys and tap **Handover** → session completed, vehicle handovered
- **Repark** – if customer doesn’t come within **120 seconds** at main gate, take car back to basement, take photo, tap **Repark**
- **Push notification** – when a retrieval is assigned to you, you get a notification even when the app is closed

**Supervisors (operators) can see:**
- **Total cars parked** and **total cars retrieved** (handovered) for the outlet
- **How many people are working today** – total valets, available valets, on duty, on break
- **Login and clock-in time** for each valet (when they started their shift)
- **Per-valet stats** – for each valet: how many cars they parked (picked up), how many they retrieved (handed over), last activity, and on-break duration
- **Car logs** – total parked, in transit, handovered, in lot; plus detailed logs per car/session
- **Retrieval requests by card number** – when customer says "bring my car" in WhatsApp, request appears with card number; operator **assigns a valet** to that card
- **Daily dashboard** – how many on duty, averages, how many cards (sessions) per day, and other KPIs
- **Sound alert** when a new retrieval request comes in (tab view in dashboard)
- **Valet gets push notification** when a retrieval is assigned to them (even when app is closed)

---

## What This App Does

| Who uses it | What they do |
|-------------|----------------|
| **Driver** (valet) | Full park → retrieve → handover flow (see **Driver flow** below). |
| **Operator** (supervisor) | Full flow: dashboard (KPIs, retrieval requests by card), assign valet to card, daily stats, sound alert; valet gets push when assigned (see **Operator flow** below). |

After login, the app sends you to **Driver Home** or **Operator Dashboard** based on your role.

---

## Driver flow (complete)

The driver logs in and lands on the **home screen**. From there:

### 1. Park car

- Driver taps **Park car** on the home screen.
- Next screen: **QR scanner** or **manual tag number** (tag is provided to valet staff).
- Valet **scans QR** (or enters tag) → **collects car from customer** → goes to **basement**.
- Takes **car photo** and submits it.
- Taps **Car parked successfully** → car is marked as parked; driver returns to **home screen**.

### 2. Retrieval request

- When a **retrieval request** is assigned to this valet, a **bottom sheet** appears on the home screen with **car details**.
- Bottom sheet is valid for **45 seconds**; driver must accept in that time.
- Driver accepts by tapping **Collect keys** → collects the car from basement → brings it to the **main gate**.

### 3. Confirm arrival and handover

- At the main gate, driver taps **Confirm arrival** → customer receives a **WhatsApp message** (e.g. "Your car has arrived at main gate").
- When the **customer comes**, valet hands over the keys and taps **Handover** → session is completed and vehicle is **successfully handovered**.

### 4. Repark (customer didn't come)

- If the car is at the main gate but the **customer doesn't come within 120 seconds**, the valet takes the car back to the basement.
- Valet takes a **car photo** again and taps **Repark** → car is **reparked** and the flow can repeat when the customer requests retrieval again.

---

## Operator flow (complete)

### Customer card and WhatsApp

- For each car there are **two physical cards**:
  - A **customer WhatsApp card** with a WhatsApp icon, QR code, and card/tag number (this stays with the customer).
  - A **valet card** with the same QR code and card/tag number (this stays with the valet/parking team).
- When the valet **takes the car from the customer**, they give the customer the **WhatsApp card** and keep the **valet card**.
- The **valet scans the QR on the valet card** when entering/parking the car; the **customer scans the QR on their card in WhatsApp** to get a message (for example: your card number and that your car is successfully parked).
- The **card number** on both cards is the same and identifies that parking session; it is also encoded in the QR that the valet scans in the app when parking or retrieving.

### How retrieval is requested


- When the customer wants their car, they go to the **same WhatsApp account** and type something like **"bring my car"** and send it.
- A **retrieval request** then appears in the **operator dashboard**, showing that customer’s **card number**. The operator **assigns a valet** to that card; that valet is responsible to bring the car for that card number.
- If the customer **never scanned the QR in WhatsApp**, they still have the **physical card** with the **card number**. The valet app also uses the same **card number** (e.g. when the valet scans the QR or enters the tag), so the valet knows which car to bring. Once the operator assigns that card to a valet, the flow in the valet app is as in [Driver flow (complete)](#driver-flow-complete) (bottom sheet, Collect keys, etc.).

### Dashboard (operator app)

- The dashboard is a **tab view** with KPIs and retrieval requests.
- When a new retrieval request comes in (e.g. customer sent "bring my car" in WhatsApp), a **sound plays** so the operator knows to look at the dashboard and assign a valet.
- **Daily stats** in the dashboard include: how many valets are **on duty**, **average** (e.g. per valet or per day), how many **cards** (sessions) came in that day, and other KPIs – everything needed to run the valet operation in one place.

### Valet notification when assigned

- When the operator **assigns a retrieval request to a valet**, that valet receives a **push notification** on their phone so they know they got the retrieval request, **even when the valet app is closed**.

---

## Tech Stack

- **Flutter** (Dart) – UI and app logic  
- **BLoC** – State management  
- **Dio** – HTTP API calls  
- **Hive** – Local storage (e.g. tokens, offline data)  
- **Firebase** – Push notifications (FCM)  
- **WebSocket** – Real-time updates from the server  
- **.env** – API URLs, keys, and config (see `.env`)

---

## Project Structure (Simple)

```
lib/
├── api/          → All API calls (auth, driver, operator)
├── bloc/         → State management (login, driver, operator, websocket, etc.)
├── models/       → Data models (requests/responses)
├── services/     → OAuth, notifications, background sync, permissions, version check
├── ui/           → Screens and widgets
│   ├── common/   → Shared widgets, colors, text
│   ├── oauth/    → Login, forgot password, splash
│   ├── driver/   → Driver home, QR, camera, confirm handover, retrieval
│   ├── operator/ → Operator dashboard, drivers, car logs
│   ├── permissions/
│   └── version/
└── utils/        → Helpers
```

- **Driver flow:** Splash → Login (if needed) → Version check → Permissions → **Driver Home** → see [Driver flow (complete)](#driver-flow-complete) for park, retrieval, confirm arrival, handover, and repark.
- **Operator flow:** Same until role check → **Operator Dashboard** → see [Operator flow (complete)](#operator-flow-complete) for customer card/WhatsApp, retrieval by card, dashboard sound, valet push notification.

---

## How to Run

### 1. Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (project uses SDK `^3.6.1`)
- Android Studio / Xcode for device or emulator

### 2. Environment

- Copy or create a `.env` file at the project root (see `.env` for `APP_NAME`, `OAUTH_BASE_URL`, `API_BASE_URL`, `WEBSOCKET_BASE_URL`, `OUTLET_ID`, etc.).
- Do not commit real API keys or secrets.

### 3. Install and run

```bash
flutter pub get
flutter run
```

Use `flutter run -d <device_id>` to pick a device. For release build: `flutter build apk` or `flutter build ios`.

---

## Main Features (Summary)

- **Auth:** Login, logout, forgot password, OAuth token refresh, session end handling (e.g. login on another device).
- **Driver:** Clock in/out, break, accept session, scan QR, take park/repark photos, confirm arrival, handover, customer missing, retrieval requests, offline-friendly flow with background sync.
- **Operator:** Customer card with QR (WhatsApp message to customer when parked); retrieval when customer sends "bring my car" in WhatsApp (request shows card number); dashboard tab view with sound when new retrieval comes in; assign valet to card; daily stats (on duty, averages, cards per day); valet list and car logs; push notification to valet when retrieval is assigned (even when app is closed).
- **App-wide:** Version check (optional mandatory update), permissions screen (camera, location, etc.), connectivity banner when offline, push notifications, WebSocket reconnect on resume.

---

## Configuration (.env)

Important variables (see `.env` for full list):

- `APP_NAME` – App title (e.g. Cafe Niloufer E-Valet)
- `OAUTH_BASE_URL` – Auth API base URL  
- `API_BASE_URL` – E-Valet API base URL  
- `WEBSOCKET_BASE_URL` – WebSocket URL for real-time events  
- `OUTLET_ID` – Outlet identifier  
- `IMAGE_COMPRESSION_QUALITY` / `IMAGE_COMPRESSION_MAX_KB` – Photo upload size  
- `CONFIRM_ARRIVAL_DISABLE_SECONDS` / `CUSTOMER_MISSING_DISABLE_SECONDS` – Button cooldowns  

UAT vs prod can be switched by changing which `*_BASE_URL` and `*_API_KEY` are set in `.env`.

---

## Version

App version is in `pubspec.yaml` (e.g. `1.0.3`). The app checks for updates on launch and can show a mandatory update dialog if the server reports a higher build.

---

*README for **niloufer-valet-mobile** – simple overview to understand and run the project.*
