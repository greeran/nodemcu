pin = 5
thinkspeak_ip = "69.172.201.153"
--192.168.1.26"

function getTemp()
    status,temp,humi,temp_decimial,humi_decimial = dht.read11(pin)
    if( status == dht.OK ) then
      -- Integer firmware using this example
      print(
        string.format(
          "in function DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
          math.floor(temp),
          temp_decimial,
          math.floor(humi),
          humi_decimial
        )
      )
      -- Float firmware using this example
      print("floating DHT Temperature:"..temp..";".."Humidity:"..humi)
    elseif( status == dht.ERROR_CHECKSUM ) then
      print( "DHT Checksum error." );
    elseif( status == dht.ERROR_TIMEOUT ) then
      print( "DHT Time out." );
    end
end

function postThingSpeak(level)
    getTemp();
   
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
        ---collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')

end

function preStart(ssid, password)
    
end
--sendData();
-- send data every X ms to thing speak
print("starting my init file")
wifi.setmode(wifi.STATION)
wifi.startsmart(0,
    function(ssid,password) 
        print(string.format("Success. SSID:%s ; PASSWORD:%s start the dht func", ssid, password))
        mytimer = tmr.alarm(2, 30000, 1, function() postThingSpeak(0) end )
    end
)
