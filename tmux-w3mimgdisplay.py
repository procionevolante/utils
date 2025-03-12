#!/usr/bin/env python3

'''
A script that displays images in w3m when it is started on a tmux panel.

w3m supports showing images on the cmdline by using `w3mimgdisplay`, a C
program which has its own proprietary protocol.

The program doesn't work on tmux natively because the escape sequences it emits
are not understood by tmux.
To get around this, the user has to enable `allow-passthrough` in tmux to send
escape sequences to tmux in a special format to tell it to forward them
directly to the underlying terminal.
'''

# w3mimgdisplay "user" options (from w3m-img/README.img)
# (w3m will not use these unless you change the display program invocation)
#
# "w3mimgdisplay" has the following options. Set options to fit terminal.
#
# -x <offset_x>
#     The X origin of display of image on terminal. The default value
#     for X11 is 2.
#     If the terminal is "xterm", the width of scroll bar is added.
#     If the terminal is "Eterm", it may be better to specify 5.
#     The default value for Linux framebuffer device is 0.
# -y <offset_y>
#     The Y origin of display of image on terminal. The default value
#     for X11 is 2.
#     If the terminal is "Eterm", it may be better to specify 5.
#     The default value for Linux framebuffer device is 0.
# -bg <background>
#     Background color of terminal. The default value for X11 is
#     automatically detected.
#     The default value for Linux framebuffer device is #000000 (black).
#     When the color is specified as #RRGGBB, escape '#'.
# -anim <n>
#     Maximum number of frames for animation. It will run everything
#     if the number is 0. Negative values count backward from the end
#     of the frames. The default value is 100.
# -margin <n>
#     Margin of an area to clear an image. The default value is 0.

# w3mimgdisplay options used by w3m:
# -test         Report terminal window resolution (pixels)
# -size <f>     Get size of image f (pixels)
# -debug        Do not redirect stderr to /dev/null


# The w3mimg protocol is defined in its source code:
#  w3mimg protocol
#   0  1  2 ....
#  +--+--+--+--+ ...... +--+--+
#  |op|; |args             |\n|
#  +--+--+--+--+ .......+--+--+
#
#  args is separated by ';'
#  op   args
#   0;  params          draw image
#   1;  params          redraw image
#   2;  -none-          terminate drawing
#   3;  -none-          sync drawing
#   4;  -none-          nop, sync communication
#                       response '\n'
#   5;  path            get size of image,
#                       response "<width> <height>\n"
#   6;  params(6)       clear image
#
#  params
#       <n>;<x>;<y>;<w>;<h>;<sx>;<sy>;<sw>;<sh>;<path>
#  params(6)
#       <x>;<y>;<w>;<h>

# TODO
