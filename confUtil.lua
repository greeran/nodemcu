local M={};

local confFile="myconf"

function M.getPassw(conf_ssid, conf_password)
	retValue = false
	print("getting passwd from file")
	if file.open(confFile,"r") then
		conf_ssid=file.readline()
		conf_password=file.readline()
		file.close()
		retValue=true
	end
	return retValue
end

function M.savePassw(conf_ssid, conf_password)
	print("saving passwd ")
	if file.open(confFile,"w") then
		file.writeline(conf_ssid)
		file.writeine(conf_password)
		file.close()
	end
end

return M