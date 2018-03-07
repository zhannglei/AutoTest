import socket
import getopt
import sys


def main(ip, cmd):
    HOST = ip
    PORT = 12345
    SIZE = 1024
    ADDR = (HOST, PORT)
    cli = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    cli.connect(ADDR)
    cli.sendall(cmd)
    data = cli.recv(SIZE)
    print(data)
    cli.close()


if __name__ == '__main__':
    opts, args = getopt.getopt(sys.argv[1:], 'c:i:')
    for opt, value in opts:
        if opt == '-c':
            cmd = value
        elif opt == '-i':
            ip = value

    main(ip, cmd)