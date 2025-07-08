import socket
import threading
import json
import binds
import os

# Constants
HEADER = 64
FORMAT = "utf-8"
EXIT_CODE = "100"

# Server setup
SERVER = socket.gethostbyname(socket.gethostname())
PORT = 5050

# Create virtual input device
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def handle_client(addr, conn):
    print(f"[NEW CONNECTION] {addr} connected")
    connected = True

    while connected:
        try:
            # Receive fixed-length header
            msg_length = conn.recv(HEADER).decode(FORMAT).strip()
            if not msg_length:
                continue

            msg_length = int(msg_length)

            # Receive actual JSON message
            msg = conn.recv(msg_length).decode(FORMAT)
            data = json.loads(msg)

            # Handle exit
            if data.get("exit"):
                print(f"[DISCONNECT] {addr} requested exit")
                break
            else:
                # Handle button press
                binds.handle_keys(data)
                
            

        except Exception as e:
            print(f"[ERROR] {addr}: {e}")
            break

    conn.close()
    print(f"[CONNECTION CLOSED] {addr}")

def start_server():
    print(f"[SERVER STARTED] Listening on {SERVER}:{PORT}")
    server.listen()

    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(addr, conn))
        thread.start()
        print(f"[ACTIVE CONNECTIONS] {threading.active_count() - 1}")

# Initialize server socket
def server_init(ADDR):
    server.bind(ADDR)

def main():
    server_init((SERVER, PORT))
    start_server() 

main()
