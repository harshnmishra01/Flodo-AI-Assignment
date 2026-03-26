# Full-Stack Task Management App

Flodo is a polished, feature-rich task management application built from the ground up with a **Flutter** frontend and a **Django REST Framework** backend. It showcases a robust, mobile-first architecture, complex relational data modeling, and a smooth, asynchronous user experience.

<p align="center">
  <em><b>Suggestion:</b> This is the most crucial missing piece. Add a GIF or a few high-quality screenshots of your application in action. Visuals are essential for showcasing a UI-focused project and will dramatically increase engagement.</em>
</p>

---

## ✨ Key Features

*   **Full CRUD Operations:** Create, read, update, and delete tasks with a seamless and intuitive UI.
*   **Complex Task Dependencies:** Implement "Blocked By" relationships. A task is visually de-emphasized and non-interactive until its prerequisite tasks are completed.
*   **Debounced Autocomplete Search:** Efficiently search for tasks by title. A 300ms debounce is implemented to optimize API calls, and a custom widget highlights matching text.
*   **Stateful Filtering:** Filter the task list by status (To-Do, In Progress, Done) using interactive Material 3 filter chips.
*   **Draft Persistence:** Unsaved new task descriptions are automatically saved to local storage, preventing data loss on accidental app closure.
*   **Optimistic UI with Undo:** Swipe to delete with an "Undo" option. The delete request is only sent to the server if the user doesn't cancel, saving server resources and improving UX.
*   **Simulated Latency Handling:** All create/update actions feature a 2-second delay with a non-blocking loading indicator to simulate real-world network conditions and prevent duplicate submissions.

---

## 🛠️ Tech Stack

| Area         | Technologies & Libraries                                                                                                                              |
| :----------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Frontend** | Flutter, Dart, `provider` (State Management), `http`, `shared_preferences`, `intl`, `google_fonts`                                                  |
| **Backend**  | Python, Django, Django REST Framework, SQLite3 (development) / PostgreSQL (production-ready)                                                        |
| **API & Docs** | `drf-spectacular` (for OpenAPI 3.0 / Swagger UI)                                                                                                      |
| **Testing**  | Flutter Widget Tests, Django Unit Tests                                                                                                             |

## 🚀 Getting Started

### Prerequisites

*   **Backend:** Python 3.8+
*   **Frontend:** Flutter SDK (Stable channel), an IDE (like VS Code or Android Studio), and a target device (Emulator, Physical Device, or Chrome for web).

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/harshnmishra01/Flodo-AI-Assignment.git
cd Flodo-AI-Assignment/backend

# Create and activate a virtual environment
python -m venv venv
# On Windows: venv\Scripts\activate
# On macOS/Linux: source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run database migrations
python manage.py makemigrations
python manage.py migrate

# Create a superuser for the admin panel
python manage.py createsuperuser

# (Optional) Seed the database with sample data
python manage.py seed_data

# Run the development server
python manage.py runserver
```
The backend will be available at `http://127.0.0.1:8000`.

### Frontend Setup

```bash
# Navigate to the frontend directory
cd ../frontend

# Install dependencies
flutter pub get

# Run the application on Chrome
# (Ensure the backend server is running first)
flutter run -d chrome

# On emulator
flutter run
```

## 📄 API Documentation

The API is fully documented using OpenAPI 3.0. Once the backend server is running, you can access the interactive Swagger UI at:

**http://127.0.0.1:8000/api/docs/**

The Django admin panel is also available at `http://127.0.0.1:8000/admin/`.

## 🧠 Development Process & AI Collaboration

This project was developed using a pair-programming methodology with AI (Google's Gemini) to accelerate debugging, explore alternative UI patterns, and refine state management logic.

*   **What was built manually:** The core application architecture, Django data models, API endpoints, baseline Flutter UI, and the primary business logic (including "Blocked By" dependencies and debounced search) were designed and implemented by the developer.
*   **How AI assisted:**
    *   **Debugging:** Resolved complex widget tree exceptions (e.g., `A dismissed Dismissible widget is still part of the tree`) by identifying async timing conflicts between the UI and backend calls.
    *   **UI Refinement:** Suggested using `InputDecorator` to achieve visual consistency for the date picker, based on screenshots and code context.
    *   **UX Enhancements:** Helped structure the "Undo" feature for deletions, moving from a simple delete to a more user-friendly, recoverable action.