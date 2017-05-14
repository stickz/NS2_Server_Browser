local kLoaded = 14
local kBad = 7

-- require a quality score of 50 to stop displaying unknown in text
-- actual score is still indicated by color
kServerPerformanceDataUnknownQualityCutoff = 50

local kPerfIconIcons = {
    PrecacheAsset("ui/icons/smiley_good.dds"),
    PrecacheAsset("ui/icons/smiley_meh.dds"),
    PrecacheAsset("ui/icons/smiley_bad.dds")
}

local kPingIconTextures = {
   PrecacheAsset("ui/icons/ping_5.dds"),
   PrecacheAsset("ui/icons/ping_4.dds"),
   PrecacheAsset("ui/icons/ping_3.dds"),
   PrecacheAsset("ui/icons/ping_2.dds"),
   PrecacheAsset("ui/icons/ping_1.dds")
}

local kNormalPingPattern = { 60, 110, 180, 250,	999 }
local kLoadedPingPattern = { 55, 100, 165, 225, 999 }
local kBadPingPattern = { 50, 90, 150, 200, 999 }

function ServerPerformanceData.GetPerformanceIcon(numPlayers, quality, score)

	if quality >= kServerPerformanceDataUnknownQualityCutoff then
		local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
		
		-- Default to bad if server is loaded and not populated
		if numPlayers < 4 and score <= kLoaded then
			return kPerfIconIcons[3]		
		end		
		
		return score <= kBad and kPerfIconIcons[3] or score <= kLoaded and kPerfIconIcons[2] or kPerfIconIcons[1]
	end

    return kPerfIconIcons[1] -- default unknown populated servers to good
end

-- return Unknown if quality is below cutoff (before that, the color
-- of the text will still indicate score)
function ServerPerformanceData.GetPerformanceText(quality, score)
     if quality >= kServerPerformanceDataUnknownQualityCutoff then
        local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
		return 	 score <= kBad 	  and	Locale.ResolveString("SERVER_PERF_BAD") 	or
				 score <= kLoaded and 	Locale.ResolveString("SERVER_PERF_LOADED")  or 
										Locale.ResolveString("SERVER_PERF_GOOD")
    end
    
    return Locale.ResolveString("SERVER_PERF_UNKNOWN") -- return unknown if bellow quality cutoff
end

function ServerPerformanceData.GetLatency(ping, quality, score)
	local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
	return score <= kLoaded and (ping + 30) or score <= kBad and (ping + 50) or ping
end

function ServerPerformanceData.GetPingIcon(ping, quality, score)
    local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
	local array =    score <= kLoaded and kLoadedPingPattern or 
					 score <= kBad and kBadPingPattern or kNormalPingPattern	
		
	local pingTexture = nil
	
	for k, v in ipairs(array) do
		if ping < v then
			pingTexture = kPingIconTextures[k]
			break
		end
    end
	
	return pingTexture ~= nil and pingTexture or kPingIconTextures[5]
end