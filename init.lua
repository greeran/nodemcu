local dht11obj =require("getDht11")

thinkspeak_ip = "69.172.201.153"
--192.168.1.26"
conf_ssid = nil --- "HOTBOX-AB72" ---nil
conf_password = nil --- "popohead103" --nil

dht11obj.getTemp();

local FileToExecute="mywifi.lua"
if file.exists(FileToExecute) then
  print("found file")
  dofile(FileToExecute)
end

print("starting my init file")
---wifi.sleeptype(wifi.LIGHT_SLEEP) 


wifi.setmode(wifi.STATION)

if conf_ssid == nil then
    print("waiting for ssid and password 4")
    ---wifi.setmode(wifi.STATION)
    wifi.startsmart(0,
        function(ssid,password) 
            print(string.format("Success. SSID:%s ; PASSWORD:%s start the dht func", ssid, password))
            file.open(FileToExecute,"w+")
            file.writeline("conf_ssid=\""..ssid.."\"")
            file.writeline("conf_password=\""..password.."\"")
            file.close()
            dofile("WebServer.lua")
        end
    )
else
    wifi.sta.config(conf_ssid,conf_password)
    print("we are already connected ssid-"..conf_ssid.." password-"..conf_password)
    
    --- ran test
    ---dofile("sendGmail.lua")
    dofile("WebServer.lua")
    
    ---  uncomment--- postThingSpeak(0)
     ---- ---- tmr.alarm(1, 6000, 1, function() postThingSpeak(0) end)
    -- tmr.alarm(1, 6000, 1, function() getTemp() end)
    --- end ran test 
end
