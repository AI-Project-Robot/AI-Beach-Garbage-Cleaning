# Signal Distance API

A professional REST API for managing signal distance training data with POST and PUT endpoints.

## Project Structure

```
BackendAPI/
├── app.py              # Main application entry point
├── database.py         # Database configuration and initialization
├── models.py           # Data models (Signal model)
├── routes.py           # API routes/endpoints
├── config.py           # Application configuration
├── requirements.txt    # Python dependencies
└── README.md          # Documentation
```

## Data Model

The API manages signal records with the following fields:

- **SignalId**: Auto-generated primary key
- **send_timestamp**: When the signal was sent
- **t1_receive_timestamp**: When T1 received the signal
- **t2_receive_timestamp**: When T2 received the signal
- **t1_distance**: Distance calculated by T1
- **t2_distance**: Distance calculated by T2
- **t1_time_diff**: Time difference for T1
- **t2_time_diff**: Time difference for T2
- **actual_distance**: The actual measured distance

## Installation

1. **Prerequisites:**
   - MySQL Server running on localhost:3306
   - Create a database named `signal_distance_db`:
     ```sql
     CREATE DATABASE signal_distance_db;
     ```

2. **Install dependencies:**
```bash
pip install -r requirements.txt
```

3. **Configure database (optional):**
   Set environment variables if using different credentials:
   ```bash
   # Windows PowerShell
   $env:DB_USER="root"
   $env:DB_PASSWORD="your_password"
   $env:DB_HOST="localhost"
   $env:DB_PORT="3306"
   $env:DB_NAME="signal_distance_db"
   ```

4. **Run the application:**
```bash
python app.py
```

The API will start on `http://localhost:5000`

## API Documentation

Interactive Swagger documentation is available at:
**http://localhost:5000/api/docs/**

The Swagger UI provides:
- Interactive API testing
- Complete endpoint documentation
- Request/response schemas
- Example payloads

## API Endpoints

### POST /api/signals
Create a new signal record.

**Request Body:**
```json
{
  "send_timestamp": "2026-01-21 10:30:00",
  "t1_receive_timestamp": "2026-01-21 10:30:01",
  "t2_receive_timestamp": "2026-01-21 10:30:01",
  "t1_distance": 150.5,
  "t2_distance": 152.3,
  "t1_time_diff": 0.001,
  "t2_time_diff": 0.0012,
  "actual_distance": 151.0
}
```

**Response:**
- Success (201): Returns the `signal_id` as integer (e.g., `1`, `2`, `3`)
- Failure (200): Returns `0`

### PUT /api/signals/{signal_id}
Update an existing signal record. You can send any combination of fields to update.

**Request Body (all fields optional):**
```json
{
  "t1_distance": 151.0,
  "t2_distance": 151.5,
  "actual_distance": 151.2
}
```

**Response:**
- Success (200): Returns `true`
- Failure (200): Returns `false`

### GET /api/signals/{signal_id}
Retrieve a single signal record by ID.

**Response (200 OK):**
```json
{
  "signal_id": 1,
  "send_timestamp": "2026-01-21T10:30:00",
  "t1_receive_timestamp": "2026-01-21T10:30:01",
  "t2_receive_timestamp": "2026-01-21T10:30:01",
  "t1_distance": 150.5,
  "t2_distance": 152.3,
  "t1_time_diff": 0.001,
  "t2_time_diff": 0.0012,
  "actual_distance": 151.0
}
```

### GET /api/signals
Retrieve all signal records.

**Response (200 OK):**
```json
[
  {
    "signal_id": 1,
    "send_timestamp": "2026-01-21T10:30:00",
    ...
  },
  {
    "signal_id": 2,
    "send_timestamp": "2026-01-21T10:31:00",
    ...
  }
]
```

### DELETE /api/signals/{signal_id}
Delete a signal record.

**Response (200 OK):**
```json
{
  "message": "Signal deleted successfully"
}
```

## Testing with cURL

### Create a signal:
```bash
curl -X POST http://localhost:5000/api/signals \
  -H "Content-Type: application/json" \
  -d "{\"send_timestamp\":\"2026-01-21 10:30:00\",\"t1_receive_timestamp\":\"2026-01-21 10:30:01\",\"t2_receive_timestamp\":\"2026-01-21 10:30:01\",\"t1_distance\":150.5,\"t2_distance\":152.3,\"t1_time_diff\":0.001,\"t2_time_diff\":0.0012,\"actual_distance\":151.0}"
```

### Update a signal:
```bash
curl -X PUT http://localhost:5000/api/signals/1 \
  -H "Content-Type: application/json" \
  -d "{\"t1_distance\":151.0,\"actual_distance\":151.2}"
```

### Get a signal:
```bash
curl http://localhost:5000/api/signals/1
```

### Get all signals:
```bash
curl http://localhost:5000/api/signals
```

### Delete a signal:
```bash
curl -X DELETE http://localhost:5000/api/signals/1
```

## Database

The API uses SQLite database (`signals.db`) which is automatically created when you run the application for the first time.
