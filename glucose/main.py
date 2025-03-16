from contextlib import asynccontextmanager
from datetime import datetime
from typing import List

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from pydantic import BaseModel, PositiveFloat, PositiveInt
from sqlmodel import col, select

from .database import create_db_tables, db_session
from .model import Measurement


@asynccontextmanager
async def lifespan(_: FastAPI):
    create_db_tables()
    yield


app = FastAPI(lifespan=lifespan)


class Message(BaseModel):
    detail: str


def not_found(thing: str):
    return JSONResponse(status_code=404, content={"detail": f"{thing} not found"})


def no_content():
    return JSONResponse(status_code=204, content=None)


class CreateMeasurementRequest(BaseModel):
    weight_in_kg: PositiveFloat


class CreateMeasurementResponse(BaseModel):
    id: PositiveInt
    created_at: datetime
    weight_in_kg: PositiveFloat


@app.post("/measurements/")
def create_measurement(request: CreateMeasurementRequest):
    measurement = Measurement(weight_in_kg=request.weight_in_kg)
    with db_session() as session:
        session.add(measurement)
        session.commit()
        assert measurement.id is not None
        assert measurement.created_at is not None
        return CreateMeasurementResponse(
            id=measurement.id, created_at=measurement.created_at, weight_in_kg=measurement.weight_in_kg
        )


class ListMeasurementsResponse(BaseModel):
    measurements: List[Measurement]


@app.get("/measurements/")
def list_measurements():
    with db_session() as session:
        query = select(Measurement).order_by(col(Measurement.created_at).desc())
        measurements = session.exec(query).all()
        return measurements


class GetMeasurementResponse(Measurement):
    pass


@app.get("/measurements/{id}", responses={404: {"model": Message}})
def get_measurement(
    id: PositiveInt,
):
    with db_session() as session:
        query = select(Measurement).where(col(Measurement.id) == id)
        measurement = session.exec(query).first()
        if measurement is None:
            return not_found("Measurement")
        return GetMeasurementResponse(
            id=measurement.id, created_at=measurement.created_at, weight_in_kg=measurement.weight_in_kg
        )


class UpdateMeasurementRequest(BaseModel):
    weight_in_kg: PositiveFloat


class UpdateMeasurementResponse(BaseModel):
    id: PositiveInt
    created_at: datetime
    weight_in_kg: PositiveFloat


@app.put("/measurements/{id}", responses={404: {"model": Message}})
def update_measurement(id: PositiveInt, request: UpdateMeasurementRequest):
    with db_session() as session:
        statement = select(Measurement).where(col(Measurement.id) == id)
        measurement = session.exec(statement).first()
        if measurement is None:
            return not_found("Measurement")
        measurement.weight_in_kg = request.weight_in_kg
        session.commit()
        assert measurement.id is not None
        assert measurement.created_at is not None
        return UpdateMeasurementResponse(
            id=measurement.id, created_at=measurement.created_at, weight_in_kg=measurement.weight_in_kg
        )


@app.delete("/measurements/{id}", responses={404: {"model": Message}})
def delete_measurement(id: PositiveInt):
    with db_session() as session:
        statement = select(Measurement).where(col(Measurement.id) == id)
        measurement = session.exec(statement).first()
        if measurement is None:
            return not_found("Measurement")
        session.delete(measurement)
        session.commit()
    return no_content()
