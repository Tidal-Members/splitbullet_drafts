/*
	Copyright (c) 2021 TidalDevs

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

// List of valid entities
local spawnables = {
	"npc_bolter",
	"npc_rollermine",
	"npc_manhack",
}

// Let's allow players to spawn entities.
util.AddNetworkString("SplitBullet.Network.Spawn")
net.Receive("SplitBullet.Network.Spawn", function(len, ply)
	local spawn = net.ReadString(32) or "npc_bolter"
	for k,v in pairs(spawnables) do
		if v == spawn then // Valid entity
			local ent = ents.Create(spawn)
			if not IsValid(ent) then return end
			local tr = util.TraceLine(util.GetPlayerTrace(ply))
			ent:SetPos(tr.HitPos + ply:GetAimVector() * -16)
			ent:SetAngles(tr.HitNormal:Angle())
			ent:Spawn()
			ent:Activate()
			return
		end
	end
end)

// Kill every valid entity.
util.AddNetworkString("SplitBullet.Network.KillAll")
net.Receive("SplitBullet.Network.KillAll", function(len, ply)
	for k,v in pairs(spawnables) do
		for k2,v2 in pairs(ents.FindByClass(v)) do
			if not IsValid(v2) then return end
			local explosion = ents.Create("env_explosion")
			explosion:SetPos(v2:GetPos())
			explosion:SetKeyValue("spawnflags", 1)
			explosion:Spawn()
			explosion:Input("Explode")
			v2:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
			v2:Remove()
		end
	end
end)

// Toggle godmode for players.
util.AddNetworkString("SplitBullet.Network.God")
net.Receive("SplitBullet.Network.God", function(len, ply)
	if ply:HasGodMode() then
    	ply:GodDisable()
	else
		ply:GodEnable()
	end
end)

// Allow players to slow down time in singleplayer.
if game.SinglePlayer() then
	util.AddNetworkString("SplitBullet.Network.TimeScale")
	net.Receive("SplitBullet.Network.TimeScale", function(len, ply)
		if game.GetTimeScale() >= 1 then
			game.SetTimeScale(0.25)
		else
			game.SetTimeScale(1)
		end
	end)
end
