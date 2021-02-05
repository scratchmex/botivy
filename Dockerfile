FROM amazon/aws-lambda-python:3.8

ENV PIP_NO_CACHE_DIR=1
RUN pip install pipenv

# WORKDIR /app

COPY Pipfile* .
RUN pipenv install --system --deploy

COPY . .

EXPOSE 3000

# CMD ["uvicorn", "main:app", "--host=0.0.0.0", "--port=3000"]

CMD ["ivy_bot.aws_lambda.handler"]