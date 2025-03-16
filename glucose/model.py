from datetime import UTC, datetime

from pydantic import PositiveFloat
from sqlmodel import Field, SQLModel


class Measurement(SQLModel, table=True):
    id: int | None = Field(default=None, primary_key=True)
    created_at: datetime = Field(default_factory=lambda: datetime.now(tz=UTC))
    weight_in_kg: PositiveFloat
