from SocketServer import (TCPServer as TCP, StreamRequestHandler as SRH)
from socket import *
import getopt
import sys


def main(mac):
    HOST = ''
    PORT = 21567
    BUFFSIZE = 1024
    ADDR = (HOST, PORT)

    tcpSer = socket(AF_INET, SOCK_STREAM)
    tcpSer.bind(ADDR)
    tcpSer.listen(5)

    tcpCli, addr = tcpSer.accept()
    data = tcpCli.recv(BUFFSIZE)
    print data
    tcpCli.send(mac)
    tcpCli.close()
    tcpSer.close()


if __name__ == '__main__':
    opts, args = getopt.getopt(sys.argv[1:], 'i:m:')
    my_mac = ''
    for opt, value in opts:
        if opt == '-m':
            my_mac = value.strip()

    main(my_mac)

# class MyRequestHandler(SRH):
#     def handle(self):
#         print 'connetced from ', self.client_address
#         print self.rfile.readline()
#         self.wfile.write(self.rfile.readline())
#
#
# tcpServ = TCP(ADDR, MyRequestHandler)
# tcpServ.serve_forever()
