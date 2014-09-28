import sys
import os
from ctypes import *


#TODO: inherit CDLL
class Client(object):
    def __init__(self, target="127.0.0.1", port="514"):
        relp_lib = os.path.realpath(__file__ + '/../../relp.so')
        self.__lib = cdll.LoadLibrary(relp_lib)
        self.__engine = c_void_p()
        self.__client = c_void_p()
        self.__target = target
        self.__port= port
        self.__timeout = 90
        self.__protFamily = 2  # IPv4=2, IPv6=10
        self.__setup()
        self.__connect()

    def __setup(self):
        if self.__lib.relpEngineConstruct(byref(self.__engine)) != 0:
            raise Exception("Failed to construct relp engine.")

        if self.__lib.relpEngineSetDbgprint(self.__engine, c_void_p()) != 0:
            raise Exception("Failed to set debug print function.")

        if self.__lib.relpEngineSetEnableCmd(self.__engine, create_string_buffer(b"syslog"), 3) != 0:
            raise Exception("Failed to enable syslog.")

        if self.__lib.relpEngineCltConstruct(self.__engine, byref(self.__client)) != 0:
            raise Exception("Failed to construct relp client.")

        if self.__lib.relpCltSetTimeout(self.__client, self.__timeout) != 0:
            raise Exception("Failed to set client timeout.")

    def __connect(self):
        target_p = create_string_buffer(self.__port.encode())
        port_p = create_string_buffer(self.__target.encode())

        if self.__lib.relpCltConnect(self.__client, self.__protFamily, target_p, port_p, 3) != 0:
            raise Exception("Failed to connect to target: %s on port %s." %
                    (self.__target, self.__port))

    def __teardown(self):
        raise NotImplemented

    def send(self, msg):
        msg_p = create_string_buffer(msg.encode())
        if self.__lib.relpCltSendSyslog(self.__client, msg_p, sizeof(msg_p)) != 0:
            raise Exception("Failed to send message: %s" % msg)

