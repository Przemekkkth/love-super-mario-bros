Map = Object:extend()

function Map:new()
    self.BlockIDCoordinates = {}
    self.PlayerIDCoordinates = {}
    self.EnemyIDCoordinates = {}
    self.DeadEnemyIDCoordinates = {}
    self.IrregularBlockReferences = {}
end

function Map:new(dataPath)
    self.BlockIDCoordinates = {}
    self.PlayerIDCoordinates = {}
    self.EnemyIDCoordinates = {}
    self.DeadEnemyIDCoordinates = {}
    self.IrregularBlockReferences = {}
    if dataPath ~= '' and dataPath ~= nil then 
        self:loadMap(dataPath)
    end
end

function Map:getBlockCoord(id)
    return self.BlockIDCoordinates[id]
end

function Map:getPlayerCoord(id)
    return self.PlayerIDCoordinates[id]
end

function Map:getEnemyCoord(id)
    return self.EnemyIDCoordinates[id]
end

function Map:loadMap(dataPath)
    local levelData = {}
    self.levelData = nil
    -- Open the file
    local file = love.filesystem.newFile(dataPath, "r")
    if file then
        file:open("r")
        for line in file:lines() do
            local row = {}
            for word in line:gmatch("([^,]+)") do
                table.insert(row, tonumber(word))
            end
            table.insert(levelData, row)
        end
        file:close()
    else
        error("Could not open file: " .. dataPath)
    end

    self.levelData = levelData
end

function Map:clear()
    self.levelData = {}
end

function Map:loadBlockIDS()
    local blockID = 0
    for i = 0, 21 do
        for j = 0, 47 do
            self.BlockIDCoordinates[blockID] = {x = j, y = i}
            blockID = blockID + 1
        end
    end
end

function Map:loadPlayerIDS()
    local playerID = 0
    for i = 0, 15 do
        for j = 0, 24 do
            self.PlayerIDCoordinates[playerID] = {x = j, y = i}
            playerID = playerID + 1
        end
    end
end

function Map:loadEnemyIDS()
    local enemyID = 0
    for i = 0, 14 do
        for j = 0, 34 do
            self.EnemyIDCoordinates[enemyID] = {x = j, y = i}
            enemyID = enemyID + 1
        end
    end
end

function Map:loadIrregularBlockReferences()
    local path = "assets/sprites/blocks/IrregularReferences.blockmap"
    
    -- Open the file
    local file, err = love.filesystem.newFile(path, "r")
    if not file then
        error("Could not open file: " .. err)
    end
    
    for line in file:lines() do
        -- Match a pair of integers separated by a comma
        local blockID, referenceID = line:match("(%d+),%s*(%d+)")
        if blockID and referenceID then
            -- Convert to numbers and store in the table
            blockID = tonumber(blockID)
            referenceID = tonumber(referenceID)

            self.IrregularBlockReferences[blockID] = referenceID
        end
    end

    file:close()
end

function Map:getLevelData()
    return self.levelData
end

function Map:getIrregularBlockReferences()
    return self.IrregularBlockReferences
end

function Map:getBlockIDCoordinates()
    return self.BlockIDCoordinates
end

function Map:getEnemyIDCoordinates()
    return self.EnemyIDCoordinates
end