print("starting my init file")

local confUtil=require("confUtil.lua")
local getDht11=require("getDht11.lua")
local postTemp=require("postThingspeak.lua")

local lpassw=""
local lssid=""

if false == confUtil.getPassw(lpassw,lssid) then
    print("waiting for ssid and password")
    wifi.setmode(wifi.STATION)
    wifi.startsmart(0,
        function(lssid,lpassw) 
            print(string.format("Success. SSID:%s ; PASSWORD:%s start the dht func", lssid, lpassw))
			confUtil.savePassw(lssid,lpassw)
        end
    )

end
temp,humi=getDht11.getTemp()
---mytimer = tmr.alarm(2, 30000, 1, function() postThingSpeak(0) end )
postTemp.postThingSpeak(temp,humi)
