import sys
import os
from ctypes import *

#TODO: inherit CDLL
class RelpEngine(object):
    def __init__(self):
        relp_lib = os.path.realpath(__file__ + '/../../relp.so')
        self.lib = cdll.LoadLibrary(relp_lib)
        self.engine = c_void_p()
        self.timeout = 90
        self.protFamily = 2  # IPv4=2, IPv6=10

    def setup(self):
        if self.lib.relpEngineConstruct(byref(self.engine)) != 0:
            raise Exception("Failed to construct relp engine.")

        if self.lib.relpEngineSetDbgprint(self.engine, c_void_p()) != 0:
            raise Exception("Failed to set debug print function.")

        if self.lib.relpEngineSetEnableCmd(self.engine, create_string_buffer(b"syslog"), 3) != 0:
            raise Exception("Failed to enable syslog.")


class Client(RelpEngine):
    def __init__(self, target="127.0.0.1", port="514"):
        super(Client, self).__init__()
        self.__client = c_void_p()
        self.__target = target
        self.__port= port
        self.__setup()
        self.__connect()

    def __setup(self):
        super(Client, self).setup()

        if self.lib.relpEngineCltConstruct(self.engine, byref(self.__client)) != 0:
            raise Exception("Failed to construct relp client.")

        if self.lib.relpCltSetTimeout(self.__client, self.timeout) != 0:
            raise Exception("Failed to set client timeout.")

    def __connect(self):
        port_p = create_string_buffer(self.__port.encode())
        target_p = create_string_buffer(self.__target.encode())

        if self.lib.relpCltConnect(self.__client, self.protFamily, port_p, target_p, 3) != 0:
            raise Exception("Failed to connect to target: %s on port %s." %
                    (self.__target, self.__port))

    def __teardown(self):
        raise NotImplemented

    def send(self, msg):
        msg_p = create_string_buffer(msg.encode())
        if self.lib.relpCltSendSyslog(self.__client, msg_p, sizeof(msg_p)) != 0:
            raise Exception("Failed to send message: %s" % msg)


class Server(RelpEngine):
    def __init__(self, port="514", callback=None):
        """
        The callback takes 3 parameters: hostname, ip, msg
        """
        super(Server, self).__init__()
        self.__server = c_void_p()
        self.__port = port
        self.__run_once = False
        self.__user_callback = callback
        self.__callback = self.__create_callback()
        self.__setup()

    def __create_callback(self):
         RCV_FUNC = CFUNCTYPE(c_int, c_char_p, c_char_p, c_char_p, c_size_t)
         return RCV_FUNC(self.__receive)

    def __setup(self):
        super(Server, self).setup()

        if self.lib.relpEngineSetFamily(self.engine, self.protFamily) != 0:
            raise Exception("Failed to set IP protocol family.")

        if self.lib.relpEngineSetSyslogRcv(self.engine, self.__callback) != 0:
            raise Exception("Failed to set callback.")

        if self.lib.relpEngineSetDnsLookupMode(self.engine, 0) != 0:
            raise Exception("Failed to disable DNS lookup.")

        if self.lib.relpEngineListnerConstruct(self.engine, byref(self.__server)) != 0:
            raise Exception("Failed to create server instance.")

        port_p = create_string_buffer(str(self.__port).encode())
        if self.lib.relpSrvSetLstnPort(self.__server, port_p) != 0:
            raise Exception("Failed to set port.")

        if self.lib.relpEngineListnerConstructFinalize(self.engine, self.__server) != 0:
            raise Exception("Failed to set port.")

    def __receive(self, hostname, ip, msg, lenMsg):
        if self.__user_callback:
            self.__user_callback(hostname, ip, msg[:lenMsg])
        return 0

    def __teardown(self):
        raise NotImplemented

    def run(self):
        self.lib.relpEngineRun(self.engine)

    def stop(self):
        if self.lib.relpEngineSetStop(self.engine) != 0:
            raise Exception("Failed to stop server.")

