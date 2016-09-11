wifi.setmode(wifi.STATION);
wifi.sta.config("HOTBOX-AB72" ,"popohead103");
 
function postThingSpeak(level)
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
 
        print ("Posting...");
 
        ---local volt = node.readvdd33();      
 
        connout:send("GET /update?api_key=TDSIUAIBYW47OBCG&field1=3.3"
        .. " HTTP/1.1\r\n"
        .. "Host: api.thingspeak.com\r\n"
        .. "Connection: close\r\n"
        .. "Accept: */*\r\n"
        .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
        .. "\r\n")
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')
end
 
tmr.alarm(1, 3000, 1, function() postThingSpeak(0) end)
