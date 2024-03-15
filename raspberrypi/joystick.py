# Released by rdb under the Unlicense (unlicense.org)
# Based on information from:
# https://www.kernel.org/doc/Documentation/input/joystick-api.txt

import os, struct, array, time
from fcntl import ioctl

import lgpio

h = lgpio.gpiochip_open(0)
lgpio.gpio_claim_output(h, 26)
lgpio.gpio_claim_output(h, 19)
lgpio.gpio_claim_output(h, 13)

# Iterate over the joystick devices.
print('Available devices:')

for fn in os.listdir('/dev/input'):
    if fn.startswith('js'):
        print('  /dev/input/%s' % (fn))

# We'll store the states here.
axis_states = {}

axis_names = {
    0x00 : 'roll',
    0x01 : 'pitch',
    0x02 : 'throttle'
}

axis_map = []

# Open the joystick device.
fn = '/dev/input/js0'
print('Opening %s...' % fn)
jsdev = open(fn, 'rb')

# Get the device name.
#buf = bytearray(63)
buf = array.array('B', [0] * 64)
ioctl(jsdev, 0x80006a13 + (0x10000 * len(buf)), buf) # JSIOCGNAME(len)
js_name = buf.tobytes().rstrip(b'\x00').decode('utf-8')
print('Device name: %s' % js_name)

# Get number of axes and buttons.
buf = array.array('B', [0])
ioctl(jsdev, 0x80016a11, buf) # JSIOCGAXES
num_axes = buf[0]

# Get the axis map.
buf = array.array('B', [0] * 0x40)
ioctl(jsdev, 0x80406a32, buf) # JSIOCGAXMAP

for axis in buf[:num_axes]:
    axis_name = axis_names.get(axis, 'unknown(0x%02x)' % axis)
    axis_map.append(axis_name)
    axis_states[axis_name] = 0.0

print('%d axes found: %s' % (num_axes, ', '.join(axis_map)))

time_last_output = 0

# Main event loop
while True:
    evbuf = jsdev.read(8)
    if evbuf:
        _time, value, type, number = struct.unpack('IhBB', evbuf)

        if type & 0x02:
            axis = axis_map[number]
            if axis:
                fvalue = value / 32767.0
                axis_states[axis] = fvalue

    if (time.time_ns() - time_last_output > 0.1*1000000000):
        print("Throttle", axis_states["throttle"], "%")
        bits = "{:04b}".format(int((axis_states["throttle"]+1)*5))
        lgpio.gpio_write(h, 26, bits[0] == "1")
        lgpio.gpio_write(h, 19, bits[1] == "1")
        lgpio.gpio_write(h, 13, bits[2] == "1")
        print("Pitch", axis_states["pitch"])
        print("Roll", axis_states["roll"])
        time_last_output = time.time_ns()
