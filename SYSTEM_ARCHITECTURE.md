# EmoTune System Architecture

## 1. High-Level Architecture

```mermaid
flowchart LR
    U[End User] --> F[Flutter App]
    A[Admin User] --> F

    F -->|HTTPS REST| API[FastAPI Backend]
    API --> NLP[Sentiment Service\nNaive Bayes / NLP]
    API --> REC[Recommendation Engine]
    API --> DB[(MySQL)]
    API --> SP[Spotify Web API]

    DB --> P[phpMyAdmin]
```

## 2. Docker Deployment View

```mermaid
flowchart TB
    subgraph DockerHost[Docker Compose Host]
        FE[flutter-web\nNginx Container\n:8080]
        BE[api\nFastAPI Container\n:8000]
        SQL[db\nMySQL 8 Container\n:3306]
        PMA[phpmyadmin Container\n:8081]
    end

    FE -->|REST calls| BE
    BE --> SQL
    BE -->|music metadata + recommendations| SPOTIFY[Spotify API]
    PMA --> SQL
```

## 3. Recommendation Request Sequence

```mermaid
sequenceDiagram
    participant User
    participant Flutter as Flutter App
    participant API as FastAPI
    participant NLP as Sentiment Module
    participant DB as MySQL
    participant Spotify as Spotify API

    User->>Flutter: Enter mood text
    Flutter->>API: POST /api/v1/mood/analyze
    API->>NLP: Preprocess + classify emotion
    NLP-->>API: emotion + confidence
    API->>DB: Save mood entry + prediction
    API->>Spotify: Search tracks by mapped mood features
    Spotify-->>API: Candidate tracks
    API->>DB: Save recommendation session + tracks
    API-->>Flutter: Return playlists
    User->>Flutter: Play/skip/like track
    Flutter->>API: POST listening event
    API->>DB: Persist event for adaptive ranking
```

## 4. Core Components

### Flutter App
- Handles login, mood input, playlist rendering, playback controls, and analytics charts.
- Calls backend APIs only; no direct DB access.

### FastAPI Backend
- Auth and role checks (user/admin).
- Mood analysis orchestration.
- Spotify query and playlist ranking.
- Persists mood logs, recommendations, and listening events.

### Sentiment Module
- Text preprocessing (tokenize, normalize, clean).
- Naive Bayes inference for mood classification.
- Optional hybrid scoring (TextBlob/VADER) if enabled.

### MySQL
- Stores users, profiles, mood entries, predictions, sessions, tracks, and logs.
- Indexed for timeline queries and admin analytics.

### phpMyAdmin
- Admin SQL inspection and troubleshooting.
- Should be restricted to trusted environments.

## 5. Backend Module Boundaries

- `Auth Module`: register, login, token validation, role checks
- `Mood Module`: parse input and return emotion classification
- `Recommendation Module`: map emotion to audio targets and fetch tracks
- `History Module`: listening events and personalization signals
- `Admin Module`: usage metrics, mood distribution, user management

## 6. Security and Reliability Notes

- Enforce HTTPS in production.
- Keep Spotify and DB secrets in environment variables only.
- Use least-privilege DB accounts for API runtime.
- Add request validation, rate limiting, and API logging.
- Back up MySQL volume and monitor failed auth attempts.

