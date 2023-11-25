#!/usr/bin/env python3
import cv2
import base64
import websockets
import asyncio
import requests
import json
import time
from datetime import datetime
baseUrl = "http://localhost:8081/api/"
global token
token = ""

def login(username, password):
    req = requests.post(baseUrl + "login", json={'username': username, 'password': password})
    parsedResp = req.json()
    print(req.json())
    if parsedResp['status'] == 'success':
        global token
        token = parsedResp['data']['token']
        return True
    return False

def register(username, password):
    req = requests.post(baseUrl + "register", json={'username': username, 'password': password})
    print(f"Register response: {req.json()}")

def get_self_profile():
    global token
    req = requests.get(baseUrl + "profile", headers={"Authorization": token})
    resp = req.json()
    print(resp)

def get_profile(id):
    global token
    req = requests.get(baseUrl + f"profile/{id}", headers={"Authorization": token})
    resp = req.json()
    print(resp)

def get_profiles():
    global token
    req = requests.get(baseUrl + "profiles", headers={"Authorization": token})
    resp = req.json()
    print(resp)

def post_profile():
    global token

    imgList = []

    img = cv2.imread('img/joconde.jpg')
    jpg_img = cv2.imencode('.jpg', img)
    b64_string = base64.b64encode(jpg_img[1]).decode('utf-8')
    imgList.append(b64_string)

    img = cv2.imread('img/david.jpg')
    jpg_img = cv2.imencode('.jpg', img)
    b64_string = base64.b64encode(jpg_img[1]).decode('utf-8')
    imgList.append(b64_string)

    req = requests.post(baseUrl + 'profile', json={
        'description': "Cherche fille vraiment facile",
        'localisation': "BE",
        'gender': "M",
        'surname': "Nathou",
        'dateOfBirth': "30/10/2004",
        'images': imgList
    },
                        headers={"Authorization": token}
                        )

    print(req.json())

def swipe(direction, profileid):
    global token
    req = requests.post(
        baseUrl + "swipe",
        json={'id': profileid, 'swipe': direction},
        headers={"Authorization": token}
        )
    print(req.json())

def matches():
    global token
    req = requests.get(
        baseUrl + "matches",
        headers={"Authorization": token}
        )
    print(req.json())

def get_match(id):
    global token
    req = requests.get(baseUrl + f"match/{id}", headers={"Authorization": token})
    print(req.json())

def spotify_disconnect():
    global token
    req = requests.post(baseUrl + "spotify/disconnect", headers={"Authorization": token})
    print(req.json())

def delete_picture(id):
    global token
    req = requests.delete(baseUrl + f"profile/picture/{id}", headers={"Authorization": token})

def download(url):
    global token
    req = requests.get(url, headers={"Authorization": token})
    print(req.headers)
    if req.status_code == 200:
        with open('download', 'wb') as f:
            f.write(req.content)

async def websock():
    global token
    uri = "ws://localhost:8081/ws/chat"
    async with websockets.connect(
            uri,
            extra_headers={"Authorization": token},
            ) as socket:
        time.sleep(5)
        while True:
            msg = input("Message?")
            await socket.send('{"matchID": "7",  "message": "'+msg+'"}')

            answer = await socket.recv()
            print("answer")
            print(answer)

def getMessages(url):
    global token
    req = requests.get(url, headers={"Authorization": token})
    print(req.headers)
    if req.status_code == 200:
        print(req.json())
    else:
        print("error")        

#register("basile", "123")
# login("basile", "123")
#login("willy", "123")
#login("nathan", "456")
print(datetime.now().strftime("%D %H:%M:%S"))
usr = int(input("user?"))
if usr == 1:
    login("nokhtcho", "123")
else :
    login("willy", "123")
# get_profiles()
#spotify_disconnect()
# ok = ""
# input(ok)
# delete_picture(1)

# if login("yooo", "macouille"):
# post_profile()
#get_profiles()
# get_self_profile()
    # swipe('right', 2)
#matches()
    # get_match(1)
#getMessages("http://localhost:8081/api/messenger/7")
asyncio.get_event_loop().run_until_complete(websock())
# await websock()
