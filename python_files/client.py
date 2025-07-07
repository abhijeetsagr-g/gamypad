import socket
import json

HEADER = 64
FORMAT = "utf-8"
EXIT_CODE = "100"

SERVER = '127.0.0.1'
PORT = 5050
ADDR = (SERVER, PORT)

client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def send(data: dict):
    msg = json.dumps(data).encode(FORMAT)
    msg_length = len(msg)
    send_length = str(msg_length).encode(FORMAT)
    send_length += b' ' * (HEADER - len(send_length))
    client.send(send_length)
    client.send(msg)    

def connect():
    client.connect(ADDR)
    connected = True
    while connected:
        msg = input("Enter button (or 100 to exit): ").strip().upper()
        if msg == EXIT_CODE:
            send({"exit": True})
            connected = False
        else:
            send({"btn": msg, "action": "pressed"})

    client.close()

connect()
