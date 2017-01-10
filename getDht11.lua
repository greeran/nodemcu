local DHT11Class={}

local pin = 4

function DHT11Class:getTemp()
  
  local status,tempr,humi,temp_decimial,humi_decimial = dht.read11(pin)
  local ret_stat=0
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
    ret_stat=-1
    print( "DHT Checksum error." );      
  elseif( status == dht.ERROR_TIMEOUT ) then
    ret_stat=-1
    print( "DHT Time out." );
  end
  return ret_stat,tempr,humi
end

return DHT11Class;
