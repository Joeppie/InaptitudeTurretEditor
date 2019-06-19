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









