from os import getenv


def read_env_or_raise(env_var: str):
    value = getenv(env_var)
    if value is None:
        raise Exception(f"You must set the {env_var} environment variable")
    return value
