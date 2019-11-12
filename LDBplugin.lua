------------------------------------------------------------------------------------------
-- AutoMessage insert to titan pannel
------------------------------------------------------------------------------------------

local AutoMessage = LibStub("AceAddon-3.0"):GetAddon("AutoMessage");
-- local L = LibStub("AceLocale-3.0"):GetLocale("AutoMessage");

local hovertip
function AutoMessage:TogglePanel()
	if (Main_frame:IsShown()) then
		Main_frame:Hide()
	else
        AutoMessage:initTabs();
	end
end
function DWGKP_ShowTitanButton(switch)
	if (not TitanPanelSettings) then
	--	dwDelayCall("TitanPanelShowCustomButton", 1, "LDBT_DWGKP", switch);
		TitanPanelShowCustomButton("AutoMessage", switch);
	else
		TitanPanelShowCustomButton("AutoMessage", switch);
	end	
end

function AutoMessage:SetupLDB()
    self:Print('AutoMessage insert to TitanPannel')
	self.ldbp = LibStub("LibDataBroker-1.1"):NewDataObject("AutoMessage", {
		-- icon = "Interface\\ICONS\\INV_Misc_Coin_16",
		label = "AutoMessage",
		type = "launcher",
		text  = "AutoMessage",
        OnClick = function(clickedFrame, button)
			self:TogglePanel();
			if hovertip and hovertip.Hide then
				hovertip:Hide()
			end
		end,
		OnTooltipShow = function(tt)
			tt:SetText('AutoMessage', 1, 1, 1)
			tt:AddLine("Click to toggle AutoMessage frame.")
			hovertip = tt
		end,
	});
end