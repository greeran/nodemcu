pin = 4
thinkspeak_ip = "69.172.201.153"
--192.168.1.26"
conf_ssid = "HOTBOX-AB72" ---nil
conf_password = "popohead103" --nil

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

print("we are already connected")

tmr.alarm(1, 3000, 1, function() getTemp() end)
