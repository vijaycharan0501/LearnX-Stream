import os
import uvicorn
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from models.schemas import HealthResponse
from routes.analyze import router as analyze_router

# Load environment variables
load_dotenv()

app = FastAPI(
    title="LearnX STREAM API",
    description="Backend AI pedagogical engine for LearnX STREAM — 'Turn Information Into Understanding'",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS configuration to allow Flutter Web development origins and mobile clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get(
    "/health",
    response_model=HealthResponse,
    tags=["System"],
    summary="API Health Check",
    description="Returns service availability and status for LearnX STREAM backend.",
)
async def health_check() -> HealthResponse:
    return HealthResponse(
        status="ok",
        service="LearnX STREAM API",
    )


# Include analysis routes
app.include_router(analyze_router)

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8001))
    host = os.getenv("HOST", "0.0.0.0")
    uvicorn.run("main:app", host=host, port=port, reload=True)
