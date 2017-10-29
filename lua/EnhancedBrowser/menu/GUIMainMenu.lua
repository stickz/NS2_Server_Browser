-- Server Browser Code
local columnClassNames =
{
	"favorite",
	"servername",
	"game",
	"map",
	"players",
	"spectators",
	"hive",
	"rate",
	"ping"
}
    
local rowNames = { {Locale.ResolveString("SERVERBROWSER_FAVORITE"), 
					Locale.ResolveString("SERVERBROWSER_NAME"), 
					Locale.ResolveString("SERVERBROWSER_GAME"), 
					Locale.ResolveString("SERVERBROWSER_MAP"), 
					Locale.ResolveString("SERVERBROWSER_PLAYERS"),
					"SPECS",
					"HIVE",
					Locale.ResolveString("SERVERBROWSER_PERF"), 
					Locale.ResolveString("SERVERBROWSER_PING") } }

function GUIMainMenu:CreateServerListWindow()

    self.highlightServer = CreateMenuElement(self.serverBrowserWindow:GetContentBox(), "Image")
    self.highlightServer:SetCSSClass("highlight_server")
    self.highlightServer:SetIgnoreEvents(true)
    self.highlightServer:SetIsVisible(false)
    
    self.blinkingArrow = CreateMenuElement(self.highlightServer, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)
    
    self.selectServer = CreateMenuElement(self.serverBrowserWindow:GetContentBox(), "Image")
    self.selectServer:SetCSSClass("select_server")
    self.selectServer:SetIsVisible(false)
    self.selectServer:SetIgnoreEvents(true)
    
    self.serverRowNames = CreateMenuElement(self.serverBrowserWindow, "Table")
    self.serverList = CreateMenuElement(self.serverBrowserWindow:GetContentBox(), "ServerList")
    
    local serverList = self.serverList

    local entryCallbacks = {
        { OnClick = function() serverList:SetComparator(SortByFavorite, nil, 1) end },
        { OnClick = function() serverList:SetComparator(SortByName, nil, 2) end },
        { OnClick = function() serverList:SetComparator(SortByMode, nil, 3) end },
        { OnClick = function() serverList:SetComparator(SortByMap, nil, 4) end },
        { OnClick = function() serverList:SetComparator(SortByPlayers, nil, 5) end },
		{ OnClick = function() serverList:SetComparator(SortByPlayers, nil, 5) end },
		{ OnClick = function() serverList:SetComparator(SortByPlayers, nil, 5) end },
        { OnClick = function() serverList:SetComparator(SortByPerformance, nil, 6) end },
        { OnClick = function() serverList:SetComparator(SortByPing, nil, 7) end }
    }
	
	--Default sorting
    local selected =  Client.GetOptionInteger("currentServerBrowerComparator", 5)
    if selected < 1 or selected > #entryCallbacks - 2 then
        selected = 5
    end
    entryCallbacks[selected].OnClick()
    
    self.serverRowNames:SetCSSClass("server_list_row_names")
    self.serverRowNames:AddCSSClass("server_list_names")
    self.serverRowNames:SetColumnClassNames(columnClassNames)
    self.serverRowNames:SetEntryCallbacks(entryCallbacks)
    self.serverRowNames:SetRowPattern( {RenderServerNameEntry, 
										RenderServerNameEntry, 
										RenderServerNameEntry,
										RenderServerNameEntry, 
										RenderServerNameEntry, 
										RenderServerNameEntry, 
										RenderServerNameEntry, 
										RenderServerNameEntry,
										RenderServerNameEntry, } )
    self.serverRowNames:SetTableData(rowNames)
    
    self.serverBrowserWindow:AddEventCallbacks({
        OnShow = function()
            self.serverBrowserWindow:ResetSlideBar()
            self:UpdateServerList()
        end
    })
    
    self:CreateFilterForm()
    self:CreatePlayFooter()
    
    self.serverTabs = CreateMenuElement(self.serverBrowserWindow, "ServerTabs", true)
    self.serverTabs:SetCSSClass("main_server_tabs")
    self.serverTabs:SetServerList(self.serverList)
end

-- Override these functions to put the server browser button back
-- Remove annoying training link glow on training as an added bonus
local LinkOrder =
{
    { 13,4,6,7,10,11,12 },
    { 1,2,3,4,9,6,7,8 }
}

local LinkItems =
{
    [1] = { "MENU_RESUME_GAME", function(self)

            self.scriptHandle:SetIsVisible(not self.scriptHandle:GetIsVisible())

        end
    },
    [2] = { "MENU_GO_TO_READY_ROOM", function(self)
            
            self.scriptHandle:SetIsVisible(not self.scriptHandle:GetIsVisible())
            Shared.ConsoleCommand("rr")

        end, "readyroom"
    },
    [3] = { "MENU_VOTE", function(self)

            OpenVoteMenu()
            self.scriptHandle:SetIsVisible(false)

        end, "vote"
    },
    [4] = { "MENU_SERVER_BROWSER", function(self)
            
            self.scriptHandle:AttemptToOpenServerBrowser()

        end, "browser"
    },
    [5] = { "MENU_ORGANIZED_PLAY", function(self)

            self.scriptHandle:ActivateGatherWindow()

        end
    },
    [6] = { "MENU_OPTIONS", function(self)

            if not self.scriptHandle.optionWindow then
                self.scriptHandle:CreateOptionWindow()
            end
            self.scriptHandle:TriggerOpenAnimation(self.scriptHandle.optionWindow)
            self.scriptHandle:HideMenu()

        end, "options"
    },
    [7] = { "MENU_CUSTOMIZE_PLAYER", function(self)

            self.scriptHandle:ActivateCustomizeWindow()
            self.scriptHandle.screenFade = GetGUIManager():CreateGUIScript("GUIScreenFade")
            self.scriptHandle.screenFade:Reset()

        end, "customize"
    },
    [8] = { "MENU_DISCONNECT", function(self)

            self.scriptHandle:HideMenu()

            Shared.ConsoleCommand("disconnect")

            self.scriptHandle:ShowMenu()

        end, "disconnect"
    },
    [9] = { "MENU_TRAINING", function(self)

            self.scriptHandle:OpenTraining()

        end, "training"
    },
    [10] = { "MENU_MODS", function(self)
            
            if not self.scriptHandle.modsWindow then
                self.scriptHandle:CreateModsWindow()
            end            
            self.scriptHandle.modsWindow.sorted = false
            self.scriptHandle:TriggerOpenAnimation(self.scriptHandle.modsWindow)
            self.scriptHandle:HideMenu()

        end, "mods"
    },
    [11] = { "MENU_CREDITS", function(self)

            self.scriptHandle:HideMenu()
            self.creditsScript = GetGUIManager():CreateGUIScript("menu/GUICredits")
            MainMenu_OnPlayButtonClicked()
            self.creditsScript:SetPlayAnimation("show")
            self.creditsScript.closeEvent:AddHandler( self, function() self.scriptHandle:ShowMenu() end)

        end, "credits"
    },
    [12] = { "MENU_EXIT", function()

            Client.Exit()
            
            if Sabot.GetIsInGather() then
                Sabot.QuitGather()
            end

        end, "exit"
    },
    [13] = { "MENU_PLAY", function(self)

            MainMenu_OnPlayButtonClicked() --Play click sound

            self.scriptHandle:HideMenu()
            self.scriptHandle.playScreen:Show()
            
        end,
    }
}

function GUIMainMenu:CreateMainLinks()    
    local index = MainMenu_IsInGame() and 2 or 1
    local linkOrder = LinkOrder[index]
    for i=1, #linkOrder do
        local linkId = linkOrder[i]
        local text = LinkItems[linkId][1]
        local callbackTable = LinkItems[linkId][2]
		local event = LinkItems[linkId][3]
		if event then
			event = ( MainMenu_IsInGame() and "igmenu_" or "menu_" ) .. event
			callbackTable = RecordEventWrap( callbackTable, event )			
		end
        local link = self:CreateMainLink(text, i, callbackTable)
        table.insert(self.Links, link)
    end    
end

function GUIMainMenu:CreateMainLink(text, linkNum, OnClick)
    
    local cssClass = MainMenu_IsInGame() and "ingame" or "mainmenu"  
    local mainLink = CreateMenuElement(self.menuBackground, "Link")
    mainLink:SetText(Locale.ResolveString(text))
    mainLink.originalText = text
    mainLink:SetCSSClass(cssClass)
    mainLink:SetTopOffset(50 + 70 * linkNum )
    mainLink:SetBackgroundColor(Color(1,1,1,0))
    mainLink:EnableHighlighting()
    
    mainLink.linkIcon = CreateMenuElement(mainLink, "Font")
    local linkNumText = string.format("%s%s", linkNum < 10 and "0" or "", linkNum)
    mainLink.linkIcon:SetText(linkNumText)
    mainLink.linkIcon:SetCSSClass(cssClass)
    mainLink.linkIcon:SetTextColor(Color(1,1,1,0))
    mainLink.linkIcon:EnableHighlighting()
    mainLink.linkIcon:SetBackgroundColor(Color(1,1,1,0))
  
	local parent = self
	local isPlayNow = ( text == "MENU_PLAY_NOW" )
    local eventCallbacks =
    {
        OnMouseIn = function (self, buttonPressed)
            MainMenu_OnMouseIn()
        end,
        
        OnMouseOver = function (self, buttonPressed)        
            self.linkIcon:OnMouseOver(buttonPressed)
        end,
        
        OnMouseOut = function (self, buttonPressed)
            self.linkIcon:OnMouseOut(buttonPressed) 
            MainMenu_OnMouseOut()
        end
    }
    
    mainLink:AddEventCallbacks(eventCallbacks)
    local callbackTable =
    {
        OnClick = OnClick
    }
    mainLink:AddEventCallbacks(callbackTable)
    
    return mainLink    
end

-- Start server browser up when game starts
function GUIMainMenu:MaybeOpenPopup()
    if not MainMenu_IsInGame() then
        self:MaybeAddChangelogPopup()
        self:MaybeAddNewItemPopup()
        self:MaybeAddLastStandMenu()
		self:OpenServerBrowser()
    end
end