from django.urls import path
from django.urls import re_path
from .chat import ChatConsumer

websocket_urlpatterns = [
    re_path("chat*", ChatConsumer.as_asgi()),
]
