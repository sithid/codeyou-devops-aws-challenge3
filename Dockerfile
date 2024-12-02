FROM python:3.9

WORKDIR /app

COPY ./source/requirements.txt /app/requirements.txt

# Notice:
#    - Our working directory is `/app` which is where we put our requirements file

# FIXME: Consider the debugging case; jsmin will fail the pip install
RUN pip install -r requirements.txt

COPY ./source/http /app
EXPOSE 5000

CMD [ "flask", "run", "--host=0.0.0.0"]