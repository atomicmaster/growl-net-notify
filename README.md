# growl-net-notify
Growl Notification for Weechat, now with GNTP

This can be used locally or even remotely if you are willing to set up an SSH tunnel.

Note 1: I have only currently tested this through socat in the following configuration:
Weechat -> Socat -> SSH Reverse Tunnel -> Socat -> Growl

Note 2: I am interested if i can forego the Socat and connect directly over a tunneled port. Will test later.

Note 3: All i currently know is that this loads, processes commands, and connects, i can also sent test messages through it, the rest of the weechat integration is currently under suspicion... 
