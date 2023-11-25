from django.urls import include, path
from channels.routing import URLRouter
import spotinder_web.routing

websocket_urlpatterns = [
    path('ws/', URLRouter(spotinder_web.routing.websocket_urlpatterns)),
]
