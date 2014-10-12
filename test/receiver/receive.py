from pyrelp import pyrelp

def rcv(h, ip, msg):
    with open('/rsyslog/rsyslog.log', 'w') as f:
        f.write(msg)

s = pyrelp.Server(20514, rcv)
s.run()
