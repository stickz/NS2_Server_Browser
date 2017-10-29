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

-- Start server browser up when game starts
function GUIMainMenu:MaybeOpenPopup()
    if not MainMenu_IsInGame() then
        self:MaybeAddChangelogPopup()
        self:MaybeAddNewItemPopup()
        self:MaybeAddLastStandMenu()
		self:OpenServerBrowser()
    end
end