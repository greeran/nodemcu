local M={};
thinkspeak_ip = "69.172.201.153"

function M.postThingSpeak(temp,humi)
    
    connout = nil
    connout = net.createConnection(net.TCP, 0)
 
    connout:on("receive", function(connout, payloadout)
        if (string.find(payloadout, "Status: 200 OK") ~= nil) then
            print("Posted OK");
        end
    end)
 
    connout:on("connection", function(connout, payloadout)
        if(temp < 0) then
            print("Failed to get temp and Humidity\n")
        else 
            print ("Posting...");
     
            ---local volt = node.readvdd33();      
     
            connout:send("GET /update?api_key=61TUR14P6J0LX5OU&field1="..temp.."&field2="..humi.." HTTP/1.1\r\n"
            .. "Host: api.thingspeak.com\r\n"
            .. "Connection: close\r\n"
            .. "Accept: */*\r\n"
            .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
            .. "\r\n")
        end
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        node.dsleep(5 * 1000000)
    end)
 
    connout:connect(80,'api.thingspeak.com')

end

return M