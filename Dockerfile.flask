FROM python:3.9

WORKDIR /app

COPY ./source/requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY ./source/http /app

EXPOSE 5000

ENV SECRET_KEY secret_string

CMD ["flask", "run", "--host=0.0.0.0"]