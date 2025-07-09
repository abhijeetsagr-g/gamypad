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
SERVER = "0.0.0.0"
PORT = 5050

# Create virtual input device
server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Track connected IPs
connected_clients = set()
clients_lock = threading.Lock()

def handle_client(addr, conn):
    ip = addr[0]
    print(f"[NEW CONNECTION] {addr} connected")
    
    with clients_lock:
        connected_clients.add(ip)

    try:
        while True:
            msg_length = conn.recv(HEADER).decode(FORMAT).strip()
            if not msg_length:
                continue

            msg_length = int(msg_length)
            msg = conn.recv(msg_length).decode(FORMAT)
            data = json.loads(msg)

            if data.get("exit"):
                print(f"[DISCONNECT] {addr} requested exit")
                break
            else:
                binds.handle_keys(data)

    except Exception as e:
        print(f"[ERROR] {addr}: {e}")

    finally:
        conn.close()
        with clients_lock:
            connected_clients.discard(ip)
        print(f"[CONNECTION CLOSED] {addr}")

def start_server():
    print(f"[SERVER STARTED] Listening on {socket.gethostbyname(socket.gethostname())}:{PORT}")
    server.listen()

    while True:
        conn, addr = server.accept()
        ip = addr[0]

        with clients_lock:
            if ip in connected_clients:
                print(f"[REJECTED] {ip} already connected. Closing new connection.")
                conn.close()
                continue

        thread = threading.Thread(target=handle_client, args=(addr, conn))
        thread.start()
        print(f"[ACTIVE CONNECTIONS] {threading.active_count() - 1}")

def server_init(ADDR):
    server.bind(ADDR)

def main():
    server_init((SERVER, PORT))
    start_server()

main()
