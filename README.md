
# :iphone: Spotinder
Spotinder is a mobile app that allows users to find each other by their musical preferences!

![image](https://user-images.githubusercontent.com/99261514/212739622-595c775f-c092-42aa-b6c1-d640a0be650e.png)

# Déroulement général

Spotinder est un genre de Tinder mais qui utilise les données de spotify de l&rsquo;utilisateur loggé pour trouver d&rsquo;éventuels match mais sans montrer les photos du profile.  
Lorsque 2 utilisateurs matchent (seulement sur base des préférences musicales et de la description du profile) il peuvent alors chatter.  
Les utilsateurs ayant matché, ils peuvent alors décider de s'échanger les photos (non floutées)  

## Fonctionnalités

### :construction_worker: `Login`

1.  Lors du premier Login, l'utilisateur est renvoyé vers la page de spotify pour s'y authentifier
2.  Une fois l'authentification Spotify terminée, il sera redirigé vers la page d'édition de profil, ainsi il pourra créer et adapter son profil

![image](https://user-images.githubusercontent.com/99261514/212743666-327ecd01-28f6-492a-a533-b25b243e7b66.png)

### :telescope: `Recherche de personnes`

1.  A l'image de Tinder, des profils sont affichés sauf qu'ici on a un coefficient de "Match". C'est à dire, à quel point les données issues de leurs comptes Spotify respectifs correspondent. 
2.  On peut soit swiper à droite ou à gauche, soit appuyer sur les boutons en dessous 
3.  Si on swipe à droite et qu&rsquo;il y a match, il apparaît dans les matchs
4.  Les photos de profils floutées sont affichées, si l'utilisateur n'a pas uploadé de photos, alors une photo par défaut de Itachi sera utilisée.

![image](https://user-images.githubusercontent.com/99261514/212743996-298689a0-91a2-4af1-ab16-cd71f995c9d8.png)

### :raised_hands: `Matches`

1.  Sur la page de messagerie, l'utilisateur peut voir tous ses Matchs et correspondre avec ceux-ci.
2.  Il peut décider de lui envoyer une requête d'échange de photos, c'est à dire d'accepter que la personne en face puisse voir ses photos non floutées.
3.  Technologie utilisée : WebSockets

![image](https://user-images.githubusercontent.com/99261514/212744828-054da2e4-d727-43a1-9243-57d4a9736a8f.png)

Pages de matches 

![image](https://user-images.githubusercontent.com/99261514/212744919-b75b7679-58a9-4f3e-b322-4d79b6ba0a2a.png)

Page de messagerie 

![image](https://user-images.githubusercontent.com/99261514/212745036-a0136b0a-ab66-495f-bb9f-e82c9dae6753.png)

Page de profil du match (Avec requete d'échange).


# Quelques Gifs pour mieux illustrer...


## `Login`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/login.gif)


## `Swipes`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/swipe.gif)

## `Matchs`
![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/chat.gif)

## Requete d'échange

![](https://github.com/tecg-dam-2022-2023/examen_dam-colinet-nathan-oumarov-nokhtcho/blob/main/gifs/sharePics.gif)

# Description du serveur

C&rsquo;est un serveur avec REST API (requête HTTP avec payload en JSON)  

Toutes les requetes (sauf login et register) doivent avoir le token d&rsquo;authentification dans le header &ldquo;Authorization&rdquo;.  


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

Nous pensons que le mieux c&rsquo;est que ce soit le serveur qui fasse toutes les requêtes pour spotify. Comme ça tout et centralisé.  

= RedirectURI  


## `/profile`

Permet de modifier son profile  

-   POST

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

Permet d&rsquo;obtenir les infos sur son propre profile  

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

Permet d&rsquo;obtenir les info sur un profile donné  

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

Permet d&rsquo;obtenir les potentiels match  

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

Permet d&rsquo;envoyer le résultat d&rsquo;un swipe  

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

Permet d&rsquo;obtenir les infos sur un match  

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

Permet de retirer ou d&rsquo;accepter un match  

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

Permet d&rsquo;obtenir la liste des matchs d&rsquo;un utilisateur  

-   GET

        - Response = {
    	    'status': 'success'/'error',
    	    'error_msg': NULL/String,
    	    'data': [
    		    ...
    	    ]
    }


## `/messages/{matchID}`

Permet d&rsquo;obtenir tous les messages échangés avec un match.  

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

Obtenir les infos sur un message  

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

Envoyer un message à un match  

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

