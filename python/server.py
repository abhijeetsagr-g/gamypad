import binds
import json
import os
import socket
import threading

# Constants
HEADER = 64
FORMAT = "utf-8"
EXIT_CODE = "EXIT"

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def main():

    SERVER_IP = get_local_ip()
    PORT = 5050

    server.bind((SERVER_IP, PORT))
    start_server()


def start_server():
    server.listen()
    socketname = server.getsockname()
    print(f"[SERVER] CONNECT TO {socketname[0]}:{socketname[1]}")

    while True:
        conn, addr = server.accept()
        
        print(f"{addr} : NEW CONNECTION")
        receive_data(conn, addr)
        conn.close() 


def receive_data(conn, addr):
    try:
        connected = True
        while connected:
            msg_length = conn.recv(HEADER).decode(FORMAT).strip()
            if not msg_length:
                continue

            msg_length = int(msg_length)
            msg = conn.recv(msg_length).decode(FORMAT)
            data = json.loads(msg)
            
            if data.get(EXIT_CODE):
                print(f"{addr} Requested to leave")
                break
            else:
                binds.handle_keys(data)

    except Exception as e:
        print(f"[ERROR] {e}")

    finally:
        conn.close()
        print(f"[CONNECTION CLOSED] {addr}")

# return the local ip of the system
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        return s.getsockname()[0]
    finally:
        s.close()

main()