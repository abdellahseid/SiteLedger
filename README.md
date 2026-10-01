# SiteLedger — Construction Delivery Intelligence Platform

> **Production-minded, offline-first construction materials delivery verification and intelligence application designed for Ethiopian contractors, project managers, storekeepers, and procurement teams.**

[![Flutter](https://img.shields.io/badge/Flutter-3.44.8-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart)](https://dart.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-3178C6?logo=typescript)](https://www.typescriptlang.org)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.4-336791?logo=postgresql)](https://www.postgresql.org)
[![Drift](https://img.shields.io/badge/Drift_SQLite-Offline_First-yellow)](https://drift.simonbinder.eu)
[![Gemini](https://img.shields.io/badge/Google_Gemini-1.5_Flash-8E75B2?logo=google)](https://deepmind.google/technologies/gemini)
[![Tests](https://img.shields.io/badge/Tests-100%25_Passing-emerald)](https://github.com)

---

## 1. Executive Summary & Value Proposition

In major infrastructure and commercial construction across Ethiopia (Addis Ababa, Bole Lemi, Adama, Dire Dawa), material delivery verification is traditionally plagued by paper waybills, unrecorded site theft, uncalibrated truck scale discrepancies, and delayed dispute resolution between contractors and suppliers.

**SiteLedger** eliminates these friction points with an **offline-first mobile workflow** coupled with an enterprise Node.js/TypeScript backend, PostgreSQL persistence, and Google Gemini AI assistance.

### Key Capabilities

1. **Gate & Yard Material Tallying:**
   - Storekeepers record waybill numbers, truck plates, driver credentials, and exact quantities:
     - **Ordered** (from Purchase Order)
     - **Delivered** (from physical truck tare/scale ticket)
     - **Accepted** (sound condition, stored in yard)
     - **Damaged** (e.g., burst cement bags, corroded rebar)
     - **Rejected** (returned with truck)
2. **Instant Discrepancy Detection & Financial Assessment:**
   - Detects `SHORTAGE`, `EXCESS`, and `DAMAGE` automatically upon receipt submission.
   - Computes exact financial impact in **Ethiopian Birr (ETB)** using contractual PO line unit prices.
   - Categorizes severity (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`).
3. **Offline-First Resilience with Drift SQLite:**
   - Site storekeepers working in remote substations or basement excavations with zero cellular connectivity can create Goods Received Notes (GRN) locally.
   - All pending operations persist in an ACID SQLite Outbox (`sync_outbox`) with idempotency keys.
   - Automatic or manual background sync resumes immediately when connectivity is restored.
4. **Gemini AI Construction Intelligence:**
   - **Executive Summaries:** Plain-language site intake progress, on-spec fulfillment rates, and supply-chain velocity.
   - **Discrepancy Root-Cause Analysis:** Generates contractual liability insights, supplier claims language, and mitigation recommendations.
   - **Natural Language Report Queries:** Ask questions like *"Which supplier caused the highest financial damages in Bole Lemi?"* and receive structured data insights.
   - **Zero Secret Exposure:** The mobile client never holds the Gemini API key; all AI inference is proxied through the secure backend with deterministic fallback engines for offline reliability.

---

## 2. System Architecture

```mermaid
graph TD
    subgraph Mobile Client [Flutter 3.44 Mobile App]
        UI[Material 3 UI / High Contrast Outdoor Surfaces]
        RP[Riverpod State Providers]
        GR[GoRouter Navigation]
        SM[SyncManager & Outbox Worker]
        LDB[(Drift SQLite Local Database)]
    end

    subgraph Backend Services [Node.js + TypeScript REST API]
        RT[Express 4 Router + Auth Middleware]
        SW[Swagger OpenAPI 3.0 Documentation]
        AS[Audit Trail Service]
        DS[Discrepancy Evaluation Engine]
        GS[Gemini AI Service + Fallback Engine]
        FS[Multer Storage / Public Photo CDN]
    end

    subgraph Data & Cloud [Infrastructure]
        PG[(PostgreSQL 18 Database)]
        GEM[Google Gemini 1.5 Flash API]
    end

    UI --> RP
    RP --> SM
    SM --> LDB
    SM -- "HTTPS / Idempotency-Key" --> RT
    RT --> DS
    RT --> AS
    RT --> GS
    RT --> FS
    RT --> PG
    GS --> GEM
```

---

## 3. Technology Stack

| Layer | Technologies | Key Libraries / Frameworks |
|---|---|---|
| **Mobile Client** | Flutter 3.44.8, Dart 3.12 | `flutter_riverpod`, `go_router`, `drift`, `sqlite3_flutter_libs`, `dio`, `intl`, `qr_flutter`, `mobile_scanner`, `image_picker` |
| **Backend REST API** | Node.js, TypeScript 5.8 | `express`, `pg` (node-postgres), `cors`, `multer`, `dotenv`, `uuid`, `swagger-ui-express`, `yamljs` |
| **Database** | PostgreSQL 18.4 | 13 relational tables with foreign keys, checks, indexes, UUIDs |
| **Local Storage** | SQLite (via Drift) | Reactive DAOs, sync outbox, cached orders, receipts, discrepancies |
| **Artificial Intelligence** | Google Gemini API | `@google/generative-ai` (1.5 Flash), temperature-tuned prompts, deterministic offline fallbacks |
| **Testing** | Vitest & Flutter Test | 11 backend API tests (100%), 7 Flutter domain & widget tests (100%) |

---

## 4. Database Schema & Data Model

PostgreSQL entities with multi-tenant isolation by `organization_id`:

```mermaid
erDiagram
    ORGANIZATIONS ||--o{ PROJECTS : owns
    ORGANIZATIONS ||--o{ USERS : employs
    USERS ||--o{ MEMBERSHIPS : has
    PROJECTS ||--o{ MEMBERSHIPS : assigns
    PROJECTS ||--o{ PURCHASE_ORDERS : manages
    SUPPLIERS ||--o{ PURCHASE_ORDERS : supplies
    MATERIALS ||--o{ ORDER_LINES : specifies
    PURCHASE_ORDERS ||--o{ ORDER_LINES : contains
    PURCHASE_ORDERS ||--o{ RECEIPTS : receives
    RECEIPTS ||--o{ RECEIPT_LINES : details
    RECEIPTS ||--o{ EVIDENCE : attaches
    RECEIPTS ||--o{ DISCREPANCIES : triggers
    DISCREPANCIES ||--o{ AUDIT_LOGS : records
```

### Relational Entities:
1. `organizations`: Enterprise contractors (e.g., Abyssinia Infrastructures PLC).
2. `users`: System users with hashed passwords, roles, and contacts.
3. `projects`: Construction projects (e.g., Bole Lemi Industrial Park Phase II).
4. `memberships`: Role-based project memberships (`PROJECT_MANAGER`, `STOREKEEPER`, `PROCUREMENT_OFFICER`, `SUPPLIER_REPRESENTATIVE`).
5. `suppliers`: Material vendors (Muger Cement, Habesha Steel, National Cement, Derba MIDROC).
6. `materials`: Categorized material master catalog (`CEMENT`, `STEEL`, `AGGREGATES`, `FINISHES`).
7. `purchase_orders`: Commercial contracts with PO numbers, ETB totals, approvals, and status.
8. `order_lines`: Line items specifying unit prices, ordered quantities, and received tallies.
9. `receipts`: Delivery verification records (GRN) with waybill, truck plate, driver name, and timestamps.
10. `receipt_lines`: Individual line tallies (`delivered`, `accepted`, `damaged`, `rejected`).
11. `evidence`: Photo attachments, delivery slips, scale receipts, and damage proof.
12. `discrepancies`: Auto-generated deviation records with severity and ETB financial impact.
13. `audit_logs`: Immutable security and business audit trail with previous/new state diffs.
14. `sync_idempotency`: Deduplication table preventing double-receipt submissions.

---

## 5. Pre-Seeded Ethiopian Construction Demo Data

The platform comes pre-seeded with realistic Ethiopian construction assets and 5 demo personas:

### Demo Personas (One-Tap Switchable in App)
* **Almaz Kebede** (`almaz.storekeeper@abyssinia-infra.et`): Lead Storekeeper — Bole Lemi Site.
* **Dawit Tadesse** (`dawit.pm@abyssinia-infra.et`): Senior Project Director & Approver.
* **Hiwot Mengistu** (`hiwot.procurement@abyssinia-infra.et`): Procurement & Commercial Contracts Manager.
* **Yonas Bekele** (`yonas.supplier@muger-cement.et`): Muger Cement Factory Logistics Dispatcher.
* **Bethlehem Alemu** (`bethlehem.admin@abyssinia-infra.et`): Head of Infrastructure Operations.

### Active Ethiopian Projects
1. **Bole Lemi Industrial Park - Phase II** (`BLIP-02`) — Budget: ETB 450,000,000
2. **Meskel Square Transit Interchange** (`MSTI-01`) — Budget: ETB 820,000,000
3. **Addis-Adama Logistics Terminal** (`AALT-04`) — Budget: ETB 280,000,000

---

## 6. End-to-End Workflow Verification

The core construction workflow executes seamlessly:

```
[1. Procurement Creates PO] ──> [2. PM Approves PO] ──> [3. Physical Truck Arrives]
                                                                  │
[6. Reports & AI Analytics] <── [5. Discrepancy Resolution] <── [4. Storekeeper GRN Tally]
                                (Shortage/Damage Claims)        (Accepted, Damaged, Photos)
```

1. **Create PO:** Procurement creates `PO-2026-BLIP-001` for 2,000 Bags of Muger Cement PPC 42.5R at ETB 1,350/bag.
2. **Approve PO:** Project Manager Dawit Tadesse reviews and digitally signs off the order. Status updates to `APPROVED`.
3. **Field Delivery & QR Scan:** Truck `ET-3-84920-AA` arrives at gate. Storekeeper scans the PO QR code or enters PO number.
4. **Verification & Tally:**
   - Ordered: 2,000 Bags
   - Delivered on truck: 1,000 Bags
   - Accepted: 920 Bags
   - Damaged: 30 Bags (torn wet packaging)
   - Rejected: 50 Bags (short shipment vs waybill)
   - Photo evidence uploaded directly.
5. **Auto-Discrepancy Detection:** System flags 2 discrepancies:
   - `SHORTAGE`: 50 Bags variance (-ETB 67,500.00)
   - `DAMAGE`: 30 Bags damaged (-ETB 40,500.00)
6. **Gemini AI Root-Cause Analysis:** Backend analyzes the discrepancy and recommends withholding ETB 108,000 from the supplier's pending invoice.
7. **Resolution:** PM records resolution: *"Supplier agreed to debit invoice ETB 108,000 and deliver replacement batch."*
8. **Audit Trail:** Immutable audit logs store the initial submission, discrepancy status changes, and final sign-off.

---

## 7. Setup & Installation Guide

### Prerequisites
* **Node.js** >= 18.x
* **PostgreSQL** 16+ or 18.x
* **Flutter SDK** >= 3.24.x (Tested on Flutter 3.44.8, Dart 3.12)
* **Android SDK** (for mobile builds)

---

### Step 1: Backend Setup & Migrations

```bash
cd backend

# Install dependencies
npm install

# Configure environment variables
# Copy .env.example or create .env:
```

Create `backend/.env`:
```env
PORT=4000
NODE_ENV=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/siteledger
JWT_SECRET=siteledger-super-secret-key-production-ready-2026
GEMINI_API_KEY=your_gemini_api_key_optional_here
UPLOAD_DIR=./uploads
BASE_URL=http://localhost:4000
```

Run database migration and seed:
```bash
# Run PostgreSQL schema migration (creates all 13 tables)
npm run migrate

# Seed Ethiopian demo data (organizations, projects, POs, materials)
npm run seed

# Start development server
npm run dev
```

The backend server starts on `http://localhost:4000`.
- **Health Check:** `http://localhost:4000/health`
- **Swagger Documentation:** `http://localhost:4000/api/docs`

---

### Step 2: Mobile Application (Flutter)

```bash
cd ../app

# Fetch Flutter dependencies
flutter pub get

# (Optional) Rebuild Drift SQLite database classes if modified
dart run build_runner build --delete-conflicting-outputs

# Run Flutter test suite
flutter test

# Run app on Android Emulator / Physical Device
flutter run

# Or run on Chrome Web
flutter run -d chrome
```

---

### Step 3: Build Android Release / Debug APK

To produce a standalone Android application package:

```bash
cd app
flutter build apk --debug
```

The compiled APK is output to:
`app/build/app/outputs/flutter-apk/app-debug.apk`

---

## 8. Automated Test Suite

Both backend and mobile layers include automated test suites.

### Backend Vitest Tests (11/11 Passing)
```bash
cd backend
npm test
```
* `GET /health` service ping.
* Multi-tenant data isolation & project listing.
* Purchase order creation, line calculation, and status progression.
* Material receiving tally (ordered, delivered, accepted, damaged, rejected).
* Discrepancy engine shortage & damage auto-calculation.
* Gemini AI summary generation with deterministic fallback validation.
* CSV report generation and data integrity.

### Flutter Unit & Widget Tests (7/7 Passing)
```bash
cd app
flutter test
```
* Ethiopian Birr currency formatters (`ETB 1,350.00`, `ETB 2.7M`).
* Quantity and unit calculations.
* `PurchaseOrderModel` deserialization and line progress fulfillment.
* `ReceiptModel` shortage/damage tracking.
* `DiscrepancyModel` severity and open status logic.
* `StatusBadge` dynamic color tokens and outdoor accessibility styling.
* `MetricCard` user interaction and responsiveness.

---

## 9. Security & Offline Resilience

* **Zero Client Secrets:** The Flutter mobile application communicates only with the backend. No third-party API keys (including Gemini) are stored or accessed by the mobile client.
* **PostgreSQL ACID Transactions:** All multi-line delivery intake submissions are wrapped in database transactions to guarantee data consistency.
* **Idempotency Guard:** Every offline outbox submission transmits a client-generated UUID `Idempotency-Key` stored in `sync_idempotency` to prevent duplicate submissions during network retries.
* **Immutable Audit Trail:** All financial adjustments, order approvals, and discrepancy resolutions log the timestamp, user ID, IP address, and JSON diff into `audit_logs`.
* **Outdoor UI Contrast:** High contrast navy (`#0F172A`), electric blue (`#2563EB`), emerald (`#059669`), and amber (`#D97706`) typography and cards calibrated for outdoor construction site legibility under bright sunlight.

---

## 10. License & Credits

Built for construction teams across Ethiopia and international infrastructure partners.  
Developed with Google DeepMind Antigravity Pair-Programming.
