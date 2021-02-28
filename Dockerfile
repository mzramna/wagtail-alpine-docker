# Use an official Python runtime based on Debian 10 "buster" as a parent image.
FROM python:3.8.1-alpine3.11

# Port used by this container to serve HTTP.
EXPOSE 8000

# Set environment variables.
# 1. Force Python stdout and stderr streams to be unbuffered.
# 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
#    command.
ENV PYTHONUNBUFFERED=1 \
    PORT=8000

# Install system packages required by Wagtail and Django.
RUN apk add --update \
    build-base \
    openssl \
    freetype-dev \
    fribidi-dev \
    harfbuzz-dev \
    jpeg-dev \
    lcms2-dev \
    openjpeg-dev \
    tcl-dev \
    tiff-dev \
    tk-dev \
    zlib-dev \
    bash \
    zlib \
    curl \
    jpeg \
    jpeg-dev \
    libpng \
    tiff \
    build-base \
    wget \
    postgresql-dev \
    && apk update \
    && apk upgrade

# Install the project requirements.
COPY requirements.txt /
RUN pip install -r /requirements.txt

RUN wagtail start app

# Use /app folder as a directory where the source code is stored.
WORKDIR /app

# Collect static files.
RUN python manage.py collectstatic --noinput --clear && python manage.py migrate

EXPOSE 8000
# Runtime command that executes when "docker run" is called, it does the
# following:
#   1. Migrate the database.
#   2. Start the application server.
# WARNING:
#   Migrating database at the same time as starting the server IS NOT THE BEST
#   PRACTICE. The database should be migrated manually or using the release
#   phase facilities of your hosting platform. This is used only so the
#   Wagtail instance can be started with a simple "docker run" command.
CMD python manage.py runserver 0.0.0.0:8000
