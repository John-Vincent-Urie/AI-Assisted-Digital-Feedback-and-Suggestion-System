<<<<<<< HEAD
# AI-Assisted-Digital-Feedback-and-Suggestion-System
=======
# EmoTune: AI-Assisted Mood-Based Music Recommendation System

This repository documents how to build **EmoTune**, a sentiment-driven music recommendation system that detects a user's current emotion from free-form text and generates mood-aligned playlists using Spotify.

The documentation is based on the provided capstone chapters and is structured as an implementation guide.

## 1. Project Overview

### Problem
Traditional music streaming recommendations mostly rely on listening history and do not respond well to a user's real-time emotional state.

### Solution
EmoTune uses sentiment analysis and AI to:
- analyze text input (example: "I feel stressed from school"),
- detect current mood,
- generate playlists that match emotional needs,
- adapt recommendations over time using listening behavior and feedback.

### Target Users
- Primary: college students (initially scoped for Leyte Normal University students)
- Secondary: administrators or guidance personnel monitoring aggregate usage and mood trends

## 2. Objectives

EmoTune is designed to:
- build a real-time mood-based playlist recommendation system,
- process both structured and unstructured data for personalization,
- classify emotion using a Naive Bayes-based sentiment module,
- evaluate quality using white-box, black-box, and ISO/IEC 25010:2011 criteria.

## 3. Scope and Limitations

### Scope
- Web-based system with user and admin modules
- User registration/login and profile management
- Text-based mood input and emotion detection
- Emotion-aware playlist generation via Spotify API
- Listening history and adaptive recommendation logic
- Mood visualization (for example, pie chart of detected emotion distribution)
- Admin dashboard with user and system analytics

### Limitations
- English text input only
- Requires internet connection
- Recommendation platform only (no music download into system)
- Simple single-turn AI follow-up prompts (non-conversational)

## 4. Core Features

### User Features
- Secure registration and login
- Free-form text mood expression
- Emotion detection and playlist generation
- Multiple playlist options per mood
- Listening history tracking
- Adaptive recommendation based on repeated behavior
- Basic emotional reflection prompts

### Admin Features
- Secure admin login
- Active user and total user metrics
- Monthly playlist generation trends
- Mood distribution and common mood insights
- Account search, view, and delete actions

## 5. Emotion Categories

Suggested emotion classes from the project materials:
- happy
- sad
- angry
- stressed
- calm
- lonely
- romantic
- nostalgic
- motivational
- fearful
- depressing
- mixed

## 6. System Architecture

Recommended implementation architecture:

1. Frontend (Flutter UI)
- user authentication screens
- mood input and playlist result views
- charts for mood analytics
- admin dashboard pages

2. Backend API
- authentication and authorization
- mood analysis endpoint
- recommendation and ranking endpoint
- history and analytics endpoints

3. Sentiment/ML Module
- text preprocessing
- Naive Bayes classifier inference
- optional support models (TextBlob/VADER) for hybrid scoring

4. Data Layer
- user profiles
- mood logs
- recommendation sessions
- playback/listening interactions

5. External Services
- Spotify Web API for track search and metadata
- optional Spotify playback SDK integration

## 6.1 Project File Structure

```text
emotune/
|-- README.md
|-- SYSTEM_ARCHITECTURE.md
|-- DATABASE_SCHEMA.md
|-- docker-compose.yml
|-- .gitignore
|-- backend/
|   |-- .env.example
|   |-- Dockerfile
|   |-- requirements.txt
|   `-- app/
|       |-- main.py
|       |-- core/
|       |   `-- config.py
|       |-- api/v1/
|       |   |-- router.py
|       |   `-- endpoints/
|       |       |-- health.py
|       |       |-- auth.py
|       |       |-- mood.py
|       |       |-- recommendations.py
|       |       `-- admin.py
|       |-- schemas/
|       |   `-- mood.py
|       `-- services/
|           |-- sentiment_service.py
|           `-- spotify_service.py
|-- frontend/
|   |-- .env.example
|   |-- Dockerfile
|   |-- pubspec.yaml
|   |-- analysis_options.yaml
|   |-- lib/
|   |   |-- main.dart
|   |   |-- core/
|   |   |   |-- config.dart
|   |   |   `-- theme.dart
|   |   |-- features/
|   |   |   |-- auth/login_page.dart
|   |   |   |-- mood/mood_input_page.dart
|   |   |   |-- recommendations/recommendations_page.dart
|   |   |   `-- admin/admin_dashboard_page.dart
|   |   `-- widgets/app_shell.dart
|   `-- web/
|       `-- index.html
`-- database/
    |-- init/
    |   |-- 001_schema.sql
    |   `-- 002_seed_admin.sql
    `-- migrations/
```

## 7. End-to-End Flow

1. User submits mood text.
2. Backend preprocesses text (normalize, tokenize, clean).
3. Sentiment module predicts emotion class.
4. Emotion is mapped to music parameters (valence, energy, tempo/BPM, etc.).
5. System queries Spotify for candidate tracks/playlists.
6. Ranking logic reorders candidates using user history and feedback.
7. Playlists are returned to UI and session is stored.
8. Mood and interaction data update future recommendations.

## 8. Data Design

### Unstructured Data
- raw user mood text input

### Structured Data
- predicted emotion class and confidence
- timestamps
- listening history and repeated plays
- audio features (BPM, valence, energy, danceability)
- generated playlist metadata

### Suggested Tables
- `users`
- `profiles`
- `mood_entries`
- `emotion_predictions`
- `recommendation_sessions`
- `session_tracks`
- `listening_events`
- `admin_audit_logs`

## 9. Tech Stack

- Frontend: Flutter
- Backend: FastAPI (Python)
- ML/NLP: scikit-learn (Naive Bayes), optional TextBlob/VADER support
- Database: MySQL
- DB Admin: phpMyAdmin
- Music Source: Spotify Web API
- Containerization: Docker + Docker Compose

## 10. Setup Guide

### 10.1 Prerequisites
- Docker Desktop (includes Docker Compose)
- Spotify Developer account and app credentials

### 10.2 Environment Variables

Create `backend/.env`:

```env
APP_ENV=development
API_PORT=8000

DB_HOST=db
DB_PORT=3306
DB_NAME=emotune
DB_USER=emotune
DB_PASSWORD=emotune123

SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
SPOTIFY_REDIRECT_URI=http://localhost:8080/callback

JWT_SECRET=replace_with_secure_value
```

Create `frontend/.env` (optional):

```env
API_BASE_URL=http://localhost:8000
```

### 10.3 Docker Setup (Python + Flutter + phpMyAdmin + MySQL)

Add `docker-compose.yml` at project root:

```yaml
services:
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: emotune-api
    env_file:
      - ./backend/.env
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy

  flutter-web:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: emotune-flutter
    ports:
      - "8080:80"
    depends_on:
      - api

  db:
    image: mysql:8.0
    container_name: emotune-db
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: emotune
      MYSQL_USER: emotune
      MYSQL_PASSWORD: emotune123
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./database/init:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-uroot", "-proot"]
      interval: 10s
      timeout: 5s
      retries: 10

  phpmyadmin:
    image: phpmyadmin:5-apache
    container_name: emotune-phpmyadmin
    restart: unless-stopped
    environment:
      PMA_HOST: db
      PMA_PORT: 3306
      PMA_USER: root
      PMA_PASSWORD: root
    ports:
      - "8081:80"
    depends_on:
      db:
        condition: service_healthy

volumes:
  mysql_data:
```

Backend Dockerfile (`backend/Dockerfile`):

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Flutter web Dockerfile (`frontend/Dockerfile`):

```dockerfile
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter config --enable-web
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Run:

```bash
docker compose up -d --build
```

Hot reload development (no rebuild for every code edit):

```bash
# Keep backend/db running
docker compose up -d api db phpmyadmin

# Run Flutter in dev mode with live reload on http://localhost:8082
docker compose -f docker-compose.yml -f docker-compose.dev.yml up flutter-dev
```

Notes:
- Edit files under `frontend/lib` and changes appear after hot reload.
- If reload does not trigger automatically, press `r` in the `flutter-dev` terminal.

Access:
- Flutter web: `http://localhost:8080`
- FastAPI: `http://localhost:8000`
- phpMyAdmin: `http://localhost:8081`
- MySQL: `localhost:3306`

phpMyAdmin login:
- username: `root`
- password: `root`

SQL initialization:
- Put SQL files in `database/init` (example: `database/init/001_schema.sql`).
- These files run automatically on first MySQL start.

Useful commands:

```bash
docker compose logs -f api
docker compose logs -f flutter-web
docker compose down
docker compose down -v
```

### 10.4 Optional Local (Non-Docker) Run

Backend:

```bash
cd backend
python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Frontend (Flutter):

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 10.5 Spotify Integration Setup

1. Create an app in Spotify Developer Dashboard.
2. Add redirect URI(s) used by your frontend/backend.
3. Store client credentials in backend environment variables.
4. Implement token retrieval and refresh flow.
5. Query tracks/playlists by mood-mapped audio parameters.

## 11. API Blueprint (Reference)

- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/mood/analyze`
- `POST /api/v1/recommendations/generate`
- `GET /api/v1/recommendations/history`
- `GET /api/v1/analytics/mood-distribution`
- `GET /api/v1/admin/dashboard`
- `DELETE /api/v1/admin/users/{id}`

## 12. Testing Strategy

### White-Box Testing
- unit tests for tokenizer/preprocessing
- unit tests for Naive Bayes inference and label mapping
- service-level tests for ranking logic

### Black-Box Testing
- user registration/login scenarios
- mood input to playlist output scenarios
- invalid input and error handling
- admin dashboard workflows

### Quality Evaluation (ISO/IEC 25010:2011)
- Functional suitability
- Performance efficiency
- Reliability
- Security
- Maintainability
- Flexibility

## 13. Security, Privacy, and Ethics

- Use HTTPS and secure token handling.
- Hash passwords and apply strict auth checks.
- Log only necessary behavioral data.
- Provide privacy notice and user consent for mood data processing.
- Add clear disclaimer: system supports emotional well-being but is not a clinical diagnostic tool.

## 14. Future Enhancements

- multilingual sentiment support
- richer conversational emotional support
- better personalization through feedback weighting
- early-risk intervention workflows with opt-in safety protocols
- model retraining pipeline with continuous evaluation

## 15. Project Team

- Joshua L. Pagatpat
- John Vincent L. Parado
- Andrei Campo
- Kristel Ann Pamilara

Institution: Leyte Normal University  
Program: Bachelor of Science in Information Technology  
Date: February 2026

---

If you want, this README can be followed by:
- a `SYSTEM_ARCHITECTURE.md` with diagrams,
- a `DATABASE_SCHEMA.md` with SQL DDL,
- and a `DEVELOPMENT_PLAN.md` with sprint-by-sprint tasks.
>>>>>>> b04213e (This is the new file structure)
