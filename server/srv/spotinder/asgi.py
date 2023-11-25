"""
ASGI config for spotinder project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/asgi/
"""

import os
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.security.websocket import AllowedHostsOriginValidator
from django.core.asgi import get_asgi_application
from django.urls import path

import spotinder.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'spotinder.settings')

application = ProtocolTypeRouter({
    # Django's ASGI application to handle traditional HTTP requests
    "http": get_asgi_application(),

    # WebSocket chat handler
    'websocket': AuthMiddlewareStack(
        URLRouter(spotinder.routing.websocket_urlpatterns),
    ),
})
