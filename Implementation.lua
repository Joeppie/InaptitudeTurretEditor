--This file contains the implementation for the server side functions of the turret editor.
require ("callable")
local SellableInventoryItem = require("sellableinventoryitem")

-- namespace ite
ite = {}

--Accessors sub-namespace, used for Modifications in config.
ite.accessors = {}


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
	
	local turretInfo = 
	{
		--InventoryTurret object; required for many turret modifications
		turret = player:getInventory():find(inventoryIndex),
		--Index: required for opertions on player inventory.
		index = inventoryIndex,
		--the 'sellable' item, which gives us some information on what the turret actually is, is called etc.
		sellableItem = nil,
		player = player
	}
	
	turretInfo.sellableItem = SellableInventoryItem(turretInfo.turret,turretInfo.index,player);
	
	print('the item is', ite.accessors.getName(turretInfo));
	local modification = ite.config.TurretModificationOptions[option];			
	
	values = {};
	if modification.Parameters then
		for name,parameter in pairs(modification.Parameters) do
			if(parameter.accessor) then
				values.name = ite.accessors["get" .. accessor](turretInfo);
			end
		end
	end
	
	
	invokeClientFunction(player, "receiveModificationParameters", values)
end
callable(ite, "sendModificationParameters")


--Accessor definitions; these are used to retrieve and set values, usually by modifications; see accessor properties in config.

--Name
function ite.accessors.getName(turretInfo)
		local weapons = {turretInfo.turret:getWeapons()}
		for _,weapon in pairs(weapons) do
			return weapon.prefix; --simply return the name of the first weapon.
		end 
end
function ite.accessors.setName(turretInfo,val)
	if(val == nil or string.len(val) <3) then return "Name is too short.";
		elseif(string.len(val) > 25) then return "Name is too long."; end

	local weapons = {turretInfo.turret:getWeapons()}
		for _,weapon in pairs(weapons) do
			if(weapon.originalPrefix  == nil) then weapon.originalPrefix = weapon.prefix end
			weapon.prefix = val;
		end 
end

--Size
function ite.accessors.getSize(turretInfo)
	return turretInfo.turret.size;
end
function ite.accessors.setSize(turretInfo,val)
	if(val < 0.5 or val > 5) then return "invalid size"; end
	turretInfo.turret.size = val;
end

--Coaxial
function ite.accessors.getCoaxial(turretInfo)
	return turretInfo.turretturret.coaxial;
end
function ite.accessors.setCoaxial(turretInfo,val)
	if(val) then turretInfo.turret.coaxial = true; else turretInfo.turret.coaxial = false; end
end

--IndependentTargeting
function ite.accessors.getIndependentTargeting(turretInfo)
	return turretInfo.turret.automatic;
end
function ite.accessors.setIndependentTargeting(turretInfo,val)
	if(val) then turretInfo.turret.automatic = true; else turretInfo.turret.automatic = false; end
end













