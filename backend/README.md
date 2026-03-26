# Task Management System - Backend

A robust RESTful API built with **Django** and **Django REST Framework (DRF)** to manage tasks with status filtering and search capabilities.

## Getting Started

### 1. Prerequisites
* Python 3.8+
* pip (Python package manager)

### 2. Installation & Setup
```bash

# Navigate to the backend directory
cd backend

# Create a virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt


python manage.py makemigrations
python manage.py migrate

# Create a superuser
python manage.py createsuperuser

# Run the development server
python manage.py runserver
```

### 3. Seeding the Database
```bash
python manage.py seed_data
```

### 3. Swagger UI
The Swagger UI is available at `http://127.0.0.1:8000/api/docs/`