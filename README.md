
# :iphone: Spotinder
Spotinder is a mobile app that allows users to find each other by their musical preferences!

![image](https://user-images.githubusercontent.com/99261514/212739622-595c775f-c092-42aa-b6c1-d640a0be650e.png)

# General

Spotinder is a kind of Tinder but it uses the spotify data of the logged-in user to find potential matches but without showing the profile photos.
When 2 users match (based only on musical preferences and profile description) they can then chat.
Once the users have matched, they can decide to exchange photos (unblurred).

## Features

### :construction_worker: `Login`

1.  When the user logs in for the first time, they are sent to the spotify page to authenticate themselves.
2.  Once Spotify authentication is complete, they will be redirected to the profile editing page, where they can create and adapt their profile.

![image](https://user-images.githubusercontent.com/99261514/212743666-327ecd01-28f6-492a-a533-b25b243e7b66.png)

### :telescope: `Match search`

1.  Like Tinder, profiles are displayed, except that here we have a ‘Match’ coefficient. In other words, how closely the data from their respective Spotify accounts matches. 
2.  You can either swipe left or right, or press the buttons underneath. 
3.  If you swipe right and there is a match, it appears in the matches.
4.  Blurred profile photos are displayed, if the user has not uploaded any photos then a default photo of Itachi will be used.

![image](https://user-images.githubusercontent.com/99261514/212743996-298689a0-91a2-4af1-ab16-cd71f995c9d8.png)

### :raised_hands: `Matches`

1.  On the messaging page, users can see all their Matches and correspond with them.
2.  They can decide to send a photo exchange request, i.e. to accept that the other person can see their unblurred photos.
3.  Technology used: WebSockets

![image](https://user-images.githubusercontent.com/99261514/212744828-054da2e4-d727-43a1-9243-57d4a9736a8f.png)

Matches page 

![image](https://user-images.githubusercontent.com/99261514/212744919-b75b7679-58a9-4f3e-b322-4d79b6ba0a2a.png)

Messenger

![image](https://user-images.githubusercontent.com/99261514/212745036-a0136b0a-ab66-495f-bb9f-e82c9dae6753.png)

Match profile page (with exchange request).

# Some GIFs to illustrate...


## `Login`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/login.gif)


## `Swipes`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/swipe.gif)

## `Matchs`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/chat.gif)

## Exchange request

![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/sharePics.gif)

# Server description

REST API

All requests (except login and register) must have the authentication token in the Authorization header


## `/login`

-   POST  
    
            - Request = {
            'username': String,
            'password': String
        }
            - Response = {
            'status': 'success'/'error',
            'error_msg': NULL/String,
        	'data': {
        		    'token': String/NULL,
        		    'needSpotifyToken': True/False,
        	}
        }


## `/register`

-   POST  
    
            - Request = {
            'username': String,
            'password: String
        }
            - Response = {
            'status': 'success'/'error',
            'error_msg': NULL/String
        }


## `/spotify/token`


= RedirectURI  


## `/profile`

Update profile

-   PATCH

        - Request = {
    	    'description': String,
    	    'localisation': Char[2] (Country code),
    	    'image: [
    		    1: String base64 (image),
    		    ...
    	    ]
    }
        - Response = {
    	    'status': 'success'/'error',
    	    '=error_msg=': NULL/String
    }

Get information about yourself
-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String
    	    'description': String,
    	    'localisation': Char[2] (Country code),
    	    'image: [
    		    1: String base64 (image),
    		    ...
    	    ]
    }


## `/profile/{ID}`

Get information about a certain user

-   GET

    - Response = {
    	'status': 'success'/'error' (error if not matched),
    	'error_msg': NULL/String
    	'data': {
    		'description': 'Cherche fille facile',
    		'localisation': 'FR',
    		'images': [{'data': base64encodedimage}, ...]
    	}
    }


## `/profiles`

Get potential matches

-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String
    	    'data': [
    		    'profile': {
    			    {...}
    		    }
    	    ]
    }


## `/swipe`

Register a swipe

-   POST

        - Request = {
    	    'id': String, (id du profile)
    	    'swipe': 'left'/'right'
    }
        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'data': {
    		    'match': True/False
    	    }
    }


## `/match/{ID}`

Get information about a match

-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'data': {
    		    'match': String/NULL,
    		    'profile': String/NULL,
    		    'this.accepted': True/False,
    		    'other.accepted': True/False,
    	    }
    }

Accept or delete a match  

-   POST

        - Request = {
    	    'action': 'accept'/'remove'
    }
        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'data': {
    		    'message': String
    	    }
    }


## `/matchs`

Get the list of all matches  

-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'data': [
    		    ...
    	    ]
    }


## `/messages/{matchID}`

Get messages exchanged with a match   

-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'match': String,
    	    'messages: [
    		    1 : {
    			    'id': String,
    			    'timestamp': String,
    			    'sent': True/False
    			    'content': String
    		    },
    
    		    2: {...}, ...
    	    ]
    }


## `/message/${ID}`

Info about a message  

-   GET

        - Request = {
    	    'token': String
    }
        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'match': String,
    	    'messages: {
    		    'id': String,
    		    'timestamp': String,
    		    'sent': True/False
    		    'content': String
    	    }
    }


## `/message/send`

Send a message to a match  

-   POST  
    
            - Request = {
            'token': String,
            'match': String,
            'content': String
        }
            - Response = {
            'status': 'success'/'error',
            'error_msg': NULL/String,
            'timestamp': String
        }

