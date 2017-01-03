local thinkspeakLoop={}

local pin = 4
local thinkspeak_ip = "69.172.201.153"
local maxtmp,mintmp,maxhmd,minhmd,toEmail
local counter=0
local MAX_INTERVALS=2
local tempAvg=0
local humiAvg=0
local loopTimer=tmr.create()

local sendGmailObj =require("sendGmail")

function getTemp()
    print("getting temp on pin "..pin);
    status,temp,humi,temp_decimial,humi_decimial = dht.read11(pin)
    if( status == dht.OK ) then
      -- Integer firmware using this example
      print(
        string.format(
          "in function DHT (pin %d) Temperature:%d.%03d;Humidity:%d.%03d\r\n",
          pin,
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

function postThingSpeak(temprature, humidity)
   
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
     
            connout:send("GET /update?api_key=61TUR14P6J0LX5OU&field1="..temprature.."&field2="..humidity.." HTTP/1.1\r\n"
            .. "Host: api.thingspeak.com\r\n"
            .. "Connection: close\r\n"
            .. "Accept: */*\r\n"
            .. "User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n"
            .. "\r\n")
        
    end)
 
    connout:on("disconnection", function(connout, payloadout)
        connout:close();
        ---node.dsleep(5 * 1000000)
        ---collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')

end

function checkTemp()
  getTemp()
  if((temp < tonumber(mintmp)) or (temp > tonumber(maxtmp)) or (humi < tonumber(minhmd)) or (humi > tonumber(maxhmd))) then
    print("send bad funk"..temp.." "..humi.." "..toEmail)
    sendGmailObj.sendBadTempFunc(temp,humi,toEmail)
  else
    print("do postthing interval "..counter)
    postThingSpeak(temp,humi)
    counter = counter +1
    tempAvg=tempAvg+temp
    humiAvg=humiAvg+humi
    if(counter == MAX_INTERVALS) then
      print("interval mail "..(tempAvg/MAX_INTERVALS).." "..(humiAvg/MAX_INTERVALS).." "..toEmail)
      sendGmailObj.sendGmailFunc(tempAvg/MAX_INTERVALS,humiAvg/MAX_INTERVALS,toEmail)
      counter = 0
    end
  end
  loopTimer:start()
  
end

function thinkspeakLoop.startLoop(maxtemp,mintemp,maxhumidity,minhumitidy,to_email)
  maxtmp=maxtemp;
  mintmp=mintemp;
  maxhmd=maxhumidity;
  minhmd=minhumitidy;
  toEmail=to_email;
  counter=0
  loopTimer:register(5000, tmr.ALARM_SEMI, checkTemp)
  checkTemp()
  ---mytimer = tmr.alarm(2, 6000, 1, function() checkTemp() end )
end

function thinkspeakLoop.stopLoop()
  loopTimer:stop()
end

return thinkspeakLoop
