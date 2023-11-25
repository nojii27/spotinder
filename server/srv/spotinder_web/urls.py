from django.urls import path, re_path

from . import views

urlpatterns = [
    path('', views.show_doc, name='index'),
    path('login', views.LoginView.as_view(), name='login'),
    path('register', views.RegisterView.as_view(), name='register'),
    path('spotify/callback', views.SpotifyCallbackView.as_view(), name='spotify/callback'),
    path('spotify/disconnect', views.SpotifyDisconnect.as_view(), name='spotify/disconnect'),
    re_path('profile$', views.ProfileView.as_view(), name='profile'),
    path('profile/<int:id>', views.ProfileIDView.as_view(), name='profile/ID'),
    path('picture/<int:id>', views.PictureID.as_view(), name='picture/ID'),
    path('picture/<int:id>/blurred', views.PictureID.as_view(), name='picture/ID/blurred'),
    path('profiles', views.ProfilesView.as_view(), name='profiles'),
    path('swipe', views.SwipeView.as_view(), name='swipe'),
    path('matches', views.MatchesView.as_view(), name='matches'),
    path('match/<int:id>', views.MatchView.as_view(), name='match'),
    path('messenger/<int:id>', views.MessengerView.as_view(), name='messenger')
]
