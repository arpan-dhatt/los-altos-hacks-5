import gps

gps.connect()

packet = gps.get_current()

print(type(packet.position()))
