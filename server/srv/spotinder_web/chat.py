from channels.consumer import SyncConsumer
from channels.exceptions import StopConsumer
from urllib.parse import parse_qsl

from spotinder.wsgi import *
from spotinder_web.views import *
from spotinder_web.models import *
from datetime import datetime

class ChatConsumer(SyncConsumer):
    def __init__(self):
        super().__init__()
        self.username = None

    def authenticate(self):
        token = None

        # search in headers
        headers = self.scope['headers']
        for h in headers:
            if h[0].decode('utf-8').lower() == "Authorization".lower():
                token = h[1].decode('utf-8')

        # search in query parameters
        if token is None:
            params = parse_qsl(self.scope['query_string'].decode('utf-8'))
            try:
                if params[0][0] == 'authorization':
                    token = params[0][1]
            except:
                pass

        if token is None:
            return None

        user = verifyStrToken(token)
        if user is not None:
            self.username = user.username

        return user


    def websocket_connect(self, event):
        try:
            user = self.authenticate()
            if user is None:
                self.send({
                    "type": "websocket.close",
                })
            else :
                self.username = user.username
                ChatContainer.addConnection(self.username, self)
                self.send({
                    "type": "websocket.accept",
                })

        except Exception as e:
            print(e)
            self.send({
                "type": "websocket.close",
            })

    def websocket_receive(self, event):
        user = self.authenticate()

        json_data = json.loads(event['text'])

        try:
            dstMatch = Match.matches.get(id=json_data['matchID'])
        except Match.DoesNotExist:
            print("Match does not exist")
            return

        msg = Message(match=dstMatch, sender=Profile.profiles.get(user=user), content=json_data['message'])
        msg.save()
        
        dstUser = self.getDstUser(user, dstMatch) #check if SENDER is one of the two profiles in match
        if dstUser is None:
            dstSocket.send({
                "type": "websocket.send",
                "text": "Not allowed"
            })

        dstSocket = ChatContainer.findConsumerByName(dstUser.username)
        if(dstSocket is not None):
            response = {
                'matchID': dstMatch.id,
                'message': msg.serialize(False)
            }
            dstSocket.send({
                "type": "websocket.send",
                "text": json.dumps(response)
            })

    def getDstUser(self, user, dstMatch):
        if(user == dstMatch.p1.user):
            return dstMatch.p2.user
        elif user == dstMatch.p2.user:
            return dstMatch.p1.user
        else:
            return None

    def websocket_disconnect(self, event):
        try:
            ChatContainer.removeConnection(self.username)
        except:
            pass
        #https://channels.readthedocs.io/en/latest/topics/consumers.html?highlight=websocket.disconnect#closing-consumers
        raise StopConsumer


class ChatContainer:
    openWebSockets = {}

    def addConnection (username, consumerObj):
        ChatContainer.openWebSockets[username] = consumerObj

    def removeConnection(username):
        print(ChatContainer.openWebSockets)
        del ChatContainer.openWebSockets[username]

    def findConsumerByName(username):
        print(ChatContainer.openWebSockets)
        try:
             return ChatContainer.openWebSockets.get(username)
        except KeyError:
            return None
