local getDht11Obj=require("getDht11")

local sendGmailObj =require("sendGmail")
local thinkLoop = require("thinkspeak-loop")

if srv~=nil then
  srv:close()
end

tempMin=15;
tempMax=35;
humiMin=25;
humiMax=50;
sndToMail="greeranjunk@gmail.com"

srv=net.createServer(net.TCP)

local dhtstat,dhttemp,dhthumi

dhtstat,dhttemp,dhthumi=getDht11Obj.getTemp();

srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
                print("["..k.."]="..v.." ")
            end
            for k, v, rr,ss in string.gmatch(vars, "(%w+)=(%w+)%%40(%w+).(%w+)&*") do     
                print("["..k.."]="..v.."@"..rr.."."..ss)
                _GET[k]=""..v.."@"..rr.."."..ss;
            end
        end

        if(_GET.getTemp == "Temp")then
              dhtstat,dhttemp,dhthumi=getDht11Obj.getTemp();              
        elseif(_GET.action == "Test")then
          print("Testing mail 2")
          sndToMail=_GET.notification;
          tempMax=_GET.maxtemp;
          tempMin=_GET.mintemp;
          humiMax=_GET.maxhumd;
          humiMin=_GET.minhumd;
          sendGmailObj.setMailToAddr(_GET.notification)
          sendGmailObj.sendGmailFunc(tempr,humi,_GET.notification)
          ---dofile("sendGmail.lua")
        elseif(_GET.action == "Start")then
          tempMax=_GET.maxtemp;
          tempMin=_GET.mintemp;
          humiMax=_GET.maxhumd;
          humiMin=_GET.minhumd;
          sndToMail=_GET.notification;
          print("test"..tempMax.." test "..tempMin.." test "..humiMax.." test "..humiMin.." test "..sndToMail.." ")
          thinkLoop.startLoop(tempMax,tempMin,humiMax,humiMin,sndToMail)
          
        end
        
        mail_to = _GET.notification
        
        print("Setting the http");
        ---buf = buf.."<h1> Thermometer Setting</h1>";
        ---buf = buf.."<p>Get Tempruture and Humidity<a href=\"?getTemp=Temp\"><button>Press</button></a>&nbsp";
        ---buf = buf.."<p>Send To Thingspeak<a href=\"?sendThings=Thing\"><button>Press</button></a>&nbsp";
        buf= buf.."<h1> Thermometer Setting</h1>";
        buf= buf.."<h2>Temprature "..dhttemp.." Humidity "..dhthumi.."</h2><p>";
        buf= buf.."<p>Get Tempruture and Humidity <a href=\"?getTemp=Temp\"><button>Press</button></a>&nbsp;</p>";
        ---buf= buf.."<p>Send To Thingspeak <a href=\"?sendThings=Thing\"><button>Press</button></a>&nbsp;</p>";
        buf= buf.."<form><p>Min Temprature <input type=\"text\" name=\"mintemp\" value="..tempMin..">&nbsp;</p>";
        buf= buf.."<p>Max Temprature <input type=\"text\" name=\"maxtemp\" value="..tempMax..">&nbsp;</p>";
        buf= buf.."<p>Min Humidity <input type=\"text\" name=\"minhumd\" value="..humiMin..">&nbsp;</p>";
        buf= buf.."<p>Max Humitidy <input type=\"text\" name=\"maxhumd\" value="..humiMax..">&nbsp;</p>";
        buf= buf.."<p>notification Mail <input name=\"notification\" type=\"email\" value="..sndToMail.." pattern=\"[a-z0-9._%+-]+@[a-z0-9.-]+\\.[a-z]{2,3}$\"> <input type=\"submit\" name=\"action\" value=\"Test Mail\""
        if(_GET.action == "Test")then
          if(false == NotificationFail)then
            buf= buf.."<font color=red> Failed Mail Test <\font>"
          else
            buf= buf.."<font color=green> Success Mail Test <\font>"
          end
        end
        buf= buf.."</p><p><input type=\"submit\" name=\"action\" value=\"Start Working\" </sp></a></form>&nbsp;</p>";


        
      
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
