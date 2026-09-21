# LearnX STREAM — Backend AI Architecture

FastAPI backend powered by Google Gemini (official `google-genai` Python SDK) for structured conceptual decomposition and modality recommendation.

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- Python 3.10+
- (Optional) Google Gemini API Key from [Google AI Studio](https://aistudio.google.com/)

---

### 2. Environment Setup

1. Open your terminal in the `backend/` directory:
   ```bash
   cd backend
   ```

2. Create and activate a Python virtual environment:
   ```bash
   # Windows (PowerShell)
   python -m venv venv
   .\venv\Scripts\Activate.ps1

   # Linux / macOS
   python3 -m venv venv
   source venv/bin/activate
   ```

3. Install required dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Configure your environment variables:
   ```bash
   # Copy example template
   cp .env.example .env
   ```
   Edit `.env` and add your Google Gemini API key:
   ```env
   GEMINI_API_KEY=AIzaSy...
   PORT=8000
   HOST=0.0.0.0
   ```

---

### 3. Run the Backend Server

Start the development server with live reload:
```bash
uvicorn main:app --reload --port 8000
```
Or simply run:
```bash
python main.py
```

The API will be live at `http://localhost:8000`.
- **Interactive Swagger Docs**: `http://localhost:8000/docs`
- **ReDoc Documentation**: `http://localhost:8000/redoc`

---

## 📡 Endpoints

### 1. Health Check
- **Endpoint**: `GET /health`
- **Response**:
  ```json
  {
    "status": "ok",
    "service": "LearnX STREAM API"
  }
  ```

### 2. Analyze Material
- **Endpoint**: `POST /analyze-material`
- **Request Body**:
  ```json
  {
    "title": "Binary Search",
    "text": "Binary Search is a search algorithm that finds the position of a target value within a sorted array..."
  }
  ```
- **Response Body**:
  ```json
  {
    "topic": "Binary Search",
    "summary": "Binary Search efficiently locates an element in a sorted list by repeatedly halving the search interval...",
    "concepts": [
      {
        "name": "Divide and Conquer",
        "type": "algorithmic_paradigm",
        "importance": "high"
      },
      {
        "name": "Logarithmic Time O(log N)",
        "type": "complexity_metric",
        "importance": "high"
      }
    ],
    "difficulty": "medium",
    "prerequisites": [
      "Sorted Arrays",
      "Index Arithmetic"
    ],
    "recommended_representation": {
      "type": "simulation",
      "reason": "Binary Search involves dynamic pointer bounds (low, mid, high) best understood through interactive step-by-step state simulation."
    }
  }
  ```
