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

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include( "shared.lua" )

function SWEP:Reload()
	// Disintegrate every bolter
	for k,v in pairs(ents.FindByClass("npc_bolter")) do
		local d = DamageInfo()
		d:SetDamage(v:Health())
		d:SetAttacker(v)
		d:SetDamageType(DMG_BLAST)
		v:TakeDamageInfo(d)
	end
	// Disintegrate every rollermine
	for k,v in pairs(ents.FindByClass("npc_rollermine")) do
		local explosion = ents.Create("env_explosion")
		explosion:SetPos(v:GetPos())
		explosion:SetKeyValue("spawnflags", 1)
		explosion:Spawn()
		explosion:Input("Explode")
		v:EmitSound("npc/roller/mine/rmine_explode_shock1.wav")
		v:Remove()
	end
end

