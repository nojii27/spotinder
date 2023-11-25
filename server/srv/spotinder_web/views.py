from django.http import HttpResponse, HttpResponseBadRequest, HttpResponseNotFound, HttpResponseForbidden
from django.http import HttpRequest
from django.core.serializers import serialize
from django.views import View
from django.forms.models import model_to_dict
from django.core.serializers.json import DjangoJSONEncoder
from django.db.models import Q
from django.shortcuts import render
from authlib.integrations.django_client import OAuth
from authlib.integrations.requests_client import OAuth2Session

import requests
import base64
import json
import datetime
from PIL import Image, ImageFilter
from io import BytesIO

from .models import *

date_format = '%d/%m/%Y'

def show_doc(request):
    return render(template_name='Spotinder.html', request=request)

def verifyToken(request):
    try:
        token = request.headers['Authorization']
        return Sessions.getUser(token)
    except Exception as e:
        print(e)

    return None

def verifyStrToken(token):
    try:
        return Sessions.getUser(token)
    except Exception as e:
        print(e)

    return None

class JsonResponse():
    successStr = 'success'
    errorStr = 'error'
    def __init__(self, status='success', errorMsg=None, data=None):
        if (status != self.successStr and status != self.errorStr):
            raise Exception(
                f'status should be "{self.successStr}" or "{self.errorStr}" only'
                )

        self.respDict = {
            'status': status,
            'error_msg': errorMsg,
        }

        if data is None:
            self.respDict['data'] = None
        elif isinstance(data, str):
            self.respDict['data'] = json.loads(data)
        elif isinstance(data, dict):
            self.respDict['data'] = data
        else:
            self.respDict['data'] = data

    def json(self):
        return json.dumps(self.respDict, indent=4, default=JsonResponse.customJsonConverter)

    def customJsonConverter(o):
        if isinstance(o, datetime.date):
            return o.strftime(date_format)


class LoginView(View):
    def post(self, request, *args, **kwargs):
        try:
            json_data = json.loads(request.body)
            username = json_data["username"]
            password = json_data["password"]
            loginAttempt = self.performLogin(username, password)
            if loginAttempt[0]:
                data = {
                    'token': loginAttempt[1],
                    }
                # Do we need a spotify token?
                if (loginAttempt[2]):
                    data['spotifyURL'] = Spotify.getAuthURL(loginAttempt[3])
                else:
                    data['spotifyURL'] = None

                return HttpResponse(
                    JsonResponse(status='success', data=data).json(),
                    content_type="application/json"
                    )
            else:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Wrong username or password').json(),
                    content_type="application/json"
                    )

        except Exception as e:
            print(e)
            return HttpResponse(
                JsonResponse(status='error', errorMsg="Authentication failed").json(),
                content_type="application/json"
                )

    def performLogin(self, usern, passw):
        try:
            # verify hash
            entry = User.users.get(username=usern)
            if bcrypt.checkpw(passw.encode('utf-8'), entry.hash.encode('utf-8')):
                out = [True, Sessions.addSession(entry)]
            else:
                return [False]

            # check if spotify token is needed
            if entry.spotify_token is None:
                out.append(True)
                out.append(entry)
            else:
                out.append(False)

            return out

        except (Exception, User.DoesNotExist) as e:
            print(e)

        return [False]


class RegisterView(View):
    def post(self, request, *args, **kwargs):
        try:
            json_data = json.loads(request.body)
            username = json_data["username"]
            password = json_data["password"]
            # verify if user with same username doesn't
            # already exists
            users = list(User.users.filter(username=username))
            if len(users) > 0:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Username already exists").json(),
                    content_type="application/json"
                    )

            hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
            user = User(username=username, hash=hash.decode('utf-8'))
            user.save()

            return HttpResponse(
                JsonResponse(status='success').json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )


class SpotifyCallbackView(View):
    def get(self, request, *args, **kwargs):
        try:
            code = request.GET['code']
            state = request.GET['state']

            Spotify.saveAccessToken(state, code)

            return HttpResponse(
                JsonResponse(status='success').json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )

class SpotifyDisconnect(View):
    def post(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            user.spotify_token = None
            user.save()

            return HttpResponse(
                JsonResponse(status='success').json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )


class ProfileView(View):
    # return data about the profile
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            profile = Profile.profiles.get(user=user)
            images = Picture.pictures.filter(profile=profile)
            data = model_to_dict(profile, fields=(
                'description',
                'localisation',
                'dateOfBirth',
                'surname',
                'gender',
                ))
            data['images'] = list(images.values('id'))
            for i in data['images']:
                i['download_url'] = f"{request.scheme}://{request.get_host()}/api/picture/{i['id']}"
            return HttpResponse(
                JsonResponse(status='success', data=data).json(),
                content_type='application/json'
                )

        except Profile.DoesNotExist:
            return HttpResponse(
                JsonResponse(status='error', errorMsg="No profile created for this user.").json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )

    # modify the user profile
    def post(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            json_data = json.loads(request.body)
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            try:
                profile = Profile.profiles.get(user=user)
            except Profile.DoesNotExist:
                profile = Profile(user=user)
            # set profiles fields
            profile.description = json_data['description']
            profile.localisation = json_data['localisation']
            profile.gender = json_data['gender']
            profile.surname = json_data['surname']
            try:
                date = datetime.datetime.strptime(json_data['dateOfBirth'],
                                                  date_format
                                                  )
                profile.dateOfBirth = date
            except Exception as e:
                print(e)
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Date format error.").json(),
                    content_type="application/json"
                    )
            try:
                profile.validate()
            except ValidationError as e:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg=str(e)).json(),
                    content_type="application/json"
                    )
            profile.save()

            # get existing images, if the content of the image
            # match we keep it otherwise we delete and add the
            # new ones
            newImages = json_data['images']
            existingImages = list(Picture.pictures.filter(profile=profile))

            # remove the existing images
            for ei in existingImages:
                ei.delete()

            # add new ones
            if len(newImages) > 5:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="There can only have 5 images per profile.").json(),
                    content_type="application/json"
                    )

            for ni in newImages:
                image = Picture(data=ni, profile=profile).save()

            return HttpResponse(
                JsonResponse(status='success').json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )

class ProfileIDView(View):
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        if user is None:
            return HttpResponse(
                JsonResponse(status='error', errorMsg="Bad token").json(),
                content_type="application/json"
                )
        try:
            # getting the user profile
            try:
                profile = Profile.profiles.get(user=user)
            except Profile.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="No profile created yet").json(),
                    content_type="application/json"
                    )

            # getting the requested profile and see if it was a potential match
            try:
                id = kwargs['id']
                requestedProfile = Profile.profiles.get(id=id)
                relationship = Profile.getRelationshipBetweenProfiles(profile, requestedProfile)
                if relationship is None:
                    return HttpResponse(
                        JsonResponse(status='error', errorMsg="Not allowed").json(),
                        content_type="application/json"
                        )
                elif relationship == 'proposition' or relationship == 'match':
                    data = requestedProfile.serialize(request)
                elif relationship == 'accepted' or 'same':
                    data = requestedProfile.serialize(request)
                    images = Picture.pictures.filter(profile=requestedProfile)
                    data.update({'images': list(images.values('id'))})
                    for i in data['images']:
                        i['download_url'] = f"{request.scheme}://{request.get_host()}/api/picture/{i['id']}"
                return HttpResponse(
                    JsonResponse(status='success', data=data).json(),
                    content_type="application/json"
                    )
            except Profile.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Not found").json(),
                    content_type="application/json"
                    )
            except ProfileProposition.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Not allowed").json(),
                    content_type="application/json"
                    )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )


class ProfilesView(View):
    def get(self, request, *args, **kwargs):
        # 1) GET user top artists
        # 2) GET the genres of those artists
        # 3) get the users in the same location
        # 4) find users that match (add percentages):
        # 4) update the proposition list
        # 5) sort the list so proposition with match percentage lower than 30% are at the end
        # 6) Dont update first element of the list, unless the profile is deleted

        user = verifyToken(request)
        if user is None:
            return HttpResponse(
                JsonResponse(status='error', errorMsg="Bad token").json(),
                content_type="application/json"
                )
        profile = Profile.profiles.get(user=user)
        topArtists = Spotify.getUserTopArtists(user)
        if topArtists is None or 'items' not in topArtists.keys():
            return HttpResponse(
                JsonResponse(status='error', errorMsg="Spotify error").json(),
                content_type="application/json"
                )

        ProfilesView.saveTopArtist(topArtists, profile)
        ProfilesView.savePotentialMatchingProfiles(profile)

        profilesProps = ProfileProposition.propositions.filter(userProfile=profile)

        data = []
        for p in profilesProps:
            # proposition data
            prop = model_to_dict(p, fields=('match'))

            # get profile informations
            prof = p.propositionProfile.serialize(request)
            prop['profile'] = prof

            # get featured genres
            genres = Genre.genres.filter(propositionProfile=p)
            genresList = []
            for g in genres:
                genresList.append(g.name)
            prop['genres'] = genresList

            data.append(prop)

        return HttpResponse(
            JsonResponse(status='success', data=data).json(),
            content_type="application/json"
            )

    def savePotentialMatchingProfiles(profile: Profile):
        localisation = profile.localisation

        # create a list of distincts top genres for the current profile
        artists, genres = ProfilesView.getGenresAndArtistListForProfile(profile)

        # for each user in the same localisation that hasn't matched with the user
        profiles = list(Profile.profiles.filter(
            Q(localisation=localisation) &
            ~Q(id=profile.id)
            ))

        matches = Match.matches.filter(Q(p1=profile))
        for p in profiles:
            for m in matches:
                if p == m.p2:
                    profiles.remove(p)
        matches = Match.matches.filter(Q(p2=profile))
        for p in profiles:
            for m in matches:
                if p == m.p1:
                    profiles.remove(p)

        # TODO when to delete?
        props = ProfileProposition.propositions.filter(userProfile=profile)
        for p in props:
            p.delete()

        # create a genre list and establish matching coefficient
        for p in profiles:

            pArtists, pGenres = ProfilesView.getGenresAndArtistListForProfile(p)
            featuredGenre = []

            # does not use spotify...
            if len(pGenres) < 1:
                continue

            if len(genres) < len(pGenres):
                smallestGenresList = genres
                biggestGenresList = pGenres
            else:
                smallestGenresList = pGenres
                biggestGenresList = genres

            for g in smallestGenresList:
                if g in biggestGenresList:
                    featuredGenre.append(g)

            # create a potential match
            matchCoef = float(len(featuredGenre)) / len(smallestGenresList)

            # compare preffered artists
            for a in artists:
                if a in pArtists:
                    matchCoef = matchCoef + 0.05

            # set maximum to 100%
            matchCoef = min(1, matchCoef)

            if matchCoef >= 0.2:
                proposition = ProfileProposition(
                    userProfile=profile,
                    propositionProfile=p,
                    match=int(matchCoef*100)
                    )

                proposition.save()

                for g in featuredGenre:
                    proposition.matchingGenres.add(g)

    def getGenresAndArtistListForProfile(profile: Profile):
        artists, genres = [], []
        artistsQ = Artist.artists.filter(profileArtist=profile)
        for a in artistsQ:
            artists.append(a)
            a_genres = Genre.genres.filter(artistGenre=a)
            for g in a_genres:
                if g not in genres:
                    genres.append(g)

        return artists, genres

    def saveTopArtist(topArtists, profile):
        try:
            # delete existing relations from artists to this profile
            artists = Artist.artists.filter(profileArtist=profile)
            for a in artists:
                a.profileArtist.remove(profile)

            # add new artists
            for item in topArtists['items']:
                if item['type'] == 'artist':
                    artist = Artist.artists.get_or_create(spotifyID=item['id'], name=item['name'])[0]
                    genreList = []
                    for genreName in item['genres']:
                        genre = Genre.genres.get_or_create(name=genreName)[0]
                        genre.artistGenre.add(artist)
                        genre.save()

                    artist.profileArtist.add(profile)
        except Exception as e:
            print(e)
            raise Exception(e)


class SwipeView(View):
    def post(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            json_data = json.loads(request.body)
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            profileID = json_data['id']
            swipeDir = json_data['swipe']
            profile1 = Profile.profiles.get(user=user)
            profile2 = Profile.profiles.get(id=int(profileID))

            if profile1 == profile2:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Cannot swipe the user own profile").json(),
                    content_type="application/json"
                    )

            # verify this profile was proposed earlier
            relationship = Profile.getRelationshipBetweenProfiles(profile1, profile2)

            if relationship != 'proposition':
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Not allowed").json(),
                    content_type="application/json"
                    )

            Swipe.swipes.get_or_create(direction=swipeDir, p1=profile1, p2=profile2)

            # is it a match?
            resp = None
            if swipeDir == 'right':
                swipes = Swipe.swipes.filter(p1=profile2, p2=profile1, direction='right')
                if swipes.count() > 0:
                    resp = {'match': True}
                    # create a new match
                    # find if not already created
                    matches = Match.matches.filter(Q(p1=profile1, p2=profile2) | Q(p1=profile2, p2=profile1))
                    if len(matches) < 1:
                        match = Match(p1=profile1, p2=profile2)
                        match.save()
                else:
                    resp = {'match': False}

            return HttpResponse(
                JsonResponse(status='success', data=resp).json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )


class MatchesView(View):
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            profile = Profile.profiles.get(user=user)
            matches = Match.serializeMatchesForProfile(profile, request)

            return HttpResponse(
                JsonResponse(status='success', data=matches).json(),
                content_type="application/json"
                )

        except Profile.DoesNotExist:
            return HttpResponse(
                JsonResponse(status='error', errorMsg="Profile not created yet").json(),
                content_type="application/json"
                )
        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )

class MatchView(View):
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            json_data = json.loads(request.body)
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            profile = Profile.profiles.get(user=user)

            try:
                match = Match.matches.get(id=kwargs['id'])
            except Match.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg=f'Wrong match id : {id}').json(),
                    content_type="application/json"
                    )

            if not (match.p1 == profile or match.p2 == profile):
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Permission denied').json(),
                content_type="application/json"
                    )
            resp = model_to_dict(match)

            return HttpResponse(
                JsonResponse(status='success', data=resp).json(),
                content_type="application/json"
                )

        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
            content_type="application/json"
            )

    def post(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            json_data = json.loads(request.body)
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )

            profile = Profile.profiles.get(user=user)

            try:
                match = Match.matches.get(id=kwargs['id'])
            except Match.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg=f'Wrong match id : {id}').json(),
                    content_type="application/json"
                    )

            if not (match.p1 == profile or match.p2 == profile):
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Permission denied').json(),
                    content_type="application/json"
                    )

            action = json_data['action']
            if action == 'accept':
                if match.p1 == profile:
                    match.p1accepted = True
                elif match.p2 == profile:
                    match.p2accepted = True
            elif action == 'remove':
                match.delete()
            else:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg=f'Unrecognized action: "{action}". Accepts: "accept" and "remove".').json(),
                    content_type="application/json"
                    )

            resp = {'message': f'Action: {action} successfull'}
            return HttpResponse(
                JsonResponse(status='success', data=resp).json(),
                content_type="application/json"
                )
        except Exception as e:
            print(e)

        return HttpResponse(
            JsonResponse(status='error', errorMsg="Error").json(),
        content_type="application/json"
            )


class PictureID(View):
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        if user is None:
            return HttpResponseBadRequest("Bad token")
        try:
            id = kwargs['id']
            profile = Profile.profiles.get(user=user)
            picture = Picture.pictures.get(id=id)

            relationShip = Profile.getRelationshipBetweenProfiles(profile, picture.profile)
            if relationShip is None:
                return HttpResponseForbidden("Not allowed")
            elif relationShip == 'proposition' or relationShip == 'match':
                buf = BytesIO()
                pictureData = base64.b64decode(picture.data.encode('utf-8'))
                buf.write(pictureData)
                im = Image.open(buf)
                blurred = im.filter(ImageFilter.GaussianBlur(30))
                buf = BytesIO()
                blurred.save(buf, "JPEG")
                print(buf.getbuffer().nbytes)
                return HttpResponse(buf.getvalue(), content_type='image/*')
            elif relationShip == 'accepted' or 'same':
                pictureData = base64.b64decode(picture.data.encode('utf-8'))
                return HttpResponse(pictureData, content_type='image/*')

        except Picture.DoesNotExist:
            return HttpResponseNotFound("Requested picture does not exists")
        except Profile.DoesNotExist:
            return HttpResponseNotFound("No profile created yet")

    def delete(self, request, *args, **kwargs):
        user = verifyToken(request)
        if user is None:
            return HttpResponse(
                JsonResponse(status='error', errorMsg='Bad token').json(),
                content_type:="application/json"
                )
        try:
            id = kwargs['id']
            profile = Profile.profiles.get(user=user)

            picture = Picture.pictures.get(id=id)
            if picture.profile != profile:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Requested picture does not exists').json(),
                    content_type:="application/json"
                    )

            picture.delete()

            return HttpResponse(
                JsonResponse(status='success').json(),
                content_type:="application/json"
                )

        except Picture.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Requested picture does not exists').json(),
                    content_type:="application/json"
                    )
        except Profile.DoesNotExist:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg='Profile not created yet').json(),
                    content_type:="application/json"
                    )


class Spotify:

    from threading import Lock

    redirectURI = "http://localhost:8081/api/spotify/callback"

    _spotify_oauth = {
        'name': 'spotify',
        'client_id': '7c83eb3d29784cd9bd9ef3e389d7e184',
        'client_secret': '68396e62993e4d1392a5eb7599e26af6',
        'scope': 'user-top-read',
        'token_endpoint': 'https://accounts.spotify.com/api/token',
        'authorize_url': 'https://accounts.spotify.com/authorize',
        'redirect_uri': redirectURI,
    }

    admin_refresh_token = ""
    admin_refresh_token_file = "/spotinder/spotinder_web/refresh.token"

    # hashmap des states vers user
    # utilisé pour l'auth seulement
    _users = {}

    _mutex = Lock()
    _oauth = OAuth()
    _oauth.register(**_spotify_oauth)

    def getAuthURL(user):
        try:
            session = Spotify._oauth.create_client('spotify')
            authorize = session.create_authorization_url(redirect_uri=Spotify.redirectURI)
            try:
                Spotify._mutex.acquire()
                Spotify._users[authorize['state']] = user
                toReturn = authorize['url']
            except Exception as e:
                print(e)
                toReturn = None

            finally:
                Spotify._mutex.release()

        except Exception as e:
            print(e)
            toReturn = None

        return toReturn

    def saveAccessToken(state, code):
        toReturn = False
        Spotify._mutex.acquire()
        try:
            session = Spotify._oauth.create_client('spotify')
            user = Spotify._users[state]
            token = session.fetch_access_token(grant_type='authorization_code', code=code)
            user.spotify_token = token['refresh_token']
            user.save()
            toReturn = True
        except Exception as e:
            print(e)
        finally:
            Spotify._mutex.release()

        return toReturn

    def getAccessToken(user):
        toReturn = None
        try:
            session = Spotify._oauth.create_client('spotify')
            token = session.fetch_access_token(grant_type='refresh_token', refresh_token=user.spotify_token)
            if 'refresh_token' in token:
                user.spotify_token = token['refresh_token']
                user.save()
            toReturn = token['access_token']
        except Exception as e:
            print("error")
            print(e)

        return toReturn

    def getAdminAccessToken():
        toReturn = None

        if len(Spotify.admin_refresh_token) == 0:
            try:
                with open(Spotify.admin_refresh_token_file, 'r') as f:
                    Spotify.admin_refresh_token = f.read().strip()
            except FileNotFoundError as e:
                print(f"File {Spotify.admin_refresh_token_file} not found")
                return toReturn

        try:
            session = Spotify._oauth.create_client('spotify')
            token = session.fetch_access_token(grant_type='refresh_token', refresh_token=Spotify.admin_refresh_token)

            if 'refresh_token' in token:
                Spotify.admin_refresh_token = token['refresh_token']
                with open(Spotify.admin_refresh_token_file, 'wt') as f:
                    f.write(Spotify.admin_refresh_token)
            toReturn = token['access_token']

        except Exception as e:
            print(e)

        return toReturn

    def getUserTopArtists(user):
        try:
            headers = {'Authorization': f'Bearer {Spotify.getAccessToken(user)}'}
            req = requests.get(
                "https://api.spotify.com/v1/me/top/artists",
                headers=headers
                )

            out = req.json()
            return out
        except Exception as e:
            print(e)
            return None

class MessengerView(View):
    def get(self, request, *args, **kwargs):
        user = verifyToken(request)
        try:
            if user is None:
                return HttpResponse(
                    JsonResponse(status='error', errorMsg="Bad token").json(),
                    content_type="application/json"
                    )
            userProfile = Profile.profiles.get(user=user)
            try:
                match = Match.matches.get(id=kwargs['id'])
            except Match.DoesNotExist:
                return HttpResponse(JsonResponse(status="error", errorMsg="Match id doesn't not exist").json())

            messagesQuerySet = Message.messages.filter(match=match).order_by('-id')[:30]
            if(len(messagesQuerySet) == 0):
                return HttpResponse(JsonResponse(status="success", errorMsg="no messages yet", data=None).json(),
                content_type="application/json"
                )
            data = []
            print(f"msg count = {messagesQuerySet.count()}")
            for msg in messagesQuerySet:
                data.append(msg.serialize(userProfile == msg.sender))
                if userProfile != msg.sender:   #if the requesting user is not the sender then it means that we're reading  
                    msg.isRead = True
                    msg.save()
            
            return HttpResponse(
                    JsonResponse(status='success', data=data).json(),
                    content_type="application/json"
                    )
        except Exception as e:
            print(e)
            return HttpResponse(JsonResponse(status='error', errorMsg='internal server error').json(),
                content_type="application/json"
            )
