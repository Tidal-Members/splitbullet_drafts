/*
	Copyright (c) 2021 Team Tidal

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

SWEP.Base = "weapon_splitbulletbase"
SWEP.PrintName = "Bolter Spawner"
SWEP.Instructions = "MOUSE1 to spawn a bolter."
SWEP.ViewModel			= "models/weapons/c_pistol.mdl"
SWEP.WorldModel = "models/splitbullet/weapons/w_glock.mdl"

local ShootSound = Sound( "Metal.SawbladeStick" )

SWEP.CSMuzzleFlashes = true
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Slot				= 1
SWEP.SlotPos			= 1
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.UseHands			= true

SWEP.Spawnable			= true

function SWEP:Think()
end

function SWEP:PrimaryAttack()
	
	local tr = util.TraceLine( util.GetPlayerTrace( self.Owner ) )
	if ( !tr.HitWorld ) then return end

	if ( IsFirstTimePredicted() ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
		util.Effect( "Sparks", effectdata )
	end

	self:EmitSound( ShootSound )

	self:ShootEffects( self )

	if ( CLIENT ) then return end

	local ent = ents.Create( "npc_bolter" )
	if ( !IsValid( ent ) ) then return end

	ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
	ent:SetAngles( tr.HitNormal:Angle() )
	ent:Spawn()

	if ( self.Owner:IsPlayer() ) then
		undo.Create( "Bolter" )
			undo.AddEntity( ent )
			undo.SetPlayer( self.Owner )
		undo.Finish()
	end

end

function SWEP:SecondaryAttack()

	local tr = util.TraceLine( util.GetPlayerTrace( self.Owner ) )
	if ( !tr.HitWorld ) then return end

	self:EmitSound( ShootSound )
	self:ShootEffects( self )

	if ( IsFirstTimePredicted() ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
		util.Effect( "Sparks", effectdata )
	end

	if ( CLIENT ) then return end

	local ent = ents.Create( "npc_rollermine" )
	if ( !IsValid( ent ) ) then return end

	ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -16 )
	ent:SetAngles( tr.HitNormal:Angle() )
	ent:Spawn()

	if ( self.Owner:IsPlayer() ) then
		undo.Create( "Rollermine" )
			undo.AddEntity( ent )
			undo.SetPlayer( self.Owner )
		undo.Finish()
	end

end

function SWEP:ShouldDropOnDie()
	return false
end
