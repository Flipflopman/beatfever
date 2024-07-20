local moduleName = "[RPC Manager]"
--local AppId = "" --// This is an app i made on discord, feel free to change it. <-- disable cause discord is weird asf 
local State = "In the menu"
local details = "sigma"
local rpc = require("discordRPC")
local rpcenabled = false

function int_discordRPC()
	if not rpcenabled then return end
	rpc.initialize(AppId, true)
    local now = os.time(os.date("*t"))
    presence = {
        state = State,
        details = "sigma",
        startTimestamp = now,
		smallImageKey="logomain",
    }
	nextPresenceUpdate = 0
end

function update_discordRPC()
	if not rpcenabled then return end

	if nextPresenceUpdate < love.timer.getTime() then
		rpc.updatePresence(presence)
		nextPresenceUpdate = love.timer.getTime() + 2.0
    end
		rpc.runCallbacks()

end

function shutdown_rpc()
    rpc.shutdown()
end

function rpc.errored(errorCode, message)
	debugLog(message, 2, moduleName)
end

function rpc.disconnected(errorCode, message)
	debugLog(message, 2, moduleName)
end

function rpc.ready(userId, username, discriminator, avatar)
	debugLog("Discord RPC Connected", 1, moduleName)
end
