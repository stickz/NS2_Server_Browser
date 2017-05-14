kServerEntryHeight = 34 -- little bit bigger than highlight server
local kDefaultWidth = 350

local kFavoriteIconSize = Vector(26, 26, 0)
local kFavoriteIconPos = Vector(5, 4, 0)
local kFavoriteTexture = PrecacheAsset("ui/menu/favorite.dds")
local kNonFavoriteTexture = PrecacheAsset("ui/menu/nonfavorite.dds")

local kFavoriteMouseOverColor = Color(1,1,0,1)
local kFavoriteColor = Color(1,1,1,0.9)

local kPingIconSize = Vector(37, 24, 0)
local kPingIconTextures = {
    {60,  PrecacheAsset("ui/icons/ping_5.dds")},
    {110, PrecacheAsset("ui/icons/ping_4.dds")},
    {180, PrecacheAsset("ui/icons/ping_3.dds")},
    {250, PrecacheAsset("ui/icons/ping_2.dds")},
    {999, PrecacheAsset("ui/icons/ping_1.dds")},
}

local kPerfIconSize = Vector(26, 26, 0)
local kPerfIconTexture = PrecacheAsset("ui/icons/smiley_meh.dds")

local kSkillIconSize = Vector(26, 26, 0)
local kSkillIconTextures = {
    PrecacheAsset("ui/menu/skill_equal.dds"),
    PrecacheAsset("ui/menu/skill_low.dds"),
    PrecacheAsset("ui/menu/skill_high.dds")
}

local kOrange = Color(1, 0.6, 0)
local kPink = Color(1, 0.4, 0.7)
local kBlue = Color(0, 168/255 ,255/255)
local kLBlue = Color (0.4, 1, 1)
local kGreen = Color(0, 208/255, 103/255)
local kYellow = kGreen --Color(1, 1, 0) --used for reserved full
local kGold = kBlue --Color(212/255, 175/255, 55/255) --used for ranked
local kRed = kBlue --Color(1, 0 ,0) --used for full

function ServerEntry:Initialize()

    self:DisableBorders()
    
    MenuElement.Initialize(self)
    
    self.serverName = CreateTextItem(self, true)
    self.mapName = CreateTextItem(self, true)
    self.mapName:SetTextAlignmentX(GUIItem.Align_Center)
	
	
    self.ping = CreateGraphicItem(self, true)
    self.ping:SetTexture(kPingIconTextures[1][2])
    self.ping:SetSize(kPingIconSize)
	self.ping:SetTextAlignmentX(GUIItem.Align_Center)
	
    self.tickRate = CreateGraphicItem(self, true)
    self.tickRate:SetTexture(kPerfIconTexture)
    self.tickRate:SetSize(kPerfIconSize)

    self.modName = CreateTextItem(self, true)
    self.modName:SetTextAlignmentX(GUIItem.Align_Center)
    self.modName.tooltip = GetGUIManager():CreateGUIScriptSingle("menu/GUIHoverTooltip")

    self.playerCount = CreateTextItem(self, true)
    self.playerCount:SetTextAlignmentX(GUIItem.Align_Center)
    
    self.favorite = CreateGraphicItem(self, true)
    self.favorite:SetSize(kFavoriteIconSize)
    self.favorite:SetPosition(kFavoriteIconPos)
    self.favorite:SetTexture(kNonFavoriteTexture)
    self.favorite:SetColor(kFavoriteColor)
    
	self.hiveSkill = CreateTextItem(self, true)
	self.hiveSkill:SetFontName(Fonts.kAgencyFB_Small)
    self.hiveSkill:SetTextAlignmentX(GUIItem.Align_Center)
    
    self:SetFontName(Fonts.kAgencyFB_Small)
    
    self:SetTextColor(kWhite)
    self:SetHeight(kServerEntryHeight)
    self:SetWidth(kDefaultWidth)
    self:SetBackgroundColor(kNoColor)
    
    --Has no children, but just to keep sure, we do that.
    self:SetChildrenIgnoreEvents(true)
        
    local eventCallbacks =
    {
        OnMouseIn = function(self, buttonPressed)
            MainMenu_OnMouseIn()
        end,
        
        OnMouseOver = function(self)
        
            local height = self:GetHeight()
            local topOffSet = self:GetBackground():GetPosition().y + self:GetParent():GetBackground():GetPosition().y
            self.scriptHandle.highlightServer:SetBackgroundPosition(Vector(0, topOffSet, 0), true)
            self.scriptHandle.highlightServer:SetIsVisible(true)
            
            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
                self.favorite:SetColor(kFavoriteMouseOverColor)
            else
                self.favorite:SetColor(kFavoriteColor)
            end

            if self.modName.tooltipText and GUIItemContainsPoint(self.modName, Client.GetCursorPosScreen()) then
                self.modName.tooltip:SetText(self.modName.tooltipText)
                self.modName.tooltip:Show()
            else
                self.modName.tooltip:Hide()
            end
        end,
        
        OnMouseOut = function(self)
        
            self.scriptHandle.highlightServer:SetIsVisible(false)
            self.favorite:SetColor(kFavoriteColor)

            if self.lastOneClick then
                self.lastOneClick = nil
                if not self.scriptHandle.serverDetailsWindow:GetIsVisible() then
                    self.scriptHandle.serverDetailsWindow:SetIsVisible(true)
                end
            end
        
        end,
        
        OnMouseDown = function(self, key, doubleClick)

            if GUIItemContainsPoint(self.favorite, Client.GetCursorPosScreen()) then
            
                if not self.serverData.favorite then
                
                    self.favorite:SetTexture(kFavoriteTexture)
                    self.serverData.favorite = true
                    SetServerIsFavorite(self.serverData, true)
                    
                else
                
                    self.favorite:SetTexture(kNonFavoriteTexture)
                    self.serverData.favorite = false
                    SetServerIsFavorite(self.serverData, false)
                    
                end
                
                self.parentList:UpdateEntry(self.serverData, true)
                
            else
            
                SelectServerEntry(self)
                
                if doubleClick then
                
                    if (self.timeOfLastClick ~= nil and (Shared.GetTime() < self.timeOfLastClick + 0.3)) then
                        self.lastOneClick = nil
                        self.scriptHandle:ProcessJoinServer()
                    end
                    
                else

                    self.scriptHandle.serverDetailsWindow:SetServerData(self.serverData, self.serverData.serverId or -1)
                    self.lastOneClick = Shared.GetTime()
                    
                end
                
                self.timeOfLastClick = Shared.GetTime()
                
            end
            
        end
    }
    
    self:AddEventCallbacks(eventCallbacks)

end

function ServerEntry:SetFontName(fontName)

    self.serverName:SetFontName(fontName)
    self.serverName:SetScale(GetScaledVector())
    self.mapName:SetFontName(fontName)
    self.mapName:SetScale(GetScaledVector())
    self.modName:SetFontName(fontName)
    self.modName:SetScale(GetScaledVector())
    self.playerCount:SetFontName(fontName)
    self.playerCount:SetScale(GetScaledVector())
	self.hiveSkill:SetFontName(fontName)
	self.hiveSkill:SetScale(GetScaledVector())
end

function ServerEntry:SetTextColor(color)

    self.serverName:SetColor(color)
    self.mapName:SetColor(color)
    self.modName:SetColor(color)
    self.playerCount:SetColor(color)
end

function ServerEntry:SetServerData(serverData)

    PROFILE("ServerEntry:SetServerData")

    if self.serverData ~= serverData then
    
        local numReservedSlots = GetNumServerReservedSlots(serverData.serverId)
        self.playerCount:SetText(string.format("%d/%d", serverData.numPlayers, (serverData.maxPlayers - numReservedSlots)))
        if serverData.numPlayers >= serverData.maxPlayers then
            self.playerCount:SetColor(kRed)
        elseif serverData.numPlayers >= serverData.maxPlayers - numReservedSlots then
            self.playerCount:SetColor(kYellow)
        else
            self.playerCount:SetColor(kWhite)
        end
     
        self.serverName:SetText(serverData.name)
        
		if serverData.requiresPassword then
			self.serverName:SetColor(kOrange)
        elseif serverData.rookieOnly then
            self.serverName:SetColor(kGreen)
		elseif serverData.favorite then
			self.serverName:SetColor(kPink)
        else
            self.serverName:SetColor(kWhite)
        end
        
        self.mapName:SetText(serverData.map)
        
        for _, pingTexture in ipairs(kPingIconTextures) do
            if serverData.ping < pingTexture[1] then
                self.ping:SetTexture(pingTexture[2])
                break
            end
        end
		
		-- Handle setting the hive skill column
		if serverData.playerSkill ~= nil then
			local pSkill = serverData.playerSkill
			
            -- Only support ns2, ns2+ or ns2Large. Don't allow other custom gamemodes to break things
			if serverData.mode ~= "ns2" and serverData.mode ~= "ns2+" and serverData.mode ~= "ns2Large" then
				self.hiveSkill:SetText(string.format("N/A"))					
				self.hiveSkill:SetColor(Color(1, 1, 1))
			
			elseif pSkill <= 3 then
				-- If the server fails to respond, try to use a previous value (if present)
				if tonumber(self.hiveSkill:GetText()) == nil or serverData.numPlayers == 0 then
					self.hiveSkill:SetText(string.format("N/A"))
					
					if serverData.numPlayers == 0 then
						self.hiveSkill:SetColor(Color(1, 1, 1))
					end
				end
				
			else
				self.hiveSkill:SetText(string.format("%d", pSkill))				
								
				if pSkill < 2800 then
					-- set percent of red to use				
					local hRed = 0
					if pSkill > 1199 then hRed = 1 end
						
					-- set percent of green to use
					local hGreen = 1 
					if pSkill > 1999 then hGreen = 0 
					elseif pSkill > 1649 then hGreen = 0.6 
					else hGreen = 1 end
					
					self.hiveSkill:SetColor(Color(hRed, hGreen, 0))
					
				else -- we're a competitive ranking					
					self.hiveSkill:SetColor(kLBlue)
				end
            end
        end			
        
        if serverData.performanceScore ~= nil then
            self.tickRate:SetTexture(ServerPerformanceData.GetPerformanceIcon(serverData.performanceQuality, serverData.performanceScore))
            -- Log("%s: score %s, q %s", serverData.name, serverData.performanceScore, serverData.performanceQuality)
        else
            self.tickRate:SetTexture(kPerfIconTexture)
        end		
        
        self.modName:SetText(serverData.mode)
        self.modName:SetColor(kWhite)
        self.modName.tooltipText = nil

        if serverData.mode == "ns2" and serverData.ranked then
            self.modName:SetColor(kGold)
            self.modName.tooltipText = Locale.ResolveString(string.format("SERVERBROWSER_RANKED_TOOLTIP"))
        end
        
        if serverData.favorite then
            self.favorite:SetTexture(kFavoriteTexture)
        else
            self.favorite:SetTexture(kNonFavoriteTexture)
        end
        
        local skillColor = kGreen
        local skillAngle = 0
        local skillTextureId = 1
        local toolTipId = 1
        
        self:SetId(serverData.serverId)
        self.serverData = { }
        for name, value in pairs(serverData) do
            self.serverData[name] = value
        end
        
    end
    
end

function ServerEntry:SetWidth(width, isPercentage, time, animateFunc, callBack)

    if width ~= self.storedWidth then
        -- The percentages and padding for each column are defined in the CSS
        -- We can use them here to set the position correctly instead of guessing like previously
        MenuElement.SetWidth(self, width, isPercentage, time, animateFunc, callBack)
        local currentPos = 0
        local currentWidth = self.favorite:GetSize().x
        local currentPercentage = width * 0.05
        local kPaddingSize = 4

        self.favorite:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), GUIScale(2), 0))

        currentPos = currentPos + currentPercentage + kPaddingSize + kPaddingSize
        currentPercentage = width * 0.38
        self.serverName:SetPosition(Vector((currentPos + kPaddingSize), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScale(self.modName:GetTextWidth(self.modName:GetText()))
        self.modName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.15
        currentWidth = GUIScale(self.mapName:GetTextWidth(self.mapName:GetText()))
        self.mapName:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.12 -- 2 percent off
        currentWidth = GUIScale(self.playerCount:GetTextWidth(self.playerCount:GetText()))
        self.playerCount:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
		
		currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.09
		currentWidth = GUIScale(self.hiveSkill:GetTextWidth(self.hiveSkill:GetText()))
        self.hiveSkill:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScaleWidth(26)
        self.tickRate:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 0, 0))
        
        currentPos = currentPos + currentPercentage + kPaddingSize
        currentPercentage = width * 0.07
        currentWidth = GUIScaleWidth(60)
        self.ping:SetPosition(Vector((currentPos + currentPercentage/2 - currentWidth/2), 2, 0))
        
        self.storedWidth = width
    
    end

end