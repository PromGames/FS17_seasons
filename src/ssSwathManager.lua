---------------------------------------------------------------------------------------------------------
-- SWATH MANAGER SCRIPT
---------------------------------------------------------------------------------------------------------
-- Purpose:  To reduce swaths
-- Authors:  reallogger 
-- (very much based on ssSnow so thank you mrbear)
--

ssSwathManager = {}

function ssSwathManager:load(savegame, key)
end

function ssSwathManager:save(savegame, key)
end

function ssSwathManager:loadMap(name)
    g_seasons.environment:addGrowthStageChangeListener(self)
    g_currentMission.environment:addDayChangeListener(self)

    if g_currentMission:getIsServer() == true then
        ssDensityMapScanner:registerCallback("ssSwathManagerReduceSwaths", self, self.reduceSwaths)
    end
end

function ssSwathManager:reduceSwaths(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, layers)
    layers = tonumber(layers)
    local x,z, widthX,widthZ, heightX,heightZ = Utils.getXZWidthAndHeight(g_currentMission.terrainDetailHeightId, startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ)

    -- Remove grass swaths
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "equals", TipUtil.fillTypeToHeightType[FillUtil.FILLTYPE_GRASS_WINDROW]["index"])
    setDensityCompareParams(g_currentMission.terrainDetailHeightId, "greater", 0)
    addDensityMaskedParallelogram(g_currentMission.terrainDetailHeightId, x, z, widthX, widthZ, heightX, heightZ, 5, 6, g_currentMission.terrainDetailHeightId, 0, 5, -layers)
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "greater", -1)

    -- Mask areas that are covered by the snow mask.
    if ssSnow.snowMaskId ~= nil then
        setDensityMaskParams(g_currentMission.terrainDetailHeightId, "equals", 0)
        setDensityCompareParams(g_currentMission.terrainDetailHeightId, "equals", 0)
        setDensityMaskedParallelogram(g_currentMission.terrainDetailHeightId, x, z, widthX, widthZ, heightX, heightZ, 0, 5, ssSnow.snowMaskId, ssSnow.SNOW_MASK_FIRST_CHANNEL, ssSnow.SNOW_MASK_NUM_CHANNELS, TipUtil.fillTypeToHeightType[FillUtil.FILLTYPE_STRAW]["index"])
        setDensityMaskParams(g_currentMission.terrainDetailHeightId, "greater", -1)
        setDensityCompareParams(g_currentMission.terrainDetailHeightId, "greater", -1)
    end
    
     -- Remove straw swaths that are outside (the mask)
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "equals", TipUtil.fillTypeToHeightType[FillUtil.FILLTYPE_STRAW]["index"])
    addDensityMaskedParallelogram(g_currentMission.terrainDetailHeightId, x, z, widthX, widthZ, heightX, heightZ, 5, 6, g_currentMission.terrainDetailHeightId, 0, 5, -layers)
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "greater", -1)

    -- Remove hay (drygrass) swaths that are outside (the mask)
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "equals", TipUtil.fillTypeToHeightType[FillUtil.FILLTYPE_DRYGRASS_WINDROW]["index"])
    addDensityMaskedParallelogram(g_currentMission.terrainDetailHeightId, x, z, widthX, widthZ, heightX, heightZ, 5, 6, g_currentMission.terrainDetailHeightId, 0, 5, -layers)
    setDensityMaskParams(g_currentMission.terrainDetailHeightId, "greater", -1)

end

function ssSwathManager:dayChanged()
    ssDensityMapScanner:queuJob("ssSwathManagerReduceSwaths", 1)
end

function ssSwathManager:growthStageChanged()
    -- removing all swaths at beginning of winter
    if g_seasons.environment:currentGrowthTransition() == 10 then
        ssDensityMapScanner:queuJob("ssSwathManagerReduceSwaths", 64)
    end
end

function ssSwathManager:readStream(streamId, connection)
end

function ssSwathManager:writeStream(streamId, connection)
end

function ssSwathManager:update(dt)
end

