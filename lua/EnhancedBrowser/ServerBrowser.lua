local function CalculateSeverRanking(serverEntry)
    
    local exp = math.exp
    local sqrt = math.sqrt
    local players = serverEntry.numPlayers
    local maxplayer = serverEntry.maxPlayers - serverEntry.numRS

    local playerskill = Client.GetSkill()
    local playerlevel = Client.GetLevel()

    local viability = 1/(1 + exp( -0.5 * (players - 12)))
    local dViability = (201.714 * exp(0.5 * players))/(403.429 + exp(0.5 * players))^2
    local player = 0.5 * viability + 0.5 * dViability *  math.max(0, math.min(maxplayer, 24) - players - 1)

    local ping = 1 / (1 + exp( 1/40 * (serverEntry.ping - 150)))
    local skill = (players < 2 or playerskill == -1) and 1 or exp(- 0.1 * math.abs(serverEntry.playerSkill - playerskill) * sqrt(players - 1) / 346.41) -- 346.41 ~= 100*sqrt(12)

    local perfscore = serverEntry.performanceScore * serverEntry.performanceQuality / 100
    local perf = 1/(1 + exp( - perfscore / 5 ))

    local empty = players > 0 and 1 or 0.5
    local fav = serverEntry.favorite and 2 or 1
    local joinable = players < maxplayer and (not serverEntry.requiresPassword or serverEntry.favorite) and 1 or 0.02
    local friend = serverEntry.friendsOnServer and 1.1 or 1
    local ranked = serverEntry.mode == "ns2" and 1.2 or 1

    local rookieonly = joinable == 1 and 0.02 or 1
    if serverEntry.rookieOnly then
        if playerlevel == -1 or playerlevel < kRookieAllowedLevel then
            rookieonly = 1 + (1/exp(0.125*(playerlevel - kRookieOnlyLevel)))
        end
    else
        if playerlevel == -1 or playerlevel > kRookieOnlyLevel then
            rookieonly = 1
        end
    end

    -- rank servers the user has connected to less than 10 mins ago similair to empty ones
    local history = serverEntry.history and os.time() - serverEntry.lastConnect <= 600 and 0.5 or 1

    return player * ping * perf * skill * joinable * empty * fav * friend * rookieonly * ranked * history
end