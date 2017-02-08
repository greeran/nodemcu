local thinkspeakLoop={}


local thinkspeak_ip = "69.172.201.153"
local maxtmp,mintmp,maxhmd,minhmd,toEmail
local counter=0
local MAX_INTERVALS=12
local tempAvg=0
local humiAvg=0
local loopTimer=tmr.create()

local sendGmailObj =require("sendGmail")
local getDht11bj = require("getDht11")

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
        
        counter = counter +1
        if(counter == (MAX_INTERVALS-1)) then
          local tmpMail=toEmail;
          print("interval mail "..(tempAvg/MAX_INTERVALS).." "..(humiAvg/MAX_INTERVALS).." tmpmail="..tmpMail)
          ---sendGmailObj.testFunc(toEmail)
          sendGmailObj.sendGmailFunc(math.floor(tempAvg/MAX_INTERVALS),math.floor(humiAvg/MAX_INTERVALS),tmpMail);
          counter = 0
        end
        ---node.dsleep(5 * 1000000)
        ---collectgarbage();
    end)
 
    connout:connect(80,'api.thingspeak.com')

end

function checkTemp()
  local dhtstat,temp,humi=getDht11bj.getTemp();
  if(dhtstat == -1) then
    print("failed the dht get temp")
  else
    if((temp < tonumber(mintmp)) or (temp > tonumber(maxtmp)) or (humi < tonumber(minhmd)) or (humi > tonumber(maxhmd))) then
      print("send bad funk "..temp.." "..humi.." "..toEmail.." limits in one: "..mintmp.." "..maxtmp.." "..minhmd.." "..maxhmd);
      sendGmailObj.sendBadTempFunc(temp,humi,toEmail)
    else
      print("do postthing interval "..counter)
      tempAvg=tempAvg+temp
      humiAvg=humiAvg+humi
      postThingSpeak(temp,humi)
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
  loopTimer:register(3600000, tmr.ALARM_SEMI, checkTemp)
  checkTemp()
  ---mytimer = tmr.alarm(2, 6000, 1, function() checkTemp() end )
end

function thinkspeakLoop.stopLoop()
  loopTimer:stop()
end

return thinkspeakLoop
