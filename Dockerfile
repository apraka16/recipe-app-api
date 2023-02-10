FROM python:3.9-alpine3.13
LABEL maintainer="abhinav.prakash1@gmail.com"

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

ARG DEV=false

# RUN command
#1. Installs python virtual env in py folder
#2 Upgrades pip
#3 Adds postgres dependency
#4
#5
#6 Installs requirements in a temp folder
#7 Removes temp file from docker image
#8 Delete DB dependencies
#5 Adds a new user - it's best practice not to use the root user. Root user has full privileges, if the app is compromised the whole docker can be exposed
#6 No password specified
#7 Do not create the home dir for that user - not needed to do so. Keeps the image file light
#8 name of the user is: django-user

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
    django-user

# Updated the path env variable; when we run commands for the projects, we do not have to specific the actual path on which executables are executed, ie /py/bin. The path ENV does it.
ENV PATH="/py/bin:$PATH"

# Switch to the new user (from root user)
USER django-user