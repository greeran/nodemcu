---local M={};

local pin = 4

---function M.getTemp()
status,tempr,humi,temp_decimial,humi_decimial = dht.read11(pin)
if( status == dht.OK ) then
      -- Integer firmware using this example
  print(
    string.format(
      "in function DHT Temperature:%d.%03d;Humidity:%d.%03d\r\n",
      math.floor(tempr),
      temp_decimial,
      math.floor(humi),
      humi_decimial
    )
  )
  -- Float firmware using this example
  print("floating DHT Temperature:"..tempr..";".."Humidity:"..humi)
elseif( status == dht.ERROR_CHECKSUM ) then
  print( "DHT Checksum error." );      
elseif( status == dht.ERROR_TIMEOUT ) then
  print( "DHT Time out." );
end
---	return temp,humi
---end

---return M
