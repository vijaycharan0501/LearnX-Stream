import logging
from fastapi import APIRouter, Depends, HTTPException, status
from models.schemas import MaterialAnalysisRequest, MaterialAnalysisResponse
from services.ai_service import AIService, get_ai_service

logger = logging.getLogger("learnx_router_analyze")
router = APIRouter(tags=["Analysis"])


@router.post(
    "/analyze-material",
    response_model=MaterialAnalysisResponse,
    status_code=status.HTTP_200_OK,
    summary="Analyze study material with AI",
    description="Processes raw study notes/documents and returns structured concepts, difficulty, summary, and recommended representation format.",
)
async def analyze_material_endpoint(
    payload: MaterialAnalysisRequest,
    ai_service: AIService = Depends(get_ai_service),
) -> MaterialAnalysisResponse:
    title = payload.title.strip()
    text = payload.text.strip()

    if not title and not text:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Topic title or study material cannot be empty.",
        )

    effective_title = title if title else (text.splitlines()[0][:60] if text else "Study Concept")
    effective_text = text if text else effective_title

    try:
        result = await ai_service.analyze_material(title=effective_title, text=effective_text)
        return result
    except ValueError as val_err:
        logger.warning(f"Validation error analyzing material: {val_err}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(val_err),
        )
    except Exception as exc:
        logger.error(f"Unexpected error during material analysis: {exc}", exc_info=True)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while analyzing the study material. Please try again.",
        )
