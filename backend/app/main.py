import logging
from fastapi import FastAPI, APIRouter


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - App - %(levelname)s - %(message)s",
)

logger = logging.getLogger(__name__)

app = FastAPI()

router = APIRouter(prefix="/api", tags=["default"])


@router.get("/hello")
def hello():
    logger.info("Hello endpoint called")
    return {"message": "Hello from the Ride Service!"}


app.include_router(router)
