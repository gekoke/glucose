from sqlmodel import Session, SQLModel, create_engine

from .env import read_env_or_raise

_connection_string = read_env_or_raise("GLUCOSE_POSTGRES_CONNECTION_STRING")


def _engine():
    return create_engine(_connection_string)


def create_db_tables():
    SQLModel.metadata.create_all(_engine())


def db_session():
    return Session(_engine())
