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
    
    local columnClassNames =
    {
        "favorite",
        "servername",
        "game",
        "map",
        "players",
<<<<<<< HEAD
		"hive",
=======
	"hive",
>>>>>>> origin/master
        "rate",
        "ping"
    }
    
    local rowNames = { {Locale.ResolveString("SERVERBROWSER_FAVORITE"), 
						Locale.ResolveString("SERVERBROWSER_NAME"), 
						Locale.ResolveString("SERVERBROWSER_GAME"), 
						Locale.ResolveString("SERVERBROWSER_MAP"), 
						Locale.ResolveString("SERVERBROWSER_PLAYERS"),
						"HIVE",
						Locale.ResolveString("SERVERBROWSER_PERF"), 
						Locale.ResolveString("SERVERBROWSER_PING") } }
    
    local serverList = self.serverList

    --Default sorting
    UpdateSortOrder(7)
    serverList:SetComparator(SortByPlayers, false)

    local entryCallbacks = {
        { OnClick = function() UpdateSortOrder(1) serverList:SetComparator(SortByFavorite) end },
        { OnClick = function() UpdateSortOrder(2) serverList:SetComparator(SortByName) end },
        { OnClick = function() UpdateSortOrder(3) serverList:SetComparator(SortByMode) end },
        { OnClick = function() UpdateSortOrder(4) serverList:SetComparator(SortByMap) end },
        { OnClick = function() UpdateSortOrder(5) serverList:SetComparator(SortByPlayers) end },
		{ OnClick = function() UpdateSortOrder(5) serverList:SetComparator(SortByPlayers) end },
        { OnClick = function() UpdateSortOrder(6) serverList:SetComparator(SortByPerformance) end },
        { OnClick = function() UpdateSortOrder(7) serverList:SetComparator(SortByPing) end }
    }
    
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
