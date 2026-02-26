exec gunicorn -b 0.0.0.0:5000 \
     --workers=2 \
     --threads=4 \
     --worker-class=gthread \
     --timeout 120 \
     --log-level debug \
     --worker-tmp-dir /dev/shm \
     --log-file=- \
     --access-logfile=- \
     main:app \
