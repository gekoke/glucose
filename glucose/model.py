from sqlalchemy import Column, DateTime, Double, Integer, func
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class Model:
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())


class Measurement(Base):
    id = Column(Integer, primary_key=True, index=True)
    recorded_at = Column(DateTime(timezone=True), nullable=False, default=func.now())
    weight_in_kg = Column(Double, nullable=False)
