local kGood = 15
local kOk = 9
local kLoaded = 3
local kBad = -9

-- require a quality score of 50 to stop displaying unknown in text
-- actual score is still indicated by color
kServerPerformanceDataUnknownQualityCutoff = 50

local kPerfIconIcons = {
    PrecacheAsset("ui/icons/smiley_good.dds"),
    PrecacheAsset("ui/icons/smiley_meh.dds"),
    PrecacheAsset("ui/icons/smiley_bad.dds")
}

function ServerPerformanceData.GetPerformanceIcon(quality, score)
    local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
    local result = score <= kLoaded and kPerfIconIcons[3] or score <= kOk and kPerfIconIcons[2] or kPerfIconIcons[1]
	
    -- Fix for unknown performance ratings, so they're not rated red
    if quality < kServerPerformanceDataUnknownQualityCutoff then
	result = kPerfIconIcons[2]
    end

    if dbgServerPerfData then
        Log("PerfText: Quality %s, Score %s, result %s", quality, score, result)
    end

    return result
end

-- return Unknown if quality is below cutoff (before that, the color
-- of the text will still indicate score)
function ServerPerformanceData.GetPerformanceText(quality, score)
    local result = Locale.ResolveString("SERVER_PERF_UNKNOWN")
    local score = score * quality / kServerPerformanceDataUnknownQualityCutoff
    if quality >= kServerPerformanceDataUnknownQualityCutoff then
        result = Locale.ResolveString(
            ( score <= kLoaded and "SERVER_PERF_BAD" or
            ( score <= kOk and "SERVER_PERF_LOADED" or
            ( score <= kGood and "SERVER_PERF_OK" or "SERVER_PERF_GOOD"))))
    end
    
    if dbgServerPerfData then
        Log("PerfText: Quality %s, Score %s, result %s", quality, score, result)
    end
    
    return result
end
