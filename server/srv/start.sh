#!/bin/sh

nginx
gunicorn --bind=unix:/tmp/gunicorn.sock spotinder.asgi -k uvicorn.workers.UvicornWorker
# gunicorn --bind=unix:/tmp/gunicorn.sock spotinder.wsgi
