from socket import *
import sys
import getopt
import time

def main(my_mac, your_ip):
    HOST = your_ip
    PORT = 21567
    BUFFSIZE = 1024
    ADDR = (HOST, PORT)

    tcpCliSock = socket(AF_INET, SOCK_STREAM)
    while True:
        try:
            tcpCliSock.connect(ADDR)
            break
        except:
            time.sleep(1)

    tcpCliSock.send(my_mac)
    data = tcpCliSock.recv(BUFFSIZE)
    print data.strip()
    tcpCliSock.close()


if __name__ == '__main__':
    opts, args = getopt.getopt(sys.argv[1:], 'i:m:')
    your_ip = ''
    my_mac = ''
    for opt, value in opts:
        if opt == '-i':
            your_ip = value
        elif opt == '-m':
            my_mac = value.strip()

    main(my_mac, your_ip)
