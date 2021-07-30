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

// Console convars
CreateClientConVar("cl_showcrosshair", "0", true, false, "Shows your crosshair.", 0, 1)
CreateClientConVar("cl_menupos", "0", true, false, "Sets the menu position.", 0, 4)
CreateClientConVar("cl_lasttab", "0", false, false, "Sets the last menu tab.", 0, 3)

local spawnables = {
	{
		name = "Bolter",
		description = "He bolts towards you and hides when up close.",
		classname = "npc_bolter",
	},
	{
		name = "Rollermine",
		description = "A rollermine from Half-Life 2.",
		classname = "npc_rollermine",
	},
	{
		name = "Manhack",
		description = "A manhack from Half-Life 2.",
		classname = "npc_manhack",
	},
}

// Enumerations for menu positions
local SBD_MENU_POS_CENTER = 0
local SBD_MENU_POS_TOP_LEFT = 1
local SBD_MENU_POS_TOP_RIGHT = 2
local SBD_MENU_POS_BOTTOM_LEFT = 3
local SBD_MENU_POS_BOTTOM_RIGHT = 4

// Enumerations for tab positions
local SBD_MENU_TAB_SETTINGS = 0
local SBD_MENU_TAB_SPAWN_MENU = 1
//local SBD_MENU_TAB_SANDBOX_OPTIONS = 2
//local SBD_MENU_TAB_SANDBOX_UTILITIES = 3

local Frame

// Freeze time when you press Q.
if game.SinglePlayer() then
	function GM:KeyPress( ply, key )
		if key == IN_SCORE then
			net.Start("SplitBullet.Network.TimeScale")
			net.SendToServer()
		end
	end
end

// This is the drafts menu.
function GM:OnContextMenuOpen()
    if IsValid(Frame) then Frame:Close() end
    Frame = vgui.Create("DFrame")
    Frame:SetSize(512, 512)
    local curpos = GetConVar("cl_menupos")
    if curpos:GetInt() == SBD_MENU_POS_CENTER then
        Frame:Center()
    elseif curpos:GetInt() == SBD_MENU_POS_TOP_LEFT then
        Frame:SetPos(32, 32)
    elseif curpos:GetInt() == SBD_MENU_POS_TOP_RIGHT then
        Frame:SetPos(ScrW()-512-32, 32)
    elseif curpos:GetInt() == SBD_MENU_POS_BOTTOM_LEFT then
        Frame:SetPos(32, ScrH()-512-32)
    elseif curpos:GetInt() == SBD_MENU_POS_BOTTOM_RIGHT then
        Frame:SetPos(ScrW()-512-32, ScrH()-512-32)
    end
    Frame:SetTitle("Split Bullet: Drafts Menu")
    Frame:SetVisible(true)
    Frame:SetDraggable(true)
    Frame:ShowCloseButton(true)
    Frame:MakePopup()

    local sheet = vgui.Create( "DPropertySheet", Frame )
    sheet:Dock( FILL )

    local panel1 = vgui.Create( "DPanel", sheet )
    local menupos = panel1:Add("DButton")
    menupos:SetPos(10, 10)
    menupos:SetText("Set menu position")
    menupos:SizeToContents()
    menupos.DoClick = function()
        local menu = vgui.Create("DMenu")
        local options = {}
        table.insert(options,menu:AddOption("Center", function() GetConVar("cl_menupos"):SetInt(SBD_MENU_POS_CENTER) end))
        table.insert(options,menu:AddOption("Top left", function() GetConVar("cl_menupos"):SetInt(SBD_MENU_POS_TOP_LEFT) end))
        table.insert(options,menu:AddOption("Top right", function() GetConVar("cl_menupos"):SetInt(SBD_MENU_POS_TOP_RIGHT) end))
        table.insert(options,menu:AddOption("Bottom left", function() GetConVar("cl_menupos"):SetInt(SBD_MENU_POS_BOTTOM_LEFT) end))
        table.insert(options,menu:AddOption("Bottom right", function() GetConVar("cl_menupos"):SetInt(SBD_MENU_POS_BOTTOM_RIGHT) end))
        for k,v in pairs(options) do
            local pos = v:GetText()
            // Meh... This works, but it's not pretty.
            v:SetChecked(curpos:GetInt() == SBD_MENU_POS_CENTER and pos == "Center"
            or curpos:GetInt() == SBD_MENU_POS_TOP_LEFT and pos == "Top left"
            or curpos:GetInt() == SBD_MENU_POS_TOP_RIGHT and pos == "Top right"
            or curpos:GetInt() == SBD_MENU_POS_BOTTOM_LEFT and pos == "Bottom left"
            or curpos:GetInt() == SBD_MENU_POS_BOTTOM_RIGHT and pos == "Bottom right")
        end
        menu:SizeToContents()
        menu:Open()
    end
	local perspective = panel1:Add("DButton")
    perspective:SetPos(10, 30)
    perspective:SetText("Toggle Perspective")
    perspective:SizeToContents()
    perspective.DoClick = function()
        RunConsoleCommand("splitbullet_toggleperson")
    end
	local godmode = panel1:Add("DButton")
    godmode:SetPos(10, 50)
    godmode:SetText("Toggle Godmode")
    godmode:SizeToContents()
    godmode.DoClick = function()
        RunConsoleCommand("splitbullet_godmode")
    end
	local nohud = panel1:Add("DButton")
    nohud:SetPos(10, 70)
    nohud:SetText("Cycle HUD")
    nohud:SizeToContents()
    nohud.DoClick = function()
        RunConsoleCommand("splitbullet_togglehud")
    end
    local sensitivity = panel1:Add("DNumberWang")
	sensitivity:SetPos(10, 90)
	sensitivity:SetConVar("sb_mousesensitivity")
    sensitivity:SetDecimals(2)
    sensitivity:SetMin(0)
    sensitivity:SetMax(math.huge)
    sensitivity:SetValue(GetConVar("sb_mousesensitivity"):GetFloat())
	sensitivity:SizeToContents()
    local sensitivitylabel = panel1:Add("DLabel")
    sensitivitylabel:SetPos(70, 93)
    sensitivitylabel:SetText("Mouse Sensitivity")
    sensitivitylabel:SetTextColor(Color(127,127,127))
    sensitivitylabel:SizeToContents()
    sheet:AddSheet("Settings", panel1, "icon16/cog.png")

    local panel2 = vgui.Create("DPanel", sheet)
    local lasty = -10
    for k,v in pairs(spawnables) do
        local spawnable = panel2:Add("DButton")
        lasty = lasty+20
        spawnable:SetPos(10, lasty)
        spawnable:SetText(v.name)
        spawnable:SizeToContents()
		spawnable.DoClick = function()
			net.Start("SplitBullet.Network.Spawn")
			net.WriteString(v.classname or "npc_bolter")
			net.SendToServer()
		end
		local description = panel2:Add("DLabel")
		description:SetTextColor(Color(127,127,127))
		description:SetText(v.description)
		description:SetPos(spawnable:GetWide()+15, lasty+2)
		description:SizeToContents()
    end
	local killall = panel2:Add("DButton")	
	killall:SetPos(10, lasty+40)
	killall:SetText("Kill Everything")
	killall:SizeToContents()
	killall.DoClick = function()
		net.Start("SplitBullet.Network.KillAll")
		net.SendToServer()
	end
	local description2 = panel2:Add("DLabel")
	description2:SetTextColor(Color(127,127,127))
	description2:SetText("Kills every spawnable object.")
	description2:SetPos(killall:GetWide()+15, lasty+42)
	description2:SizeToContents()
    sheet:AddSheet("Spawn Menu", panel2, "icon16/bomb.png")

    sheet:SetFadeTime(0) // Looks bad if we fade in before we set the tab.

    // Setting the last tab position.
    local lasttab = GetConVar("cl_lasttab")
    if lasttab:GetInt() == SBD_MENU_TAB_SETTINGS then
        sheet:SetActiveTab(sheet:GetItems()[1].Tab)
    elseif lasttab:GetInt() == SBD_MENU_TAB_SPAWN_MENU then
        sheet:SetActiveTab(sheet:GetItems()[2].Tab)
    /*
	elseif lasttab:GetInt() == SBD_MENU_TAB_SANDBOX_OPTIONS then
        print("tab3")
        sheet:SetActiveTab(sheet:GetItems()[3].Tab)
    elseif lasttab:GetInt() == SBD_MENU_TAB_SANDBOX_UTILITIES then
        print("tab4")
        sheet:SetActiveTab(sheet:GetItems()[4].Tab)
	*/
    end

    // Saving the last tab position cvar.
    Frame.OnClose = function()
        local cvar = GetConVar("cl_lasttab")
        if sheet:GetActiveTab() == sheet:GetItems()[1].Tab then
            cvar:SetInt(SBD_MENU_TAB_SETTINGS)
        elseif sheet:GetActiveTab() == sheet:GetItems()[2].Tab then
            cvar:SetInt(SBD_MENU_TAB_SPAWN_MENU)
        /*
		elseif sheet:GetActiveTab() == sheet:GetItems()[3].Tab then
            cvar:SetInt(SBD_MENU_TAB_SANDBOX_OPTIONS)
        elseif sheet:GetActiveTab() == sheet:GetItems()[4].Tab then
            cvar:SetInt(SBD_MENU_TAB_SANDBOX_UTILITIES)
		*/
        end
    end

	local help = panel2:Add("DLabel")
	help:SetTextColor(Color(127,127,127))
	help:SetText("Choose an object to spawn and it will be placed where your world cursor is.")
	help:SetPos(7, 420)
	help:SizeToContents()

    sheet:SetFadeTime(0.1) // Revert to default fade time.
end

// Drafts commands, for use in the console and in the menu.

concommand.Add("splitbullet_godmode", function()
    net.Start("SplitBullet.Network.God")
    net.SendToServer()
end, nil, "Toggles godmode.")

concommand.Add("splitbullet_togglehud", function()
	local cvar = GetConVar("sb_nohud")
    if cvar:GetInt() >= 2 then
		cvar:SetInt(0)
	else
		cvar:SetInt(cvar:GetInt()+1)
	end
end, nil, "Toggles the HUD.")

