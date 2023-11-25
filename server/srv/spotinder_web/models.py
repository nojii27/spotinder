from django.db import models
from django.core.serializers import serialize
from django.core.exceptions import ValidationError
from django.db.models import Q

import json
import bcrypt
import uuid

from datetime import date

class User(models.Model):
    username = models.CharField(max_length=50)
    hash = models.CharField(max_length=60)
    spotify_token = models.TextField(null=True, default=None)

    users = models.Manager()


class Profile(models.Model):
    GENDER = (
        'M',
        'F',
        'O'
    )

    description = models.TextField(max_length=500)
    localisation = models.CharField('Country code', max_length=2)
    surname = models.TextField(max_length=15)
    gender = models.CharField(max_length=1)
    dateOfBirth = models.DateField()
    user = models.ForeignKey(User, on_delete=models.CASCADE)

    profiles = models.Manager()

    def validate(self):
        if len(self.description) <= 2 or len(self.description) >= 500:
            raise ValidationError(
                'Invalid description: %(value)s',
                params={'value': self.description},
                )
        if self.gender not in self.GENDER:
            raise ValidationError(
                'Invalid gender: %(value)s',
                params={'value': self.gender},
                )
        if len(self.surname) <= 2 or len(self.surname) > 15:
            raise ValidationError(
                'Invalid surname: %(value)s',
                params={'value': self.surname},
                )
        if Profile.calculate_age(self.dateOfBirth) < 16:
            raise ValidationError(
                'Invalid age (must be at least 16): %(value)s',
                params={'value': self.dateOfBirth},
                )
        if len(self.localisation) != 2:
            raise ValidationError(
                'Bad country code: %(value)s',
                params={'value': self.localisation},
                )

    def getSurname(self):
        return self.surname

    def getRelationshipBetweenProfiles(p1, p2):
        # returns None or proposition or match or accepted or same
        if p1 == p2:
            return 'same'

        matches = Match.matches.filter(Q(p1=p1, p2=p2) | Q(p1=p2, p2=p1))
        if len(matches) == 1:
            if matches[0].p1accepted is True and matches[0].p2accepted is True:
                return 'accepted'

            return 'match'
        try:
            proposition = ProfileProposition.propositions.get(userProfile=p1, propositionProfile=p2)
            return 'proposition'
        except ProfileProposition.DoesNotExist:
            return None

    def calculate_age(dob: date):
        today = date.today()
        return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day))

    def serialize(self, request):
        out = {}
        out['id'] = self.id
        out['surname'] = self.surname
        out['description'] = self.description
        out['age'] = Profile.calculate_age(self.dateOfBirth)
        out['gender'] = self.gender

        images = Picture.pictures.filter(profile=self)
        out.update({'images': list(images.values('id'))})
        for i in out['images']:
            i['download_url'] = f"{request.scheme}://{request.get_host()}/api/picture/{i['id']}"
        return out


class Picture(models.Model):
    data = models.TextField('base64 encoded image')
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE)

    pictures = models.Manager()


class Swipe(models.Model):
    DIRECTION = (
        'left',
        'right',
        )
    direction = models.TextField(max_length=6)
    p1 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 1', related_name='p1swipe')
    p2 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 2', related_name='p2swipe')

    swipes = models.Manager()

    def validate(self):
        if self.direction not in Swipe.DIRECTION:
            raise ValidationError(
                'Invalid swipe direction: %(value)s',
                params={'value': self.direction},
                )


class Match(models.Model):
    p1 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 1', related_name='p1match')
    p2 = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='Profile 2', related_name='p2match')
    p1accepted = models.BooleanField(default=False)
    p2accepted = models.BooleanField(default=False)

    matches = models.Manager()

    def serializeMatchesForProfile(profile: Profile, request):
        serializedMatches = []

        # get matches where p1 = the asker profile
        matches = Match.matches.filter(p1=profile)
        for m in matches:
            images = list(Picture.pictures.filter(profile=m.p2))
            imageDict = None
            if len(images) > 0:
                firstImage = images[0]
                imageDict = {
                    'id': firstImage.id,
                    'download_url': f"{request.scheme}://{request.get_host()}/api/picture/{firstImage.id}/blurred"
                }
            try:
                lastMsg = Message.messages.filter(match=m)
                if len(lastMsg) > 0:        #casting to list to get last element (last message)
                    lastMsg = list(lastMsg)[-1]
                    lastMsg = lastMsg.serialize(profile.user == lastMsg.sender) #serialize returns a map
                else:
                    lastMsg = None
    
            except Exception as e:
                print(e)
            match = {
                'id': m.id,
                'accepted': m.p1accepted,
                'profile': {
                    'id': m.p2.id,
                    'surname': m.p2.surname,
                    'accepted': m.p2accepted,
                    'image': imageDict,
                    },
                'last_message': lastMsg
            }
            serializedMatches.append(match)
        
        # get matches where p2 = the asker profile
        matches = None
        matches = Match.matches.filter(p2=profile)
        for m in matches:
            images = list(Picture.pictures.filter(profile=m.p1))
            imageDict = None
            if len(images) > 0:
                firstImage = images[0]
                imageDict = {
                    'id': firstImage.id,
                    'download_url': f"{request.scheme}://{request.get_host()}/api/picture/{firstImage.id}/blurred"
                }
            try:
                lastMsg = Message.messages.filter(match=m)
                if len(lastMsg) > 0:
                    lastMsg = list(lastMsg)[-1]
                    lastMsg = lastMsg.serialize(profile.user == lastMsg.sender)
                else:
                    lastMsg = None

            except Exception as e:
                print(e)
            match = {
                'id': m.id,
                'accepted': m.p2accepted,
                'profile': {
                    'id': m.p1.id,
                    'surname': m.p1.surname,
                    'accepted': m.p1accepted,
                    'image': imageDict,
                },
                'last_message': lastMsg
            }
            serializedMatches.append(match)

        return serializedMatches


class Artist(models.Model):
    spotifyID = models.TextField(verbose_name='spotify artist ID')
    name = models.TextField(verbose_name='artist name')
    profileArtist = models.ManyToManyField(Profile, verbose_name='profile artists')

    artists = models.Manager()


class Genre(models.Model):
    name = models.TextField(verbose_name='artist genre')
    artistGenre = models.ManyToManyField(Artist, verbose_name='artist genres')

    genres = models.Manager()


class ProfileProposition(models.Model):
    userProfile = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='user profile', related_name='userProfile')
    propositionProfile = models.ForeignKey(Profile, on_delete=models.CASCADE, verbose_name='proposed profile', related_name='propositionProfile')
    match = models.IntegerField(verbose_name="match percentage")
    # matchingArtists = models.ManyToManyField(Artist, verbose_name='matching artists')
    matchingGenres = models.ManyToManyField(Genre, verbose_name='matching genre', related_query_name='propositionProfile')

    propositions = models.Manager()


class Message(models.Model):
    match = models.ForeignKey(Match, on_delete=models.CASCADE)
    sender = models.ForeignKey(Profile, on_delete=models.CASCADE)
    content = models.TextField(max_length=1000)
    timestamp = models.DateTimeField(auto_now_add=True)
    isRead = models.BooleanField(default=False)

    messages = models.Manager()

    def serialize(self, isSender):
        out = {}
        out['sender'] = isSender
        out['timestamp'] = self.timestamp.strftime("%D %H:%M:%S")
        out['content'] = self.content
        out['isRead'] = self.isRead
        return out

class Sessions():
    from threading import Lock

    _sessions = {}
    _mutex = Lock()

    def addSession(user: User):
        Sessions._mutex.acquire()
        try:
            for u in Sessions._sessions.items():
                if u[1] == user.id:
                    return u[0]

            token = str(Sessions.genToken())
            Sessions._sessions[token] = user.id
        except:
            token = None
        finally:
            Sessions._mutex.release()
        return token

    def genToken():
        return str(uuid.uuid4())

    def getUser(token: str):
        Sessions._mutex.acquire()
        out = None
        try:
            uid = Sessions._sessions[token]
            out = User.users.get(id=uid)
        except Exception as e:
            print(e)
        finally:
            Sessions._mutex.release()

        return out
