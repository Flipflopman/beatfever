local moduleName = "[RPC Manager]"
local AppId = "1264350096108028017"
local State = "In the menu"
local details = "AFK"
local rpc = require("discordRPC")
local rpcenabled = true

function int_discordRPC()

	if love.system.getOS()~="Windows" then rpcenabled=false end --// The RPC binding i use doesn't work with mac or linux, maybe Ill find some alternatives in the future.

	if not rpcenabled then return end
	rpc.initialize(AppId, true)
    local now = os.time(os.date("*t"))
    presence = {
        state = State,
        details = details,
        startTimestamp = now,
		largeImageKey="logoround",
		largeImageText="Beatfever",
    }
	nextPresenceUpdate = 0
end

function rpc_setState(state)
	presence.state = state
end

function rpc_setDetails(details)
	presence.details = details
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
