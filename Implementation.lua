--This file contains the implementation for the server side functions of the turret editor.
require ("callable")

-- namespace iti
iti = {}



if not iti.config then
	iti.config = require("mods.InaptitudeTurretEditor.Config")
end


function iti.getConfig()
	invokeServerFunction("server_getConfig")
end

function iti.server_getConfig()
	return iti.config;
end
callable(iti,"server_getConfig");










