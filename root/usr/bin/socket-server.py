#!/usr/bin/python

import SocketServer
import socket
from subprocess import call

class MyTCPHandler(SocketServer.StreamRequestHandler):
    """
    The request handler class for our server.

    It is instantiated once per connection to the server, and must
    override the handle() method to implement communication to the
    client.
    """

    def handle(self):
        # self.rfile is a file-like object created by the handler;
        # we can now use e.g. readline() instead of raw recv() calls
        self.data = self.rfile.readline().strip()
        words = self.data.split()
        commands = set(["start", "stop"])
        if words[0].lower() in commands:
            print "Proper command"
            if words[0].lower() == 'stop':
                call(["s6-svc", "-d", "/var/run/s6/services/transmission"])
                call(["killall", "-SIGKILL", "transmission-daemon"])
                print "Stopped Transmission"
                self.wfile.write("Stopped Transmission")
            else:
                try:
                    newip = words[1]
                    socket.inet_aton(words[1])
                    print "Legal IP number"
                    if words[0].lower() == 'start':
                        call(["s6-svc", "-d", "/var/run/s6/services/transmission"])
                        call(["killall", "-SIGKILL", "transmission-daemon"])
                        call(['sed -i "s/\\"bind-address-ipv4\\": \(.*\)/\\"bind-address-ipv4\\": \\"'+newip+'\\",/g" /config/settings.json'], shell=True)
                        call(["s6-svc", "-u", "/var/run/s6/services/transmission"])
                        print "Updated Transmission"
                        self.wfile.write("Updated Transmission")
                except socket.error:
                    print "Not a legal IP number"
        else:
            print "Not a proper command"

if __name__ == "__main__":
    var_filename = '/etc/socket-server-variables.txt'

    def getVarFromFile(filename):
        import imp
        f = open(filename)
        global var_data
        var_data = imp.load_source('var_data', '', f)
        f.close()

    getVarFromFile(var_filename)


    # Create the server, binding to localhost on port 9999
    server = SocketServer.TCPServer((var_data.host, var_data.port), MyTCPHandler)

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
