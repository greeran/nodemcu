---local getDht11=require("getDht11.lua")
dofile("getDht11.lua")

local sendGmailObj =require("sendGmail")

if srv~=nil then
  srv:close()
end

srv=net.createServer(net.TCP)
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
        end

        if(_GET.getTemp == "Temp")then
              dofile("getDht11.lua");
        ---elseif(_GET.sendThings == "Thing")then
        ---      print("Got Thing");
        elseif(_GET.action == "Test")then
          print("Testing mail 2")
          sendGmailObj.sendGmailFunc(_GET.notification)
          ---dofile("sendGmail.lua")
        elseif(_GET.action == "Start")then
          print("starting with temp min/max".._GET.mintemp.."/".._GET.maxtemp)
        end
        
        mail_to = _GET.notification
        
        print("Setting the http");
        ---buf = buf.."<h1> Thermometer Setting</h1>";
        ---buf = buf.."<p>Get Tempruture and Humidity<a href=\"?getTemp=Temp\"><button>Press</button></a>&nbsp";
        ---buf = buf.."<p>Send To Thingspeak<a href=\"?sendThings=Thing\"><button>Press</button></a>&nbsp";
        buf= buf.."<h1> Thermometer Setting</h1>";
        buf= buf.."<h2>Temprature "..tempr.." Humidity "..humi.."</h2><p>";
        buf= buf.."<p>Get Tempruture and Humidity <a href=\"?getTemp=Temp\"><button>Press</button></a>&nbsp;</p>";
        ---buf= buf.."<p>Send To Thingspeak <a href=\"?sendThings=Thing\"><button>Press</button></a>&nbsp;</p>";
        buf= buf.."<form><p>Min Temprature <input type=\"text\" name=\"mintemp\" value=\"30\">&nbsp;</p>";
        buf= buf.."<p>Max Temprature <input type=\"text\" name=\"maxtemp\" value=\"40\">&nbsp;</p>";
        buf= buf.."<p>Min Humidity <input type=\"text\" name=\"minhumd\" value=\"30\">&nbsp;</p>";
        buf= buf.."<p>Max Humitidy <input type=\"text\" name=\"maxhumd\" value=\"40\">&nbsp;</p>";
        buf= buf.."<p>notification Mail <input name=\"notification\" type=\"text\" /> <input type=\"submit\" name=\"action\" value=\"Test Mail\""
        if(_GET.action == "Test")then
          if(false == NotificationFail)then
            buf= buf.."<font color=red> Failed Mail Test <\font>"
          else
            buf= buf.."<font color=green> Success Mail Test <\font>"
          end
        end
        buf= buf.."</p><p><input type=\"submit\" name=\"action\" value=\"Start Working\" </p></a></form>&nbsp;</p>";


        
      
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
