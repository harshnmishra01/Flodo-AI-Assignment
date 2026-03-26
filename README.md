# Flodo Task Management App (Full-Stack)

A functional, visually polished Task Management application built with **Flutter** and **Django REST Framework**. This project demonstrates a robust mobile-first architecture, complex relational data logic ("Blocked By" tasks), and smooth asynchronous UI/UX.

---

## Technical Track & Stretch Goal
* **Chosen Track:** **Track A: The Full-Stack Builder** (Flutter + Django + PostgreSQL/SQLite).
* **Stretch Goal:** **Debounced Autocomplete Search**.
    * Implemented a 300ms debounce to optimize API efficiency and reduce server load.
    * Developed a custom `HighlightedText` widget to visually emphasize matching search substrings within task titles.

---

## Features & Requirements Checklist

### Core Requirements (Must-Have)
- [x] **Task CRUD:** Full Create, Read, Update, and Delete functionality.
- [x] **Relational Logic:** "Blocked By" dependency. Tasks are visually greyed out (0.5 opacity) and interaction is locked if their prerequisite task is not marked as "Done".
- [x] **Draft Persistence:** Any unsaved text in the creation screen is persisted via `shared_preferences` in real-time, allowing recovery after app restarts or accidental closes.
- [x] **Search & Filter:** Search by title (Debounced) and filter the list by Status (To-Do, In Progress, Done) using high-fidelity UI chips.
- [x] **Simulated Latency:** All Create/Update actions include a mandatory **2-second delay** with a non-freezing loading overlay to provide clear feedback and prevent double-submissions.

### Technical Highlights
- [x] **API Documentation:** Integrated `drf-spectacular` to provide a full Swagger/OpenAPI 3.0 UI for backend testing.
- [x] **State Management:** Utilized `Provider` for reactive UI updates and centralized business logic.
- [x] **Mobile UX:** Implemented `Dismissible` (Swipe-to-delete) with confirmation dialogs and Material 3 design principles.


## Setup Instructions


* Clone the repo

```bash
git clone https://github.com/harshnmishra01/Flodo-AI-Assignment.git -b main
```

### BE Setup

```bash
cd backend

python -m venv venv

#### On Windows:
venv\Scripts\activate
#### On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt


python manage.py makemigrations
python manage.py migrate

# Create a superuser to be able to check the admin panel
python manage.py createsuperuser

# Seed the database with sample tasks
python manage.py seed_data

# Run the development server
python manage.py runserver
```

#### Swagger UI
The Swagger UI is available at `http://127.0.0.1:8000/api/docs/`

#### Admin Panel
The admin panel is available at `http://127.0.0.1:8000/admin/`

### FE Setup

#### 1. Prerequisites
* Flutter SDK (Stable channel)
* Android Studio / Xcode (for mobile)
* Chrome (for web debugging)

#### 2. Installation
```bash

cd frontend

# Install Flutter dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Run on Mobile Emulator
flutter run
```

## AI Usage Report

In the development of this project, AI (specifically Google's Gemini) was utilized as a pair-programming assistant to accelerate debugging, refine UI/UX patterns, and optimize state management. 

### How AI was Leveraged:
* **Debugging Flutter Widget Trees:** Used AI to diagnose and resolve a strict `Dismissible` widget exception ("A dismissed Dismissible widget is still part of the tree"). This led to refactoring the `TaskProvider` to use synchronous, optimistic UI updates rather than waiting for API responses before updating the local state.
* **UI/UX Refinement:** * Transitioned the date picker from a basic `ListTile` to an `InputDecorator` to maintain strict visual consistency with the app's standard `TextFormField` borders.
    * Implemented standard, human-readable date formatting using the `intl` package.
* **Advanced State Logic:** Designed a seamless "Undo" feature for task deletion. AI assisted in structuring the logic to use `ScaffoldMessenger` and `SnackBarClosedReason.action`, ensuring API delete calls are only executed if the user ignores the Undo prompt, thereby saving unnecessary server load.

### What was Built Manually:
* The core Django REST Framework architecture, data models, and API endpoints.
* The baseline Flutter UI layouts, routing, and form validation logic.
* The relational "Blocked By" dependency logic and the implementation of the debounced search system.

### Prompts That Stood Out
* **Combining Visuals with Code:** Prompting with *"Date filter UI uniformity. Keep it in same borders as the rest of the buttons"* alongside both a screenshot of the mismatched UI and the `TaskFormScreen.dart` file. This provided the exact visual context needed for the AI to recommend `InputDecorator` instead of guessing layout fixes.
* **Direct Error Pasting:** Providing the raw, unedited exception stack trace (`A dismissed Dismissible widget is still part of the tree`) alongside the relevant `deleteTask` API function. This allowed the AI to immediately identify the async timing conflict between Flutter's widget tree and the backend logic.
* **Action-Oriented UX Requests:** Prompting *"If we accidentally deleted then while the snackbar is active, can we give a undo button"* shifted the AI from fixing a bug to implementing a standard, mobile-first UX pattern.

### Bugs/Issues Caused by AI Misunderstandings
* **The "Silent Fail" on Optimistic Deletion:** To fix the `Dismissible` crash, the AI initially suggested instantly removing the task from the local UI list *before* calling the backend. However, it didn't account for what would happen if the API call failed (e.g., network error). The frontend would show the task as deleted, but it would still exist in the database, requiring an extra iteration to add a state "rollback" mechanism.
* **Index Shifting in the Undo Logic:** When generating the Undo feature, the AI suggested re-inserting the deleted task at its original index (`_tasks.insert(index, task)`). The AI failed to account for a scenario where a user rapidly deletes *multiple* tasks in a row. If the list size shrinks faster than the SnackBars close, trying to insert a task at a now non-existent index could cause an out-of-bounds crash. This required adding a `safeIndex` check.