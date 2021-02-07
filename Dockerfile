ARG POETRY_HOME="/opt/poetry"
ARG PYSETUP_PATH="/opt/pysetup"
# defined via ARG to use later in other base images


FROM python:3.8-slim as base

ARG POETRY_HOME
ARG PYSETUP_PATH

# python env
ENV PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    \
    # pip
    PIP_NO_CACHE_DIR=off \
    \
    # poetry
    # https://python-poetry.org/docs/configuration/#using-environment-variables
    # make poetry install to this location
    POETRY_HOME=$POETRY_HOME \
    # make poetry create the virtual environment in the project's root
    # it gets named `.venv`
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    # do not ask any interactive question
    POETRY_NO_INTERACTION=1 \
    \
    # paths
    # this is where our requirements + virtual environment will live
    PYSETUP_PATH=$PYSETUP_PATH

# prepend poetry and venv to path
ENV PATH="$POETRY_HOME/bin:$PYSETUP_PATH/.venv/bin:$PATH"


FROM base AS build

WORKDIR $PYSETUP_PATH

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        # deps for installing poetry
        curl \
        # deps for building python deps
        build-essential

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

COPY poetry.lock pyproject.toml ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# `development` image is used during development / testing
FROM base as development

WORKDIR $PYSETUP_PATH

# copy in our built poetry + venv
COPY --from=build $POETRY_HOME $POETRY_HOME
COPY --from=build $PYSETUP_PATH $PYSETUP_PATH

# quicker install as runtime deps are already installed
RUN poetry install

WORKDIR /app

COPY . ./

CMD ["uvicorn", "ivy_bot.api:app", "--port=3000"]


FROM amazon/aws-lambda-python:3.8 as production
# FROM python:3.8-alpine as production

# WORKDIR /app

ARG PYSETUP_PATH
ENV PATH="$PYSETUP_PATH/.venv/bin:$PATH"

COPY --from=build $PYSETUP_PATH $PYSETUP_PATH
RUN cp -rsf $PYSETUP_PATH/.venv/lib /var/lang/

COPY . ./

CMD ["ivy_bot.aws_lambda.handler"]