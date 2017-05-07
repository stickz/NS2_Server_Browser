function GUIMainMenu:CreateServerListWindow()

    self.highlightServer = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.highlightServer:SetCSSClass("highlight_server")
    self.highlightServer:SetIgnoreEvents(true)
    self.highlightServer:SetIsVisible(false)
    
    self.blinkingArrow = CreateMenuElement(self.highlightServer, "Image")
    self.blinkingArrow:SetCSSClass("blinking_arrow")
    self.blinkingArrow:GetBackground():SetInheritsParentStencilSettings(false)
    self.blinkingArrow:GetBackground():SetStencilFunc(GUIItem.Always)
    
    self.selectServer = CreateMenuElement(self.playWindow:GetContentBox(), "Image")
    self.selectServer:SetCSSClass("select_server")
    self.selectServer:SetIsVisible(false)
    self.selectServer:SetIgnoreEvents(true)
    
    self.serverRowNames = CreateMenuElement(self.playWindow, "Table")
    self.serverList = CreateMenuElement(self.playWindow:GetContentBox(), "ServerList")
    
    -- Use a hack for now to partially realign the top bar
    local columnClassNames =
    {
        "rank",
        "favorite",
        "private",
        "servername",
        "game",
        "rate", -- map
        "players", --players
	"rate", -- hive
        "rate",
        "ping"
    }
    
    local rowNames = { { Locale.ResolveString("SERVERBROWSER_RANK"), 
						Locale.ResolveString("SERVERBROWSER_FAVORITE"), 
						Locale.ResolveString("SERVERBROWSER_PRIVATE"), 
						Locale.ResolveString("SERVERBROWSER_NAME"), 
						Locale.ResolveString("SERVERBROWSER_GAME"), 
						Locale.ResolveString("SERVERBROWSER_MAP"), 
						Locale.ResolveString("SERVERBROWSER_PLAYERS"),
						"HIVE", -- To Do: convert this to a translated locale
						Locale.ResolveString("SERVERBROWSER_PERF"), 
						Locale.ResolveString("SERVERBROWSER_PING") } }
    
    local serverList = self.serverList

    --Default sorting
    UpdateSortOrder(1)
    serverList:SetComparator(SortByRating, true)

    local entryCallbacks = {
        { OnClick = function() UpdateSortOrder(1) serverList:SetComparator(SortByRating, true) end },
        { OnClick = function() UpdateSortOrder(2) serverList:SetComparator(SortByFavorite) end },
        { OnClick = function() UpdateSortOrder(3) serverList:SetComparator(SortByPrivate) end },
        { OnClick = function() UpdateSortOrder(4) serverList:SetComparator(SortByName) end },
        { OnClick = function() UpdateSortOrder(5) serverList:SetComparator(SortByMode) end },
        { OnClick = function() UpdateSortOrder(6) serverList:SetComparator(SortByMap) end },
        { OnClick = function() UpdateSortOrder(7) serverList:SetComparator(SortByPlayers) end },
	{ OnClick = function() UpdateSortOrder(7) serverList:SetComparator(SortByPlayers) end }, -- To Do: Add hive skill sorting
        { OnClick = function() UpdateSortOrder(8) serverList:SetComparator(SortByPerformance) end },
        { OnClick = function() UpdateSortOrder(9) serverList:SetComparator(SortByPing) end }
    }
    
    self.serverRowNames:SetCSSClass("server_list_row_names")
    self.serverRowNames:AddCSSClass("server_list_names")
    self.serverRowNames:SetColumnClassNames(columnClassNames)
    self.serverRowNames:SetEntryCallbacks(entryCallbacks)
    self.serverRowNames:SetRowPattern( { SERVERBROWSER_RANK, 
						RenderServerNameEntry, 
						RenderServerNameEntry, 
						RenderServerNameEntry, 
						RenderServerNameEntry,
						RenderServerNameEntry, 
						RenderServerNameEntry, 
						RenderServerNameEntry, 
						RenderServerNameEntry, 
						RenderServerNameEntry, } )
    self.serverRowNames:SetTableData(rowNames)
    
    self.playWindow:AddEventCallbacks({
        OnShow = function()
            self.playWindow:ResetSlideBar()
            self:UpdateServerList()
        end
    })
    
    self:CreateFilterForm()
    self:CreatePlayFooter()
    
    self.serverTabs = CreateMenuElement(self.playWindow, "ServerTabs", true)
    self.serverTabs:SetCSSClass("main_server_tabs")
    self.serverTabs:SetServerList(self.serverList)

end
