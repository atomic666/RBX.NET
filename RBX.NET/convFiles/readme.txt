Place the files onto your webserver and execute the following commands:

sudo apt-get install python
sudo apt-get install python-pip
pip install cfscrape

After your're done with that replace convUrl in script.lua with your webserver's conv.php path. Example: https://server.com/conv.php
and you're all set for bypassing cloudflare's under attack mode.