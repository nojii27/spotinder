FROM alpine:3.17.0
ENV PYTHONUNBUFFERED=1

RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN apk add jpeg-dev zlib-dev
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools
RUN pip3 install Django
RUN pip3 install bcrypt
RUN pip3 install Authlib
RUN pip3 install requests
RUN pip3 install channels
RUN pip3 install 'uvicorn[standard]'
RUN pip3 install gunicorn
RUN apk add nginx
RUN rm -rf /etc/nginx/http.d
RUN apk add --virtual .build-deps build-base linux-headers python3-dev && pip install Pillow

WORKDIR /spotinder
CMD ["./start.sh"]
