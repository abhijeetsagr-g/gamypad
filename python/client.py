import socket

# Constants
HEADER = 64
FORMAT = "utf-8"
EXIT_CODE = "EXIT"


client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

def main():

    SERVER_IP = "192.168.1.6"
    PORT = 5050

    msg = "SK"
    
    client.connect((SERVER_IP, PORT))
    send(msg)
        

def send(msg):
    message = msg.encode(FORMAT)
    client.send(message)
    client.close()

main()