# Recipe Wallet

Recipe Wallet is a personal finance and budgeting platform featuring automated, AI-powered receipt scanning. By integrating Optical Character Recognition (OCR) with Large Language Models (LLMs like Gemma 3), Recipe Wallet extracts receipt line items, classifies expenses, updates budgets, and tracks detailed item-level spending histories automatically.

---

## 📱 Application Screenshots

| Main Dashboard Screen | Detailed Receipt Extraction |
|:---:|:---:|
| ![Main Dashboard Screen](./docs/MainScreen.png) | ![Detailed Receipt Extraction](./docs/DetailedReceipt.png) |

---

## 📂 Project Repository Structure

* [backend/](./backend) - **Spring Boot 3.x** API backend & background OCR workers.
* [frontend/](./frontend) - **Flutter** client supporting mobile (iOS, Android) and web applications.
* [docs/](./docs) - Structured specification and design documents:
  * 📑 [Business Specification](./docs/business_specification.md) - Features, use cases, and functional requirements.
  * ⚙️ [Backend Architecture Guide](./docs/backend_architecture.md) - System design, schema design, asynchronous queuing, and endpoint documentation.
  * 📱 [Frontend Architecture Guide](./docs/frontend_guide.md) - Flutter client states, themes, localization, and environments.

---

## 🛠️ Quick Start & Developer Workflow

We provide a developer wrapper script (`manage.sh`) and a matching `Makefile` at the root directory to handle standard developer tasks.

### 1. Setup Environment
Verify your local dependencies (Docker, Java, Flutter) and create your `.env` configuration file:
```bash
make setup
# OR
./manage.sh setup
```
Open the generated `.env` file at the root of the project and populate your private API credentials:
* `MISTRAL_API_KEY` & `OPENROUTER_API_KEY` (AI services)
* `EXCHANGERATE_API_KEY` (Exchange rates)
* `FIREBASE_STORAGE_BUCKET` & `FIREBASE_CREDENTIALS` (Database file storage & OIDC authentication)

### 2. Start Services
Boot the PostgreSQL database and Langfuse tracing panel inside background Docker containers:
```bash
make db-up
# OR
./manage.sh db-up
```

### 3. Run Backend
Start the local Spring Boot backend service:
```bash
make run-backend
# OR
./manage.sh backend
```
The API is exposed at `http://localhost:8080` (database migrations run automatically).

### 4. Run Frontend
Launch the Flutter development client:
```bash
make run-frontend
# OR
./manage.sh frontend
```
For targeting a specific device:
```bash
./manage.sh frontend chrome
```

---

## 🐳 Clean and Shutdown

Stop the running Docker compose database services:
```bash
make db-down
```

Clean temporary files and Maven builds:
```bash
make clean
```
