# Dockerfile
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    FLASK_ENV=development \
    PYTHONPATH=/app \
    AWS_DEFAULT_REGION=eu-central-1 \
    APP_HOME=/app \
    VENV_PATH=/opt/venv

# OS deps + Python tooling
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip nano ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Create and activate a venv
RUN python3 -m venv ${VENV_PATH}
ENV PATH="${VENV_PATH}/bin:${PATH}"

# App user and dir
RUN groupadd -r app && useradd -r -g app -d ${APP_HOME} -s /usr/sbin/nologin app
RUN mkdir -p ${APP_HOME} && chown -R app:app ${APP_HOME}
WORKDIR ${APP_HOME}

# Install Python deps in venv
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files (these will be overridden by your volume mounts at runtime, which is fine)
COPY --chown=app:app demo/ ./demo
COPY --chown=app:app main.py ./main.py
COPY --chown=app:app run.sh ./run.sh
COPY --chown=app:app tests/ ./tests
COPY --chown=app:app pytest.ini ./
COPY --chown=app:app .flake8 ./

# Logs dir + run.sh perms
RUN mkdir -p logs && touch logs/logs.txt && chown -R app:app logs && chmod +x run.sh

USER app

EXPOSE 5000
CMD ["sh", "run.sh"]
