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


- For the setup of the projects distict READMEs are provided in the respective directories.