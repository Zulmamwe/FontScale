-- chat options
local opts = {
    type='group',
    args = {
		quest_scale = {
			type = 'text',
            name = "Quest scale value",
            desc = "Sets the scale of quest fonts",
            usage = "<scale number>",
            get = "get_quest_scale",
            set = "set_quest_scale",
		},
		quest = {
			type = 'toggle',
            name = "Quest scale toggle",
            desc = "Enable or disable quest fonts scale",
            get = "get_quest",
            set = "toggle_quest"
		},
		big_scale = {
			type = 'text',
            name = "Big fonts scale value",
            desc = "Sets the scale of big fonts",
            usage = "<scale number>",
            get = "get_big_scale",
            set = "set_big_scale",
		},
		big = {
			type = 'toggle',
            name = "Big fonts scale toggle",
            desc = "Enable or disable big fonts scale",
            get = "get_big",
            set = "toggle_big"
		},
		other_scale = {
			type = 'text',
            name = "Other fonts scale value",
            desc = "Sets the scale of all other fonts",
            usage = "<scale number>",
            get = "get_other_scale",
            set = "set_other_scale",
		},
		other = {
			type = 'toggle',
            name = "Other fonts scale toggle",
            desc = "Enable or disable all other fonts scale",
            get = "get_other",
            set = "toggle_other"
		},
		timer = {
			type = 'toggle',
            name = "Toggle update by timer",
            desc = "Enable or disable fonts scale refresh by timer",
            get = "get_timer",
            set = "toggle_timer"
		},
		timer_interval = {
			type = 'text',
            name = "Timer interval (s)",
            desc = "Sets the time between font scale refreshes (in seconds)",
            usage = "<seconds>",
            get = "get_timer_interval",
            set = "set_timer_interval",
		},
		reload = {
			type = 'execute',
			name = 'Refresh',
			desc = 'Reapply font scale',
			func = 'refresh'
		},
		r = {
			type = 'execute',
			name = 'Refresh',
			desc = 'Reapply font scale',
			func = 'refresh'
		}
    },
}

local fonts = {
	quest = {
		{obj = QuestTitleFont, size = 18},
		{obj = QuestFont, size = 13},
		{obj = QuestFontNormalSmall, size = 12},
		{obj = QuestFontHighlight, size = 14}
	},
	big = {
		{obj = ZoneTextFont, size = 102},
		{obj = WorldMapTextFont, size = 102},
	},
	other = {
		{obj = SystemFont, size = 15},
		{obj = GameFontNormal, size = 12},
		{obj = GameFontBlack, size = 12},
		{obj = GameFontNormalSmall, size = 10},
		{obj = GameFontNormalLarge, size = 16},
		{obj = GameFontNormalHuge, size = 20},
		{obj = NumberFontNormal, size = 14},
		{obj = NumberFontNormalSmall, size = 12},
		{obj = NumberFontNormalLarge, size = 16},
		{obj = NumberFontNormalHuge, size = 30},
		{obj = ChatFontNormal, size = 14},
		{obj = ItemTextFontNormal, size = 15},
		{obj = MailTextFontNormal, size = 15},
		{obj = SubSpellFont, size = 10},
		{obj = DialogButtonNormalText, size = 16},
		{obj = SubZoneTextFont, size = 26},
		{obj = TextStatusBarTextSmall, size = 12},
		{obj = GameTooltipText, size = 12},
		{obj = GameTooltipTextSmall, size = 10},
		{obj = GameTooltipHeaderText, size = 14},
		{obj = InvoiceTextFontNormal, size = 12},
		{obj = CombatTextFont, size = 25},
		{obj = InvoiceTextFontSmall, size = 10},
	}
}

local FontScale = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceEvent-2.0", "AceDB-2.0")
FontScale:RegisterChatCommand({ "/fontscale", "/fs" }, opts)

FontScale:RegisterDB("FontScaleDB")
FontScale:RegisterDefaults("profile", {
	quest_scale = 1.3,
	quest = true,
	big_scale = 1.3,
	big = false,
	other_scale = 1.3,
	other = true,
	timer_interval = 1,
	timer = false
} )

function FontScale:OnInitialize()
    FontScale:refresh()
end

function FontScale:OnEnable()
	FontScale:refresh()
	self:RegisterEvent("TRAINER_UPDATE", "refresh")
	self:RegisterEvent("AUCTION_HOUSE_SHOW", "refresh")
	self:RegisterEvent("TRADE_SKILL_SHOW", "refresh")
	self:RegisterEvent("MAIL_SHOW", "refresh")
	self:RegisterEvent("UPDATE_MACROS", "refresh")
	self:RegisterEvent("BAG_OPEN", "refresh")
	FontScale:HookTalent()
	FontScale:HookBags()
	
	if self.db.profile.timer then
		FontScale:StartTimer()
	end
end

function FontScale:refresh()
	if FontScale:get_quest() then
		FontScale:Iterate(fonts.quest, FontScale:get_quest_scale())
	end
	
	if FontScale:get_big() then
		FontScale:Iterate(fonts.big, FontScale:get_big_scale())
	end
	
	if FontScale:get_other() then
		FontScale:Iterate(fonts.other, FontScale:get_other_scale())
	end
end

function FontScale:Iterate(f, scale)
	for i, o in pairs(f) do
		file, height, flags = o.obj:GetFont()
		FontScale:SetFont(o.obj, file, floor(o.size * scale + 0.5), flags)
	end
end

function FontScale:SetFont(obj, font, size, style)
	if not obj then return end
	obj:SetFont(font, size, style)
end

function FontScale:StartTimer()
	local delayAddWonItem = CreateFrame("Frame")
	FontScale.startTime = GetTime()
	delayAddWonItem:SetScript("OnShow", function()
		FontScale.startTime = GetTime()
	end)
	delayAddWonItem:SetScript("OnUpdate", function()
		local plus = self.db.profile.timer_interval -- seconds
		local gt = GetTime() * 1000
		local st = (FontScale.startTime + plus) * 1000
		if gt >= st then
			FontScale:refresh()
			FontScale.startTime = GetTime()
		end
	end)
	delayAddWonItem:Show()
end

function FontScale:HookTalent()
	local original = ToggleTalentFrame
	if original then
		ToggleTalentFrame = function()
			original()
			FontScale:refresh()
		end
	end
end

function FontScale:HookBags()
	local original = OpenAllBags
	if original then
		OpenAllBags = function()
			original()
			FontScale:refresh()
		end
	end
end

function is_not_number(value)
	if tonumber(value) == nil then
		self:Print('"' .. value .. '" is not a number')
		return true
	else
		return false
	end
end

-- Getters and setters

-- quest
function FontScale:get_quest_scale()
    return self.db.profile.quest_scale
end
function FontScale:set_quest_scale(value)
	if is_not_number(value) then return end
    self.db.profile.quest_scale = value
end
function FontScale:get_quest()
    return self.db.profile.quest
end
function FontScale:toggle_quest()
    self.db.profile.quest = not self.db.profile.quest
end

-- big
function FontScale:get_big_scale()
    return self.db.profile.big_scale
end
function FontScale:set_big_scale(value)
	if is_not_number(value) then return end
    self.db.profile.big_scale = value
end
function FontScale:get_big()
    return self.db.profile.big
end
function FontScale:toggle_big()
    self.db.profile.big = not self.db.profile.big
end

-- other
function FontScale:get_other_scale()
    return self.db.profile.other_scale
end
function FontScale:set_other_scale(value)
	if is_not_number(value) then return end
    self.db.profile.other_scale = value
end
function FontScale:get_other()
    return self.db.profile.other
end
function FontScale:toggle_other()
    self.db.profile.other = not self.db.profile.other
end

-- timer
function FontScale:get_timer_interval()
    return self.db.profile.timer_interval
end
function FontScale:set_timer_interval(value)
	if is_not_number(value) then return end
    self.db.profile.timer_interval = value
end
function FontScale:get_timer()
    return self.db.profile.timer
end
function FontScale:toggle_timer()
    self.db.profile.timer = not self.db.profile.timer
end
