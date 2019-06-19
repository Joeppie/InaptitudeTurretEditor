--This file contains the implementation for the server side functions of the turret editor.
require ("callable")

-- namespace ite
ite = {}


--Code for sending the configuration to the client.
if onServer() and not ite.config then
    ite.config = require("mods.InaptitudeTurretEditor.Config")
end

function ite.initealize()
    if onClient() then
        print("requesting config")
        invokeServerFunction("sendConfig")
    end
end


function ite.sendConfig()
    print("sending config")
    invokeClientFunction(Player(callingPlayer), "receiveConfig", ite.config)
end
callable(ite, "sendConfig")



--Actual implementation

--This function is responsible for gathering values for the turret's current values.
function ite.sendModificationParameters(option,inventoryIndex)

	local player = Player(callingPlayer);
	print('server has been requested to send values for parameters for ', option, ' on turret index ' .. inventoryIndex, ' for ',player.name) ;
	
	local turret = player:getInventory():find(inventoryIndex)
	
	print('the item is', turret.weaponName);
	
	local modification = ite.config.TurretModificationOptions[option];			
	
	
	values = {};
	if modification.Parameters then
		for name,parameter in pairs(modification.Parameters) do
			if(parameter.accessor) then
				values.name = ite["get" .. accessor](turret);
			end
		end
	end
	
	
	invokeClientFunction(player, "receiveModificationParameters", ite.config)
end
callable(ite, "sendModificationParameters")


--Accessor definitions, required for turrets.


--Size
function ite.getSize(turret)
	return turret.size;
end
function ite.setSize(turret,val)
	if(val < 0.5 or val > 5) then return "invalid size"; end
	turret.size = val;
end

--Coaxial
function ite.getCoaxial(turret)
	return turret.coaxial;
end
function ite.setCoaxial(turret,val)
	if(val) then turret.coaxial = true; else turret.coaxial = false; end
end

--IndependentTargeting
function ite.getIndependentTargeting(turret)
	return turret.automatic;
end
function ite.setIndependentTargeting(turret,val)
	if(val) then turret.automatic = true; else turret.automatic = false; end
end













