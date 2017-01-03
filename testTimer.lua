local mytimer = tmr.create()
local cnt=0

function testFunc()
    print ("test print "..cnt)  
    cnt=cnt+1
    mytimer:start()
end

-- oo calling
mytimer:register(5000, tmr.ALARM_SEMI, testFunc)
testFunc()
