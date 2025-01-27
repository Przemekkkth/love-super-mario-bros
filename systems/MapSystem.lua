MapSystem = Concord.system()

function MapSystem:init(world) --onAddedToWorld(world))

end

function MapSystem:setScene(scene)
    self.scene = scene
end

function MapSystem:loadEntities()
    local world = self:getWorld()
    local backgroundMap = self.scene:getBackgroundMap()
    for i = 1, #backgroundMap:getLevelData() do
        for j = 1, #backgroundMap:getLevelData()[1] do
            local entityID = backgroundMap:getLevelData()[i][j]
            local referenceID = self:getReferenceBlockID(entityID)

            if referenceID ~= -1 and referenceID ~= 391 and referenceID ~= 393 then
                local entity = Concord.entity(world)
                entity:give('position', {x = (j - 1) * SCALED_CUBE_SIZE, y = (i - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
                entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID) )
                entity:give('background')
            end
        end
    end

    local undergroundMap = self.scene:getUndergroundMap()
    for i = 1, #undergroundMap:getLevelData() do
        for j = 1, #undergroundMap:getLevelData()[1] do
            local entityID = undergroundMap:getLevelData()[i][j]
            local referenceID = self:getReferenceBlockID(entityID)
            self:createForegroundEntities(j, i, entityID, referenceID, false) -- TO DO why shouldn't be true ?
        end
    end

    self:addPlatformsLevel()

    local foregroundMap = self.scene:getForegroundMap()
    for i = 1, #foregroundMap:getLevelData() do
        for j = 1, #foregroundMap:getLevelData()[1] do
            local entityID = foregroundMap:getLevelData()[i][j]
            local referenceID = self:getReferenceBlockID(entityID)
            self:createForegroundEntities(j, i, entityID, referenceID, true)
        end
    end

    self:createFireBarEntities()

    local enemyMap = self.scene:getEnemiesMap()
    for i = 1, #enemyMap:getLevelData() do
        for j = 1, #enemyMap:getLevelData()[1] do
            local entityID = enemyMap:getLevelData()[i][j]
            local referenceID = self:getReferenceEnemyID(entityID)
            if entityID ~= -1 or entityID ~= 73 or entityID ~= 83 or entityID ~= 85 or entityID ~= 85 or entityID ~= 91 or
                entityID ~= 490 or entityID ~= 492 or entityID ~= 496 then
                    self:createEnemyEntities(j, i, entityID, referenceID)
            end
        end
    end

    local aboveForegroundMap = self.scene:getAboveForegroundMap()
    for i = 1, #aboveForegroundMap:getLevelData() do
        for j = 1, #aboveForegroundMap:getLevelData()[1] do
            local entityID = aboveForegroundMap:getLevelData()[i][j]
            local referenceID = self:getReferenceBlockID(entityID)
            if referenceID == 150 or referenceID == 292 then -- WARP Pipe
                local entity = Concord.entity(world)
                entity:give('position', {x = (j-1) * SCALED_CUBE_SIZE, y = (i - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
                entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                    ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID))
                local warpPipeLocations = self.scene:getLevelData().warpPipeLocation
                --[ {"pipe_coords": [57, 9], "teleport_coords": [2, 20], "camera_coords": [0, 18], "going_in": "DOWN", "going_out": "NONE", "freeze_camera": true, "bg_color": "BLACK", "level_type": "UNDERGROUND", "level_to_go": [0, 0]} ]
                local position = entity.position
                for key, warpPipeLocation in ipairs(warpPipeLocations) do
                    if (j - 1) == warpPipeLocation.pipe_coords[1] and (i - 1) == warpPipeLocation.pipe_coords[2] then
                        if warpPipeLocation.going_in ~= "NONE" then
                            local playerCoordinates = {x = warpPipeLocation.teleport_coords[1], y = warpPipeLocation.teleport_coords[2] }
                            local cameraCoordinates = {x = warpPipeLocation.camera_coords[1], y = warpPipeLocation.camera_coords[2] }
                            local inDirection = Level:convertDirectionTextToType(warpPipeLocation.going_in)
                            local outDirection = Level:convertDirectionTextToType(warpPipeLocation.going_out)
                            local cameraFreeze = warpPipeLocation.freeze_camera
                            local color = Level:convertBGColorTextToType(warpPipeLocation.bg_color)
                            local levelType = Level:convertLevelTextToType(warpPipeLocation.level_type)
                            local newLevel = {x = warpPipeLocation.level_to_go[1], y = warpPipeLocation.level_to_go[2] }

                            entity:give('warp_pipe_component', playerCoordinates, cameraCoordinates,
                                                               inDirection, outDirection, cameraFreeze,
                                                               color, levelType, newLevel)

                            if inDirection == DIRECTION.UP then
                                position.hitbox.x = 32
                                position.hitbox.w = 0
                            elseif inDirection == DIRECTION.DOWN then
                                position.hitbox.x = 32
                                position.hitbox.w = 0
                            elseif inDirection == DIRECTION.LEFT then
                                position.hitbox.y = 32
                                position.hitbox.h = 0
                            elseif inDirection == DIRECTION.RIGHT then    
                                position.hitbox.y = 32
                                position.hitbox.h = 0
                            end
                        end
                    end
                end

                entity:give('above_foreground')
            elseif referenceID ~= -1 then
                local entity = Concord.entity(world)
                entity:give('position', {x = (j-1) * SCALED_CUBE_SIZE, y = (i-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
                entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                    ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID))
                entity:give('above_foreground')
            end

        end
    end

    for _, floatingText in ipairs(self.scene:getLevelData().floatingTextLocations) do
        local text = Concord.entity(world)
        text:give('position', {x = floatingText.pos[1] * SCALED_CUBE_SIZE, y = floatingText.pos[2] * SCALED_CUBE_SIZE})
        text:give('text', floatingText.text, 16, true)
        text:give('floating_text')
    end
    -- Set the camera max (i don't know where to put this)
    CameraInstance:setCameraMaxX(self.scene:getLevelData():getCameraMax() * SCALED_CUBE_SIZE)
end

--Gets the Block ID that is equivalent to its ID in the Overworld
function MapSystem:getReferenceBlockID(entityID)
    if entityID == -1 then
        return -1
    end

    local irregularBlockReferences = MapInstance:getIrregularBlockReferences()
    if irregularBlockReferences[entityID] ~= nil then
        return irregularBlockReferences[entityID]
    end

    local blockIDCoordinate = MapInstance:getBlockIDCoordinates()[entityID]
    local coordinateX = blockIDCoordinate.x 
    local coordinateY = blockIDCoordinate.y

    if coordinateY > 10 and blockIDCoordinate.x < 32 then
        coordinateY = coordinateY - 11
    end

    if coordinateX > 15 and coordinateX < 32 then
        coordinateX = coordinateX - 16
    elseif coordinateX > 32 and blockIDCoordinate.y < 10 then
        coordinateX = coordinateX - 32
    end

    for key, blockIDCoord in ipairs(MapInstance:getBlockIDCoordinates()) do
        if (blockIDCoord.x == coordinateX) and (blockIDCoord.y == coordinateY) then
            return key
        end
    end

    return -1
end

function MapSystem:createForegroundEntities(coordinateX, coordinateY, entityID, referenceID, createInvisibleBlocks)
    local world = self:getWorld()
    local collectiblesMap = self.scene:getCollectiblesMap()
    if referenceID == -1 then
        if createInvisibleBlocks and collectiblesMap:getLevelData()[coordinateY][coordinateX] ~= -1 then
            local entity = self:createBlockEntity(coordinateX, coordinateY, 53)
            entity:give('invisible_block_component')
            entity:give('bumpable_component')

            local collectibleType = MYSTERY_BOX_TYPE.NONE
            local collectibleID = collectiblesMap:getLevelData()[coordinateY][coordinateX]
            local referenceCollectibleID = self:getReferenceBlockID(collectibleID)
            local blankBlockID

            if collectibleID ~= 608 then
                blankBlockID = self:getReferenceBlockIDAsEntity(collectibleID, 53)
            else
                local levelType = self.scene:getLevelData().levelType
                if levelType == LEVEL_TYPE.UNDERGROUND or levelType == LEVEL_TYPE.START_UNDERGROUND then
                    blankBlockID = 69
                elseif levelType == LEVEL_TYPE.CASTLE then
                    blankBlockID = 581
                else
                    blankBlockID = 53
                end
            end

            if referenceCollectibleID == 52 then
                collectibleType = MYSTERY_BOX_TYPE.ONE_UP
            elseif referenceCollectibleID == 96 then
                collectibleType = MYSTERY_BOX_TYPE.SUPER_STAR
            elseif referenceCollectibleID == 144 then
                collectibleType = MYSTERY_BOX_TYPE.COINS
            elseif referenceCollectibleID == 608 then
                collectibleType = MYSTERY_BOX_TYPE.MUSHROOM
            end

            if collectibleType ~= MYSTERY_BOX_TYPE.NONE then
                entity:give('mystery_box_component', collectibleType)
                self:addItemDispenser(entity, blankBlockID, 53);
            end
        end
    elseif referenceID == 144 or referenceID == 176 then -- COIN
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', BLOCK_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
                ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                MapInstance:getBlockCoord(entityID))
        
        entity:give('animation_component', 
                    {entityID, entityID + 1, entityID + 2, entityID + 3}, --frameIDs
                    8,                                   --framesPerSecond
                    MapInstance.BlockIDCoordinates)      --coordinateSupplier
        entity:give('pause_animation_component', 1, 25)
        entity:give('collectible', COLLECTIBLE_TYPE.COIN)
    elseif referenceID == 63 then -- BULLET BILL CANNON
        local entity = self:createBlockEntity(coordinateX, coordinateY, entityID)
        local bulletBillID
        if entityID == 63 then -- Overworld
            bulletBillID = 90
        elseif entityID == 79 then -- Underground
            bulletBillID = 195
        elseif entityID == 95 then -- Underwater
            bulletBillID = 300
        elseif entityID == 591 then -- Castle
            bulletBillID = 405
        else
            bulletBillID = 90
        end
           
        entity:give('timer_component', function(entity) 
            if not CameraInstance:inCameraRange(entity.position) then
                return
            end

            local bulletBill = Concord.entity(world)
            local randomDirection = math.random(0, 1) == 1
            local intRandomDirection= randomDirection and 1 or 0  
            bulletBill:give('position', {x = ((coordinateX - 1) + (intRandomDirection * 2 - 1)) * SCALED_CUBE_SIZE,
                                         y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            bulletBill:give('texture', ENEMY_TILESHEET_IMG, randomDirection, false)
            bulletBill.texture:setHorizontalFlipped(randomDirection)
            bulletBill:give('spritesheet', bulletBill.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0, ORIGINAL_CUBE_SIZE,
                                                               ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(bulletBillID + 26) )
            local xVelocity = randomDirection and 3.0 or -3.0
            bulletBill:give('moving_component', {x = xVelocity, y = 0}, {x = 0, y = 0})
            bulletBill:give('destroy_outside_camera_component')
            bulletBill:give('friction_exempt_component')
            bulletBill:give('particle')
            
            local cannonSound = Concord.entity(world)
            cannonSound:give('sound_component', SOUND_ID.CANNON_FIRE)

            bulletBill:give('crushable_component', function(entity)
                entity.moving_component.velocity.x = 0
                entity:give('dead_component')
                entity:give('gravity_component')
            end)

            bulletBill:give('enemy', ENEMY_TYPE.BULLET_BILL)
        end, 4 * MAX_FPS)
    elseif referenceID == 149 or referenceID == 101 then -- FLAG POLE
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', BLOCK_TILESHEET_IMG, false, false)   
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                       ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID) )
        entity:give('foreground')
        entity:give('flag_pole_component')
    elseif referenceID == 152 then -- FLAG
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE + SCALED_CUBE_SIZE / 2, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', BLOCK_TILESHEET_IMG, false, false)   
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                       ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID) )
        
        entity:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
        entity:give('foreground')
        entity:give('flag_component')
    elseif referenceID == 192 then -- QUESTION BLOCK   
        local entity = self:createBlockEntity(coordinateX, coordinateY, entityID)
        entity:give('animation_component', 
            {entityID, entityID + 1, entityID + 2, entityID + 3}, --frameIDs
             8,                                   --framesPerSecond
            MapInstance.BlockIDCoordinates)      --coordinateSupplier
        
        entity:give('pause_animation_component', 1, 25)
        entity:give('bumpable_component')

        
        local collectibleType = MYSTERY_BOX_TYPE.COINS
        local collectibleID = collectiblesMap:getLevelData()[coordinateY][coordinateX]
        if collectibleID ~= -1 then
            local referenceCollectibleID = self:getReferenceBlockID(collectibleID)
            if referenceCollectibleID == 52 then
                collectibleType = MYSTERY_BOX_TYPE.ONE_UP
            elseif referenceCollectibleID == 96 then
                collectibleType = MYSTERY_BOX_TYPE.SUPER_STAR
            elseif referenceCollectibleID == 144 then
                collectibleType = MYSTERY_BOX_TYPE.COINS
            elseif referenceCollectibleID == 608 then
                collectibleType = MYSTERY_BOX_TYPE.MUSHROOM     
            end
        end

        if collectibleType ~= MYSTERY_BOX_TYPE.NONE then
            entity:give('mystery_box_component', collectibleType)
            self:addItemDispenser(entity, entityID, referenceID)
        end
    elseif referenceID == 240 then -- AXE  
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                   ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID) )
        entity:give('animation_component', 
                        {entityID, entityID + 1, entityID + 2, entityID + 3}, --frameIDs
                        8,                                   --framesPerSecond
                        MapInstance.BlockIDCoordinates)      --coordinateSupplier
                                               
        entity:give('pause_animation_component', 1, 25)
        entity:give('foreground')
        entity:give('axe_component')
    elseif referenceID == 289 or referenceID == 290 then -- BRICKS
        local entity = self:createBlockEntity(coordinateX, coordinateY, entityID)
        local debrisID = self:getReferenceBlockIDAsEntity(entityID, 291)
        entity:give('destructible_component', MapInstance:getBlockCoord(debrisID))
        entity:give('bumpable_component')
        local boxType = MYSTERY_BOX_TYPE.NONE
        local collectibleID = collectiblesMap:getLevelData()[coordinateY][coordinateX]
        if collectibleID ~= MYSTERY_BOX_TYPE.NONE then
            local referenceCollectibleID = self:getReferenceBlockID(collectibleID)
            if referenceCollectibleID == 52 then
                boxType = MYSTERY_BOX_TYPE.ONE_UP
            elseif referenceCollectibleID == 96 then
                boxType = MYSTERY_BOX_TYPE.SUPER_STAR
            elseif referenceCollectibleID == 144 then
                boxType = MYSTERY_BOX_TYPE.COINS
            elseif referenceCollectibleID == 148 then
                boxType = MYSTERY_BOX_TYPE.VINES
            elseif referenceCollectibleID == 608 then
                boxType = MYSTERY_BOX_TYPE.MUSHROOM
            end
        end

        if boxType ~= MYSTERY_BOX_TYPE.NONE then
            entity:give('mystery_box_component', boxType)
            self:addItemDispenser(entity, entityID, referenceID)
        end
    elseif referenceID == 339 then -- BRIDGE CHAIN (this is here so it gets destroyed with the bridge
        if self.scene:getLevelData():getLevelType() == LEVEL_TYPE.CASTLE then
            local bridgeChain = self:createBlockEntity(coordinateX, coordinateY, entityID)
            bridgeChain:give('bridge_chain')
        else
            self:createBlockEntity(coordinateX, coordinateY, entityID)
        end
    elseif referenceID == 346 then -- TRAMPOLINE
        local trampolineTop = self:createBlockEntity(coordinateX, coordinateY, entityID)
        local trampolineBottom = self:createBlockEntity(coordinateX, coordinateY + 1, entityID + 48)
        trampolineBottom:remove('tile_component')
        trampolineTop:give('trampoline_component', trampolineBottom, {entityID, entityID + 1, entityID + 2}, {entityID + 48, entityID + 1 + 48, entityID + 2 + 48})
    elseif referenceID == 392 then -- BRIDGE
        if self.scene:getLevelData():getLevelType() == LEVEL_TYPE.CASTLE then
            if self:getReferenceBlockID(self.scene:getForegroundMap():getLevelData()[coordinateY][coordinateX - 1]) ~= 392 then
                local bridge = self:createBlockEntity(coordinateX, coordinateY, entityID)
                bridge:give('bridge_component')
                local bridgeComponent = bridge.bridge_component
                table.insert(bridgeComponent.connectedBridgeParts, bridge)
                local futureCoordinateCheck = coordinateX + 1
                while self:getReferenceBlockID(self.scene:getForegroundMap():getLevelData()[coordinateY][futureCoordinateCheck]) == 392 do
                    local connectedBridge = self:createBlockEntity(futureCoordinateCheck, coordinateY, entityID)
                    table.insert(bridgeComponent.connectedBridgeParts, connectedBridge)
                    futureCoordinateCheck = futureCoordinateCheck + 1
                end
            end
        else
            self:createBlockEntity(coordinateX, coordinateY, entityID)
        end
    elseif referenceID == 609 then -- MOVING PLATFORM
        self:createBlockEntity(coordinateX, coordinateY, entityID)
    elseif referenceID == 761 then -- MOVING PLATFORM (2 wide)
        for _, movingPlatformDirection in ipairs(self.scene:getLevelData().movingPlatformDirections) do
            local platformX = movingPlatformDirection.coords[1]
            local platformY = movingPlatformDirection.coords[2]
            if (coordinateX-1) == platformX and (coordinateY-1) == platformY then
                self:createPlatformEntity(coordinateX, coordinateY, entityID, 2, movingPlatformDirection)
            end
        end
        if #self.scene:getLevelData().movingPlatformDirections == 0 then
            local platform = Concord.entity(world)
            platform:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = 2 * SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            platform:give('texture', BLOCK_TILESHEET_IMG)
            platform:give('spritesheet', platform.texture, ORIGINAL_CUBE_SIZE * 2, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                           ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID))
            platform:give('foreground')
            platform:give('tile_component')
        end
    elseif referenceID == 762 then -- MOVING PLATFORM (2 wide)
    elseif referenceID == 809 then -- MOVING PLATFORM (3 wide)
        local platformData = nil
        for _, movingPlatformDirection in ipairs(self.scene:getLevelData().movingPlatformDirections) do
            if movingPlatformDirection.coords[1] == (coordinateX-1) and movingPlatformDirection.coords[2] == (coordinateY-1) then
                platformData = movingPlatformDirection
            end
        end

        if platformData == nil then
            return
        end

        local motionType = Level:convertMotionTextToType(platformData.motion)
        if motion ~= PLATFORM_MOTION_TYPE.NONE then
            self:createPlatformEntity(coordinateX, coordinateY, entityID, 3, platformData)
            return
        end
    elseif referenceID == 810 or referenceID == 811 then
        -- To Do: check length of platform
    elseif referenceID == 857 or referenceID == 610 then -- CLOUD PLATFORM
        if referenceID == 610 then
            entityID = 857
        end
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE}, {x = 3 * SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', BLOCK_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE * 3, ORIGINAL_CUBE_SIZE, 1,
                                                   1, 1, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                    MapInstance:getBlockCoord(entityID))
        entity:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
        entity:give('friction_exempt_component')
        entity:give('wait_until_component', 
        function(entity)
            return entity:has('top_collision_component')
        end,
        function(entity)
            entity.moving_component.velocity.x = 2.0
            entity:remove('wait_until_component')
        end)

        entity:give('foreground')
        entity:give('tile_component')
    elseif referenceID == 858 or referenceID == 859 then
        -- To Do investigate(cloud platform)
    else
        self:createBlockEntity(coordinateX, coordinateY, entityID)
    end
end

function MapSystem:createBlockEntity(coordinateX, coordinateY, entityID)
    local world = self:getWorld()
    local entity = Concord.entity(world)
    entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
    entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
                                               ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                               MapInstance:getBlockCoord(entityID))
    entity:give('foreground')  
    entity:give('tile_component')
    
    return entity
end

function MapSystem:getReferenceBlockIDAsEntity(entityID, referenceID)
    if entityId == -1 then
        return -1
    end

    local entityCoordinates = MapInstance:getBlockIDCoordinates()[entityID]
    local referenceCoordinates = MapInstance:getBlockIDCoordinates()[referenceID]

    local entityCoordinateX = entityCoordinates.x
    local entityCoordinateY = entityCoordinates.y

    local referenceCoordinateX = referenceCoordinates.x
    local referenceCoordinateY = referenceCoordinates.y

    if entityCoordinateY > 10 then
        referenceCoordinateY = referenceCoordinateY + 11
    end

    if entityCoordinateX > 15 and entityCoordinateX < 32 then
        referenceCoordinateX = referenceCoordinateX + 16
    elseif entityCoordinateX >= 32 then
        referenceCoordinateX = referenceCoordinateX - 32 
    end

    for key, blockIDCoord in ipairs(MapInstance:getBlockIDCoordinates()) do
        if (blockIDCoord.x == referenceCoordinateX) and (blockIDCoord.y == referenceCoordinateY) then
            return key
        end
    end

    return -1
end

function MapSystem:addItemDispenser(entity, entityID, referenceID)
    local world = self:getWorld()
    local mysteryBox = entity.mystery_box_component
    local blockTexture = BLOCK_TILESHEET_IMG
    local deactivatedID = self:getReferenceBlockIDAsEntity(entityID, 196)
    mysteryBox.deactivatedCoordinates = MapInstance:getBlockCoord(deactivatedID)
    if mysteryBox.type == MYSTERY_BOX_TYPE.MUSHROOM then
        mysteryBox.whenDispensed = function(originalBlock) 
            local dispenseSound = Concord.entity(world)
            dispenseSound:give('sound_component', SOUND_ID.POWER_UP_APPEAR)

            local player = world:getSystem(PlayerSystem):getMario().player

            if player.playerState ~= PLAYER_STATE.SMALL_MARIO then 
                local fireFlower = Concord.entity(world)
                local position   = originalBlock.position
                local yOffset = -4 -- add to avoid collison during brick bumps
                fireFlower:give('position', {x = position.position.x, y = position.position.y + yOffset}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                local flowerID = self:getReferenceBlockIDAsEntity(entityID, 48)
                fireFlower:give('texture', BLOCK_TILESHEET_IMG)
                fireFlower:give('spritesheet', fireFlower.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                               ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(flowerID))

                fireFlower:give('animation_component', 
                                {flowerID, flowerID + 1, flowerID + 2, flowerID + 3}, --frameIDs
                                 8,                                   --framesPerSecond
                                 MapInstance.BlockIDCoordinates)      --coordinateSupplier
                
                fireFlower:give('collectible', COLLECTIBLE_TYPE.FIRE_FLOWER)
                fireFlower:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
                fireFlower:give('collision_exempt_component')
                fireFlower:give('wait_until_component', 
                    function(entity)
                        return position:getTop() > entity.position:getBottom()
                    end,
                    function(entity)
                        entity:give('gravity_component')
                        entity.moving_component.velocity.y = 0
                        entity:remove('collision_exempt_component')
                        entity:remove('wait_until_component')
                    end)
            else
                local mushroom = Concord.entity(world)
                local position   = originalBlock.position
                local yOffset = -4 -- add to avoid collison during brick bumps
                mushroom:give('position', {x = position.position.x, y = position.position.y + yOffset}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                local flowerID = self:getReferenceBlockIDAsEntity(entityID, 48)
                mushroom:give('texture', BLOCK_TILESHEET_IMG)
                mushroom:give('spritesheet', mushroom.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                               ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(608))
                
                mushroom:give('collectible', COLLECTIBLE_TYPE.MUSHROOM)
                mushroom:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
                mushroom:give('collision_exempt_component')
                mushroom:give('wait_until_component', 
                    function(entity)
                        return position:getTop() > entity.position:getBottom()
                    end,
                    function(entity)
                        entity:give('gravity_component')
                        entity.moving_component.velocity.x = COLLECTIBLE_SPEED
                        entity:remove('collision_exempt_component')
                        entity:remove('wait_until_component')
                    end)
            end
        end
    elseif mysteryBox.type == MYSTERY_BOX_TYPE.COINS then
        mysteryBox.whenDispensed = function(originalBlock)
            local coinSound = Concord.entity(world)
            coinSound:give('sound_component', SOUND_ID.COIN)
            local addScore = Concord.entity(world)
            addScore:give('add_score_component', 100, true)

            local floatingText = Concord.entity(world)
            floatingText:give('create_floating_text_component', originalBlock, tostring(100))

            local coin = Concord.entity(world)
            local position = originalBlock.position
            coin:give('position', {x = position.position.x, y = position.position.y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            coin:give('texture', BLOCK_TILESHEET_IMG)
            coin:give('spritesheet', coin.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1,
                                                1, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                MapInstance:getBlockCoord(656))
            
            coin:give('foreground')

            coin:give('animation_component', 
            {656, 657, 658, 659},                 --frameIDs
             8,                                   --framesPerSecond
             MapInstance.BlockIDCoordinates)      --coordinateSupplier

            coin:give('gravity_component')
            coin:give('moving_component', {x = 0, y = -10}, {x = 0, y = 0.3})
            coin:give('particle')

            coin:give('wait_until_component', 
            function(e)
                return AABBCollision(position, e.position) and e.moving_component.velocity.y >= 0
            end,
            function(e)
                world:removeEntity(e)
            end
            )
        end
    elseif mysteryBox.type == MYSTERY_BOX_TYPE.SUPER_STAR then
        mysteryBox.whenDispensed = function(originalBlock)
            local dispenseSound = Concord.entity(world)
            dispenseSound:give('sound_component', SOUND_ID.POWER_UP_APPEAR)

            local star = Concord.entity(world)
            local position   = originalBlock.position
            local yOffset = -4 -- add to avoid collison during brick bumps

            star:give('position', {x = position.position.x, y = position.position.y + yOffset}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            local starID = self:getReferenceBlockIDAsEntity(entityID, 96)
            star:give('texture', BLOCK_TILESHEET_IMG)
            star:give('spritesheet', star.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(starID))
            
            star:give('collectible', COLLECTIBLE_TYPE.SUPER_STAR)
            star:give('animation_component', 
            {starID, starID + 1, starID + 2, starID + 3},   --frameIDs
             8,                                             --framesPerSecond
             MapInstance.BlockIDCoordinates)                --coordinateSupplier


            star:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
            star:give('collision_exempt_component')
            star:give('wait_until_component', 
                function(entity)
                    return position:getTop() > entity.position:getBottom()
                end,
                function(entity)
                    entity:give('gravity_component')
                    entity.moving_component.velocity.x = COLLECTIBLE_SPEED
                    entity:remove('collision_exempt_component')
                    entity:remove('wait_until_component')
                end)
        end
    elseif mysteryBox.type == MYSTERY_BOX_TYPE.ONE_UP then
        mysteryBox.whenDispensed = function(originalBlock)
            local dispenseSound = Concord.entity(world)
            dispenseSound:give('sound_component', SOUND_ID.POWER_UP_APPEAR)
            local oneup = Concord.entity(world)
            local position   = originalBlock.position
            local yOffset = -4 -- add to avoid collison during brick bumps

            oneup:give('position', {x = position.position.x, y = position.position.y + yOffset}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            local oneupID = self:getReferenceBlockIDAsEntity(entityID, 52)
            oneup:give('texture', BLOCK_TILESHEET_IMG)
            oneup:give('spritesheet', oneup.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(oneupID))
            
            oneup:give('collectible', COLLECTIBLE_TYPE.ONE_UP)


            oneup:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
            oneup:give('collision_exempt_component')
            oneup:give('wait_until_component', 
                function(entity)
                    return position:getTop() > entity.position:getBottom()
                end,
                function(entity)
                    entity:give('gravity_component')
                    entity.moving_component.velocity.x = COLLECTIBLE_SPEED
                    entity:remove('collision_exempt_component')
                    entity:remove('wait_until_component')
                end)
        end
    elseif mysteryBox.type == MYSTERY_BOX_TYPE.VINES then
        local blockPositionX = entity.position.position.x / SCALED_CUBE_SIZE
        local blockPositionY = entity.position.position.y / SCALED_CUBE_SIZE
        local vineData = self.scene:getLevelData().vineLocations[1]
        --{"vine_coords": [83, 20], "teleport_coords": [83, 13], "camera_coords": [79, 0], "y": 13, "normal_teleport_coords": [162, 16], "camera_start": 224, "bg_color": "BLUE", "level_type": "OVERWORLD"}  
        if vineData.vine_coords[1] == 0 and vineData.vine_coords[2] == 0 then
            return
        end

        local vineParts = {}
        local vineLength = 0

        local vineTopID = self:getReferenceBlockIDAsEntity(entityID, 100)
        local vineBodyID = self:getReferenceBlockIDAsEntity(entityID, 148)

        mysteryBox.whenDispensed = function(originalBlock)
            local dispenseSound = Concord.entity(world)
            dispenseSound:give('sound_component', SOUND_ID.POWER_UP_APPEAR)

            originalBlock:give('above_foreground')
            local vineTop = Concord.entity(world)
            local position = originalBlock.position
            vineTop:give('position', {x = position.position.x, y = position.position.y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            vineTop:give('texture', BLOCK_TILESHEET_IMG)
            vineTop:give('spritesheet', vineTop.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(vineTopID))
            vineTop:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
            vineTop:give('move_outside_camera_component')
            vineTop:give('friction_exempt_component')
            vineTop:give('collision_exempt_component')
            vineTop:give('vine_component', vineData.vine_coords, vineData.teleport_coords, vineData.camera_coords,
                                           vineData.y,
                                           vineData.reset_location,
                                           vineData.camera_max, 
                                           Level:convertBGColorTextToType(vineData.bg_color),
                                           Level:convertLevelTextToType(vineData.level_type), 
                                           vineParts)
            vineTop:give('foreground')
            table.insert(vineParts, vineTop)
            vineLength = vineLength + 1

            --[[
                Periodically waits until the bottom of the vine has moved past the block, and then
                adds another piece to the vine.
                This keeps happening until the vine has fully grown
            ]]
            local vineGrowController = Concord.entity(world)
            vineGrowController:give('wait_until_component', 
            function(entity)
                local position = originalBlock.position
                return vineParts[#vineParts].position:getBottom() <= position:getTop()
            end,
            function(entity)
                local position = originalBlock.position
                --Adds another part to the vine
                if vineLength < 6 then
                    local vinePiece = Concord.entity(world)
                    vinePiece:give('position', {x = position.position.x, y = position.position.y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
                    vinePiece:give('texture', BLOCK_TILESHEET_IMG)
                    vinePiece:give('spritesheet', vinePiece.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                                     ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(vineBodyID))
                    vinePiece:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
                    vinePiece:give('move_outside_camera_component')
                    vinePiece:give('friction_exempt_component')
                    vinePiece:give('collision_exempt_component')
                    vinePiece:give('vine_component', vineData.vine_coords, vineData.teleport_coords, vineData.camera_coords,
                                                     vineData.y,
                                                     vineData.reset_location,
                                                     vineData.camera_max, 
                                                     Level:convertBGColorTextToType(vineData.bg_color),
                                                     Level:convertLevelTextToType(vineData.level_type), 
                                                     vineParts)
                    
                    vinePiece:give('foreground')
                    table.insert(vineParts, vinePiece)
                    vineLength = vineLength + 1
                    --If the vine is fully grown and the last vine is no longer in the block
                elseif vineParts[#vineParts].position:getBottom() < position:getTop() then
                    for _, e in ipairs(vineParts) do
                        e.moving_component.velocity.y = 0
                    end
                    vineGrowController:remove('wait_until_component')
                    world:removeEntity(vineGrowController)
                end
            end)
        end
    end
end

function MapSystem:createFireBarEntities()
    local world = self:getWorld()
    for _, fireBarCoordinate in ipairs(self.scene:getLevelData().fireBarLocations) do
        local barCoordinate = {x = fireBarCoordinate.coords[1], y = fireBarCoordinate.coords[2]}
        local startAngle = fireBarCoordinate.angle
        local rotationDirection = Level:convertRotationTextToType(fireBarCoordinate.direction)
        local barLength = fireBarCoordinate.length

        for bar = 0, barLength - 1 do
            local barElement = Concord.entity(world)
            barElement:give('position', {x = barCoordinate.x * SCALED_CUBE_SIZE, y = barCoordinate.y * SCALED_CUBE_SIZE},
                                        {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE},
                                        {x = 0, y = 0, w = SCALED_CUBE_SIZE / 4, h = SCALED_CUBE_SIZE / 4})
            barElement:give('texture', BLOCK_TILESHEET_IMG)
            barElement:give('spritesheet', barElement.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                               ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(611))
            barElement:give('animation_component', {611, 612, 613, 614}, 12, MapInstance:getBlockIDCoordinates())
            barElement:give('fire_bar_component', {x = barCoordinate.x * SCALED_CUBE_SIZE, y = barCoordinate.y * SCALED_CUBE_SIZE}, bar * ORIGINAL_CUBE_SIZE, startAngle, rotationDirection)
            barElement:give('timer_component',
            function(entity)
                local barComponent = entity.fire_bar_component
                local type = barComponent.direction
                if type == ROTATION_DIRECTION.CLOCKWISE then
                    barComponent.barAngle = barComponent.barAngle - 10
                elseif type == ROTATION_DIRECTION.COUNTER_CLOCKWISE then
                    barComponent.barAngle = barComponent.barAngle + 10
                end
            end, 6 )

            if bar ~= (barLength - 1) then
                barElement:give('enemy', ENEMY_TYPE.FIRE_BAR)
            end

            barElement:give('foreground')
        end
    end
end

function MapSystem:getReferenceEnemyID(entityID)
    if entityID == -1 then
        return -1
    end

    local entityCoordinates = MapInstance:getEnemyCoord(entityID)

    local coordinateX = entityCoordinates.x
    local coordinateY = entityCoordinates.y

    if coordinateY > 2 and coordinateY < 12 then
        coordinateY = coordinateY - (coordinateY - (coordinateY % 3))
    end

    for key, enemyIDCoord in ipairs(MapInstance:getEnemyIDCoordinates()) do
        if (enemyIDCoord.x == coordinateX) and (enemyIDCoord.y == coordinateY) then
            return key
        end
    end

    return -1
end

function MapSystem:createEnemyEntities(coordinateX, coordinateY, entityID, referenceID)
    local world = self:getWorld()
    if referenceID == 38 then -- KOOPA
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE},
                                {x = 0, y = SCALED_CUBE_SIZE, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1, 1, 0, ORIGINAL_CUBE_SIZE,
            ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(entityID) )
        
        local firstAnimationID = entityID
        entity:give('animation_component', 
                    {firstAnimationID, firstAnimationID + 1}, --frameIDs
                    6,                                   --framesPerSecond
                    MapInstance.EnemyIDCoordinates)      --coordinateSupplier

        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('gravity_component')
        entity:give('crushable_component', 
        function(entity)
            entity:remove('animation_component')
            entity.enemy.type = ENEMY_TYPE.KOOPA_SHELL
            entity.moving_component.velocity.x = 0
            entity.spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)

            entity:give('destroy_outside_camera_component')
            local position = entity.position
            position.scale.y = SCALED_CUBE_SIZE
            position.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}
            position.position.y = position.position.y + SCALED_CUBE_SIZE

            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 39))
        end)

        entity:give('enemy', ENEMY_TYPE.KOOPA)
    elseif referenceID == 39 then -- KOOPA (shifted to the right)
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE},
                                {x = 0, y = SCALED_CUBE_SIZE, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1, 1, 0, ORIGINAL_CUBE_SIZE,
            ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(entityID) )
        
        local firstAnimationID = entityID - 1
        entity:give('animation_component', 
                    {firstAnimationID + 1, firstAnimationID}, --frameIDs
                    6,                                   --framesPerSecond
                    MapInstance.EnemyIDCoordinates)      --coordinateSupplier

        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('gravity_component')
        entity:give('crushable_component', 
        function(entity)
            entity:remove('animation_component')
            entity.enemy.type = ENEMY_TYPE.KOOPA_SHELL
            entity.moving_component.velocity.x = 0
            entity.spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)

            entity:give('destroy_outside_camera_component')
            local position = entity.position
            position.scale.y = SCALED_CUBE_SIZE
            position.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}
            position.position.y = position.position.y + SCALED_CUBE_SIZE

            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 38))
        end)

        entity:give('enemy', ENEMY_TYPE.KOOPA)
    elseif referenceID == 40 then -- KOOPA PARATROOPA (GREEN)
        local koopa = Concord.entity(world)
        koopa:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                               {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE},
                               {x = 0, y = SCALED_CUBE_SIZE, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE})
        koopa:give('texture', ENEMY_TILESHEET_IMG)
        koopa:give('spritesheet', koopa.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1, 1,
                                                0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                MapInstance:getEnemyCoord(entityID))
        koopa:give('animation_component', {entityID, entityID + 1}, 4, MapInstance:getEnemyIDCoordinates())
        koopa:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        koopa:give('gravity_component')
        koopa:give('friction_exempt_component')
        koopa:give('wait_until_component',
        function(entity)
            return entity:has('bottom_collision_component')
        end,
        function(entity)
            entity:remove('bottom_collision_component')
            entity.moving_component.velocity.y = -8
            entity.moving_component.acceleration.y = -0.22
        end)

        koopa:give('crushable_component',
        function(entity)
            entity:remove('wait_until_component')
            entity.enemy.type = ENEMY_TYPE.KOOPA
            entity.animation_component.frameIDs = {entityID - 2, entityID - 1}
            entity:give('bottom_collision_component')
            entity.crushable_component.whenCrushed = 
            function(entity)
                entity.enemy.type = ENEMY_TYPE.KOOPA_SHELL
                entity.moving_component.velocity.x = 0.0
                entity.spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)
                entity:give('destroy_outside_camera_component')
                local position = entity.position
                position.scale.y = SCALED_CUBE_SIZE
                position.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}
                position.position.y = position.position.y + SCALED_CUBE_SIZE
                local shellCoordinate = self:getReferenceBlockIDAsEntity(entityID, 77)
                entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 37))
                entity:remove('animation_component')
            end
        end)
        koopa:give('enemy', ENEMY_TYPE.KOOPA_PARATROOPA)
    elseif referenceID == 44 then -- PIRHANNA PLANT
        local pirhanna = Concord.entity(world)
        pirhanna:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE + SCALED_CUBE_SIZE / 2, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                  {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE * 2},
                                  {x = 24, y = 48, w = 16, h = 16})
        local position = pirhanna.position
        pirhanna:give('texture', ENEMY_TILESHEET_IMG)
        pirhanna:give('spritesheet', pirhanna.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1,
                                                 1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                 MapInstance:getEnemyCoord(entityID) )
        pirhanna:give('animation_component', {entityID, entityID + 1}, 4, MapInstance:getEnemyIDCoordinates())
        pirhanna:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
        -- TO DO: I don't know why this component casues that game is lagged
        --pirhanna:give('move_outside_camera_component')
        pirhanna:give('collision_exempt_component')
        pirhanna:give('friction_exempt_component')
        pirhanna:give('enemy', ENEMY_TYPE.PIRANHA_PLANT)
        pirhanna:give('piranha_plant_component')
        local piranhaComponent = pirhanna.piranha_plant_component
        piranhaComponent.pipeCoordinates = {x = position.position.x, y = position.position.y + SCALED_CUBE_SIZE * 2}

        pirhanna:give('timer_component', 
        function(entity)
            local piranha = entity.piranha_plant_component
            if piranha.inPipe then
                entity.moving_component.velocity.y = -1
                entity:give('wait_until_component',
                function(entity)
                    return entity.position.position.y <= piranha.pipeCoordinates.y - SCALED_CUBE_SIZE * 2
                end,
                function(entity)
                    entity.position:setBottom(piranha.pipeCoordinates.y)
                    entity.moving_component.velocity.y = 0
                    entity:remove('wait_until_component')
                end)

                piranha.inPipe = false
            else
                entity.moving_component.velocity.y = 1
                entity:give('wait_until_component',
                function(entity)
                    return entity.position.position.y >= piranha.pipeCoordinates.y --+ SCALED_CUBE_SIZE * 2
                end,
                function(entity)
                    entity.position:setTop(piranha.pipeCoordinates.y)
                    entity.moving_component.velocity.y = 0
                    entity:remove('wait_until_component')
                end)

                piranha.inPipe = true
            end
        end, 3 * MAX_FPS)
    elseif referenceID == 48 then -- BLOOPER
        local blooper = Concord.entity(world)
        blooper:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                 {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE},
                                 {x = 0, y = SCALED_CUBE_SIZE / 2, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE})
        local position = blooper.position
        blooper:give('texture', ENEMY_TILESHEET_IMG)
        blooper:give('spritesheet', blooper.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1,
                                                     1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                     MapInstance:getEnemyCoord(entityID))
        blooper:give('animation_component', {entityID, entityID + 1}, 2, MapInstance:getEnemyIDCoordinates())
        blooper:give('moving_component', {x = 0, y = 0}, {x = 0, y = -0.5})
        local move = blooper.moving_component
        blooper:give('gravity_component')
        blooper:give('friction_exempt_component')
        blooper:give('collision_exempt_component')
        blooper:give('timer_component',
        function(entity)
            if not CameraInstance:inCameraRange(position) then
                return
            end

            entity:remove('gravity_component')
            move.acceleration.y = 0

            local playerPosition = world:getSystem(PlayerSystem):getMario().position

            if playerPosition.position.x > position.position.x then
                move.velocity.x = 3.0
            else
                move.velocity.x = -3.0
            end

            if position.position.y < CameraInstance:getCameraCenterY() then
                move.velocity.y = 3.0
            else
                move.velocity.y = -3.0
            end

            entity:give('callback_component',
            function(entity)
                entity:give('gravity_component')
                move.velocity.x = 0
                move.velocity.y = 0
                move.acceleration.y = -0.5
            end, MAX_FPS / 2)
        end, MAX_FPS)

        blooper:give('enemy', ENEMY_TYPE.BLOOPER)
    elseif referenceID == 50 then -- LAKITU
        local lakitu = Concord.entity(world)
        lakitu:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
        lakitu:give('texture', ENEMY_TILESHEET_IMG)
        lakitu:give('spritesheet', lakitu.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1,
                                                   1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                   MapInstance:getEnemyCoord(entityID))
        lakitu:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
        lakitu:give('friction_exempt_component')
        lakitu:give('crushable_component', 
        function(entity) 
            entity.texture:setVerticalFlipped(true)
            entity:give('dead_component')
            entity:give('gravity_component')
            entity:give('particle')
        end)

        lakitu:give('lakitu_component')
        lakitu:give('enemy', ENEMY_TYPE.LAKITU)
        local inCloudID = self:getReferenceEnemyIDAsEntity(entityID, 86)
        local createSpine = function(entity)
            local position = entity.position
            local texture = entity.texture
            local spine = Concord.entity(world)
            spine:give('position', {x = position.position.x, y = position.position.y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            spine:give('texture', ENEMY_TILESHEET_IMG)
            spine:give('spritesheet', spine.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1,
                                                     0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                     MapInstance:getEnemyCoord(500))
            spine:give('animation_component', {500, 501}, 4, MapInstance:getEnemyIDCoordinates())
            
            local xMov
            if texture:isHorizontalFlipped() then
                xMov = 2.5
            else
                xMov = -2.5
            end
            spine:give('moving_component', {x = xMov, y = 0}, {x = 0, y = 0})
            spine:give('gravity_component')
            spine:give('destroy_outside_camera_component')
            spine:give('enemy', ENEMY_TYPE.SPINE)
            return spine
        end

        local throwSpine = function(entity)
            local position = entity.position
            local texture = entity.texture
            local spritesheet = entity.spritesheet
            if not CameraInstance:inCameraRange(position) then
                return
            end

            CommandScheduler:addCommand(
                SequenceCommand({
                    --Set Lakitu to be in the cloud
                    RunCommand(function() 
                        local world = self:getWorld()
                        local shouldBeReturned = true
                        for _, e in ipairs(world:getEntities()) do
                            if entity == e then
                                shouldBeReturned = false
                            end
                        end

                        if shouldBeReturned then
                           return 
                        end

                        position.scale.y = SCALED_CUBE_SIZE
                        position.position.y = position.position.y + SCALED_CUBE_SIZE
                        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)
                        spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(inCloudID))
                    end),
                    WaitCommand(0.75),
                    -- Move out of the cloud and launch a spine
                    RunCommand(function()
                        local world = self:getWorld()
                        local shouldBeReturned = true
                        for _, e in ipairs(world:getEntities()) do
                            if entity == e then
                                shouldBeReturned = false
                            end
                        end

                        if shouldBeReturned then
                            return 
                         end

                        position.scale.y = SCALED_CUBE_SIZE * 2
                        position.position.y = position.position.y - SCALED_CUBE_SIZE
                        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE * 2)
                        spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID))

                        createSpine(entity)
                    end)
                }))
        end

        lakitu:give('timer_component', throwSpine, 3 * MAX_FPS)
    elseif referenceID == 56 then -- HAMMER BRO
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
        local position = entity.position
        entity:give('texture', ENEMY_TILESHEET_IMG)
        local texture = entity.texture
        entity:give('spritesheet', texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1,
                                            1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                            MapInstance:getEnemyCoord(entityID))
        entity:give('moving_component', {x = 2, y = 0}, {x = 0, y = 0})
        entity:give('gravity_component')
        entity:give('friction_exempt_component')

        local armsBackID = self:getReferenceEnemyIDAsEntity(entityID, 58)
        local hammerID = self:getReferenceEnemyIDAsEntity(entityID, 60)

        local armsDownAnimation = {entityID, entityID + 1}
        local armsBackAnimation = {armsBackID, armsBackID + 1}

        entity:give('animation_component', armsBackAnimation, 4, MapInstance:getEnemyIDCoordinates())
        local animation = entity.animation_component
        local throwHammer = 
        function(entity)
            animation.frameIDs = armsBackAnimation
            -- Create hammer
            local hammer = Concord.entity(world)
            hammer:give('position', {x = 0, y = position.position.y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            local hammerPosition = hammer.position
            hammerPosition:setCenterX(position:getCenterX())
            hammer:give('texture', ENEMY_TILESHEET_IMG)
            hammer.texture:setHorizontalFlipped(texture:isHorizontalFlipped())

            hammer:give('spritesheet', hammer.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1,
                                                       0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                       MapInstance:getEnemyCoord(hammerID))
            
            hammer:give('particle')
            hammer:give('destroy_outside_camera_component')
            entity.hammer_bro_component.hammer = hammer
            entity:give('callback_component',
            function(entity)
                -- Fail safe in case if crushed before hammer is thrown
                if not entity:has('hammer_bro_component') then
                    world:removeEntity(hammer)
                    return
                end

                animation.frameIDs = armsDownAnimation
                hammerPosition:setBottom(position:getTop())

                local xMoveVal
                if texture:isHorizontalFlipped() then
                    hammerPosition:setLeft(position:getRight())
                    xMoveVal = 3.0
                else
                    hammerPosition:setRight(position:getLeft())
                    xMoveVal = -3.0
                end

                hammer:give('moving_component', {x = xMoveVal, y = -6}, {x = 0, y = 0})
                hammer:give('friction_exempt_component')
                hammer:give('gravity_component')
                hammer:give('projectile', PROJECTTILE_TYPE.OTHER)
                entity.hammer_bro_component.lastThrowTime = 0
            end, MAX_FPS * 0.5)
        end

        entity:give('hammer_bro_component', throwHammer)

        entity:give('crushable_component', 
        function(entity)
            entity.texture:setVerticalFlipped(true)
            entity:give('particle')
            entity:remove('callback_component')
            entity:remove('hammer_bro_component')
            entity:give('dead_component')
        end
        )

        entity:give('enemy', ENEMY_TYPE.HAMMER_BRO)
    elseif referenceID == 61 then -- BOWSER
        local bowser = Concord.entity(world)
        bowser:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE },
                                {x = 2 * SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE })
        local position = bowser.position
        bowser:give('texture', ENEMY_TILESHEET_IMG)
        local texture = bowser.texture
        bowser:give('spritesheet', bowser.texture, ORIGINAL_CUBE_SIZE * 2, ORIGINAL_CUBE_SIZE * 2,
                                  1, 1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                  MapInstance:getEnemyCoord(entityID) )
        bowser:give('moving_component', {x = 0, y = 0}, {x = 0, y = -0.3})
        local move = bowser.moving_component
        bowser:give('gravity_component')
        bowser:give('friction_exempt_component')

        local mouthOpenID = self:getReferenceEnemyIDAsEntity(entityID, 61)
        local mouthClosedID = self:getReferenceEnemyIDAsEntity(entityID, 65)
        local hammerID = self:getReferenceEnemyIDAsEntity(entityID, 60)

        local mouthOpenAnimation = {mouthOpenID, mouthOpenID + 2}
        local mouthClosedAnimation = {mouthClosedID, mouthClosedID + 2}

        bowser:give('animation_component', mouthOpenAnimation, 2, MapInstance:getEnemyIDCoordinates())
        local animation = bowser.animation_component
        local bowserMovements = {
            function(entity) -- MOVE
                local bowserComponent = entity.bowser_component
                if bowserComponent.lastMoveDirection == DIRECTION.LEFT then
                    move.velocity.x = 1
                    bowserComponent.lastMoveDirection = DIRECTION.RIGHT
                else
                    move.velocity.x = 1
                    bowserComponent.lastMoveDirection = DIRECTION.LEFT
                end
                bowserComponent.lastMoveTime = 0
            end,
            function(entity) -- STOP
                move.velocity.x = 0
                entity.bowser_component.lastStopTime = 0
            end,
            function(entity) -- JUMP
                local bowserComponent = entity.bowser_component
                move.velocity.y = -5.0
                move.acceleration.y = -0.35
                bowserComponent.lastJumpTime = 0
            end
        }

        local bowserAttacks = {
            function(entity, number) -- LAUNCH FIRE
                local bowserComponent = entity.bowser_component
                animation.frameIDs = mouthClosedAnimation
                entity:give('callback_component', 
                function(entity, number)
                    if number == nil then
                        number = 0
                    end

                    animation.frameIDs = mouthOpenAnimation
                    local blastSound = Concord.entity(world)
                    blastSound:give('sound_component', SOUND_ID.BOWSER_FIRE)

                    local fireBlast = Concord.entity(world)
                    fireBlast:give('position', {x = 0, y = position:getTop() + 4},
                                               {x = 1.5 * SCALED_CUBE_SIZE, y = 0.5 * SCALED_CUBE_SIZE })
                    local blastPosition = fireBlast.position
                    fireBlast:give('texture', ENEMY_TILESHEET_IMG)
                    local blastTexture = fireBlast.texture
                    fireBlast:give('spritesheet', blastTexture, ORIGINAL_CUBE_SIZE + ORIGINAL_CUBE_SIZE / 2, ORIGINAL_CUBE_SIZE / 2, 1,
                                                                1, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                                MapInstance:getEnemyCoord(470))
                    fireBlast:give('animation_component', {470, 505}, 16, MapInstance:getEnemyIDCoordinates())
                    fireBlast:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
                    local blastMove = fireBlast.moving_component
                    fireBlast:give('friction_exempt_component')
                    fireBlast:give('destroy_outside_camera_component')
                    if texture:isHorizontalFlipped() then
                        blastMove.velocity.x = 3
                        blastPosition:setLeft(position:getRight())
                        blastTexture:setHorizontalFlipped(true)
                    else
                        blastMove.velocity.x = -3
                        blastPosition:setRight(position:getLeft())
                        blastTexture:setHorizontalFlipped(false)
                    end

                    fireBlast:give('projectile', PROJECTTILE_TYPE.OTHER)
                end, MAX_FPS * 2)
                bowserComponent.lastAttackTime = 0
            end,
            function(entity, number) -- THROW HAMMERS
                local bowserComponent = entity.bowser_component
                if number == nil then
                    number = 0
                end

                for i = 0, number - 1 do
                    local hammer = Concord.entity(world)
                    hammer:give('callback_component', 
                    function(hammer)
                        hammer:give('position', {x = position:getLeft(), y = position:getTop()}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE })
                        local hammerPosition = hammer.position
                        if texture:isHorizontalFlipped() then
                            hammerPosition:setLeft(position:getRight())
                        else
                            hammerPosition:setRight(position:getLeft())
                        end

                        hammer:give('texture', ENEMY_TILESHEET_IMG)
                        hammer:give('spritesheet', hammer.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0, ORIGINAL_CUBE_SIZE,
                                                                   ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(hammerID))
                        local randomXVelocity = -(love.math.random() + 2.25)
                        local randomYVelocity = -(love.math.random() * 0.5 + 6)
                        
                        if texture:isHorizontalFlipped() then
                            randomXVelocity = randomXVelocity * -1
                        end

                        hammer:give('moving_component', {x = randomXVelocity, y = randomYVelocity}, {x = 0, y = -0.35})
                        hammer:give('friction_exempt_component')
                        hammer:give('gravity_component')
                        hammer:give('destroy_outside_camera_component')
                        hammer:give('projectile', PROJECTTILE_TYPE.OTHER)
                        hammer:give('particle')
                    end, i * 4)

                    bowserComponent.lastAttackTime = 0
                end

            end
        }

        bowser:give('bowser_component', bowserAttacks, bowserMovements)
        bowser:give('enemy', ENEMY_TYPE.BOWSER)
    elseif referenceID == 70 then -- GOOMBA
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(entityID) )
        local firstAnimationID = entityID
        entity:give('animation_component', 
                {firstAnimationID, firstAnimationID + 1}, --frameIDs
                8,                                   --framesPerSecond
                MapInstance.EnemyIDCoordinates)      --coordinateSupplier

        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('crushable_component', 
        function(entity)
            entity:remove('animation_component')
            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 2))
            entity:give('dead_component')
            entity:give('frozen_component')
            entity:give('destroy_delayed_component', 20)
        end)

        entity:give('gravity_component')
        entity:give('enemy', ENEMY_TYPE.GOOMBA)
    elseif referenceID == 71 then -- GOOMBA (shifted to the right)
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0, ORIGINAL_CUBE_SIZE,
                                           ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(entityID) )
        local firstAnimationID = entityID - 1
        entity:give('animation_component', 
                {firstAnimationID + 1, firstAnimationID}, --frameIDs
                8,                                   --framesPerSecond
                MapInstance.EnemyIDCoordinates)      --coordinateSupplier

        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('crushable_component', 
        function(entity)
            entity:remove('animation_component')
            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 1))
            entity:give('dead_component')
            entity:give('frozen_component')
            entity:give('destroy_delayed_component', 20)
        end)

        entity:give('gravity_component')
        entity:give('enemy', ENEMY_TYPE.GOOMBA)
    elseif referenceID == 81 then -- CHEEP CHEEP
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0,
                                                   ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                   MapInstance:getEnemyCoord(entityID))
        entity:give('animation_component', {entityID, entityID + 1}, 6, MapInstance:getEnemyIDCoordinates())
        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('collision_exempt_component')
        entity:give('friction_exempt_component')
        entity:give('enemy', ENEMY_TYPE.CHEEP_CHEEP)
    elseif referenceID == 87 then -- BUZZY BEETLE
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})

        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0,
                                                   ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                   MapInstance:getEnemyCoord(entityID))
        local firstAnimationID = entityID
        local deadID = self:getReferenceEnemyIDAsEntity(entityID, 89)

        entity:give('animation_component', {firstAnimationID, firstAnimationID + 1}, 6, MapInstance:getEnemyIDCoordinates())
        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('gravity_component')

        entity:give('crushable_component', 
        function(entity) 
            entity.enemy.type = ENEMY_TYPE.KOOPA_SHELL
            entity.moving_component.velocity.x = 0
            entity:give('destroy_outside_camera_component')
            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(deadID))
            entity:remove('animation_component')
        end)

        entity:give('enemy', ENEMY_TYPE.BUZZY_BEETLE)
    elseif referenceID == 90 then -- BULLET BILL
    elseif referenceID == 455 then -- NORMAL KOOPA (RED)
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE},
                                {x = 0, y = SCALED_CUBE_SIZE, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE})
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE * 2, 1, 1, 0, ORIGINAL_CUBE_SIZE,
            ORIGINAL_CUBE_SIZE, MapInstance:getEnemyCoord(entityID) )
        
        local firstAnimationID = entityID
        entity:give('animation_component', 
                    {firstAnimationID, firstAnimationID + 1}, --frameIDs
                    6,                                   --framesPerSecond
                    MapInstance.EnemyIDCoordinates)      --coordinateSupplier

        entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
        entity:give('gravity_component')
        entity:give('crushable_component', 
        function(entity)
            entity:remove('animation_component')
            entity.enemy.type = ENEMY_TYPE.KOOPA_SHELL
            entity.moving_component.velocity.x = 0
            entity.spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)

            entity:give('destroy_outside_camera_component')
            local position = entity.position
            position.scale.y = SCALED_CUBE_SIZE
            position.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}
            position.position.y = position.position.y + SCALED_CUBE_SIZE

            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getEnemyCoord(entityID + 39))
        end)

        entity:give('enemy', ENEMY_TYPE.KOOPA)
    elseif referenceID == 498 then -- CHEEP CHEEP (RED)
        if self.scene:getBackgroundMap():getLevelData()[coordinateY][coordinateX] == 186 then -- if underwater
            local entity = Concord.entity(world)
            entity:give('texture', ENEMY_TILESHEET_IMG)
            entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1,
                                                       0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                       MapInstance:getEnemyCoord(entityID))
            entity:give('animation_component', {entityID, entityID + 1}, 6, MapInstance:getEnemyIDCoordinates())
            entity:give('moving_component', {x = -ENEMY_SPEED, y = 0}, {x = 0, y = 0})
            entity:give('collision_exempt_component')
            entity:give('friction_exempt_component')
            entity:give('enemy', ENEMY_TYPE.CHEEP_CHEEP)
        else -- If in those flying patches of them idk what they're called
            
            local entity = Concord.entity(world)
            entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = coordinateY * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
            local position = entity.position
            entity:give('texture', ENEMY_TILESHEET_IMG, true)
            entity.texture:setHorizontalFlipped(true)
            entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1,
                                                       0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                       MapInstance:getEnemyCoord(entityID))
            entity:give('animation_component', {entityID, entityID + 1}, 6, MapInstance:getEnemyIDCoordinates())
            entity:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
            local move = entity.moving_component

            entity:give('move_outside_camera_component')
            entity:give('gravity_component')
            entity:give('collision_exempt_component')
            entity:give('friction_exempt_component')

            local randomValue = generateRandomNumber(0.5, 2.0)
            entity:give('timer_component',
            function(entity)
                entity:give('callback_component',
                function(entity)
                    if CameraInstance:inCameraYRange(position) then
                        return
                    end
                    position.position = {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = coordinateY * SCALED_CUBE_SIZE}

                    if not CameraInstance:inCameraXRange(position) then
                        return
                    end
                    move.velocity.x = generateRandomNumber(2.0, 4.0)
                    move.velocity.y = -10
                    move.acceleration.y = -0.4542
                end, math.floor(MAX_FPS * randomValue))
            end, MAX_FPS * 2.5)

            entity:give('crushable_component',
            function(entity)
                entity.texture:setVerticalFlipped(true)
                entity.moving_component.acceleration.y = 0
                entity:give('dead_component')
                entity:give('particle')
                entity:remove('timer_component')
            end)
            entity:give('enemy', ENEMY_TYPE.CHEEP_CHEEP)
        end
    elseif referenceID == 504 then -- LAVA BUBBLE
        local entity = Concord.entity(world)
        entity:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = coordinateY * SCALED_CUBE_SIZE},
                                {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
        local resetYLevel = coordinateY * SCALED_CUBE_SIZE
        entity:give('texture', ENEMY_TILESHEET_IMG)
        entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 0,
                                                   ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                   MapInstance:getEnemyCoord(entityID))
        entity:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
        entity:give('particle')
        entity:give('gravity_component')
        entity:give('timer_component',
        function(entity)
            entity.position.position.y = resetYLevel
            entity.moving_component.velocity.y = -10.0
            entity.moving_component.acceleration.y = -0.40
        end, MAX_FPS * 4)

        entity:give('enemy', ENEMY_TYPE.LAVA_BUBBLE)
    end
end

function MapSystem:getReferenceEnemyIDAsEntity(entityID, referenceID)
    if enemyID == -1 or referenceID == -1 then
        return -1
    end

    local entityCoordinates = MapInstance:getEnemyCoord(entityID)
    local referenceCoordinates = MapInstance:getEnemyCoord(referenceID)

    local entityCoordinateY = entityCoordinates.y
    local referenceCoordinateX = referenceCoordinates.x
    local referenceCoordinateY = referenceCoordinates.y

    for key, enemyIDCoord in ipairs(MapInstance:getEnemyIDCoordinates()) do
        if (enemyIDCoord.x == referenceCoordinateX) and (enemyIDCoord.y == referenceCoordinateY) then
            return key
        end
    end

    return -1
end

function MapSystem:createPlatformEntity(coordinateX, coordinateY, entityID, platformLength, platformData)
    local world = self:getWorld()
    local platform = Concord.entity(world)
    platform:give('position', {x = (coordinateX - 1) * SCALED_CUBE_SIZE, y = (coordinateY - 1) * SCALED_CUBE_SIZE}, {x = platformLength * SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    platform:give('texture', BLOCK_TILESHEET_IMG)
    platform:give('spritesheet', platform.texture, ORIGINAL_CUBE_SIZE * platformLength, ORIGINAL_CUBE_SIZE, 1, 1, 1, ORIGINAL_CUBE_SIZE,
                                                   ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID))
    platform:give('foreground')
    platform:give('tile_component')

    -- {"coords": [140, 24], "motion": "ONE_DIRECTION_REPEATED", "direction": "DOWN", "point": [17, 32], "shift": false},
    if platformData.shift then
        platform.position.position.x = platform.position.position.x + SCALED_CUBE_SIZE / 2
    end

    platform:give('friction_exempt_component')
    platform:give('collision_exempt_component')
    platform:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
    local move = platform.moving_component

    local motionType =  Level:convertMotionTextToType(platformData.motion)
    if motionType == PLATFORM_MOTION_TYPE.ONE_DIRECTION_REPEATED then
        local movingDirection = Level:convertDirectionTextToType(platformData.direction)
        local minMax = {x = platformData.point[1], y = platformData.point[2]}
        minMax.y = minMax.y + 1
        minMax.x = minMax.x * SCALED_CUBE_SIZE
        minMax.y = minMax.y * SCALED_CUBE_SIZE
        platform:give('moving_platform_component', PLATFORM_MOTION_TYPE.ONE_DIRECTION_REPEATED, movingDirection, minMax)
        if movingDirection == DIRECTION.LEFT then
            move.velocity.x = -2
        elseif movingDirection == DIRECTION.RIGHT then
            move.velocity.x = 2
        elseif movingDirection == DIRECTION.UP then
            move.velocity.y = -1
        elseif movingDirection == DIRECTION.DOWN then
            move.velocity.y = 1
        end
    elseif motionType == PLATFORM_MOTION_TYPE.ONE_DIRECTION_CONTINUOUS then
        local movingDirection = convertDirectionTextToType(platformData.direction)
        local minMax = {x = 0, y = 0}
        platform:give('moving_platform_component', PLATFORM_MOTION_TYPE.ONE_DIRECTION_CONTINUOUS, movingDirection, minMax)
        if movingDirection == DIRECTION.LEFT then
            move.velocity.x = -2
        elseif movingDirection == DIRECTION.RIGHT then
            move.velocity.x = 2
        elseif movingDirection == DIRECTION.UP then
            move.velocity.y = -2
        elseif movingDirection == DIRECTION.DOWN then
            move.velocity.y = 2
        end
    elseif motionType == PLATFORM_MOTION_TYPE.BACK_AND_FORTH then
        local movingDirection = Level:convertDirectionTextToType(platformData.direction)
        local minMax = {x = platformData.point[1], y = platformData.point[2]}
        minMax.y = minMax.y + 1
        minMax.x = minMax.x * SCALED_CUBE_SIZE
        minMax.y = minMax.y * SCALED_CUBE_SIZE
        platform:give('moving_platform_component', PLATFORM_MOTION_TYPE.BACK_AND_FORTH, movingDirection, minMax)
        if movingDirection == DIRECTION.LEFT then
            move.velocity.x = -2
        elseif movingDirection == DIRECTION.RIGHT then
            move.velocity.x = 2
        elseif movingDirection == DIRECTION.UP then
            move.velocity.y = -2
        elseif movingDirection == DIRECTION.DOWN then
            move.velocity.y = 2
        end
    elseif motionType == PLATFORM_MOTION_TYPE.GRAVITY then
        platform:give('moving_platform_component', PLATFORM_MOTION_TYPE.GRAVITY, DIRECTION.NONE)
    end

    return platform
end

function MapSystem:createPlatformLevelEntity(platformLevelData)
    local world = self:getWorld()
    --{"left_coords": [81, 6], "right_coords": [88, 8], "yLevel": 2},
    local leftCoordinate = platformLevelData.left_coords
    local rightCoordinate = platformLevelData.right_coords
    local pulleyHeight = platformLevelData.yLevel + 1

    local leftLineX = leftCoordinate[1] + 1
    local rightLineX = rightCoordinate[1] + 1

    local pulleyID = self:getReferenceBlockIDAsEntity(self.scene:getBackgroundMap():getLevelData()[pulleyHeight - 1 + 1][leftLineX + 1], 391)

    if pulleyID == -1 then 
        pulleyID = 391
    end 

    local leftPulleyLine = self:createBackgroundEntity(leftLineX + 1, pulleyHeight + 1, pulleyID)
    local rightPulleyLine = self:createBackgroundEntity(rightLineX + 1, pulleyHeight + 1, pulleyID)

    local leftPlatform = Concord.entity(world)
    local rightPlatform = Concord.entity(world)

    leftPlatform:give('position', {x = leftCoordinate[1] * SCALED_CUBE_SIZE, y = leftCoordinate[2] * SCALED_CUBE_SIZE}, 
                                  {x = 3 * SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE},
                                  {x = 0, y = 0, w = 3 * SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE / 2})
    
    leftPlatform:give('texture', BLOCK_TILESHEET_IMG)
    leftPlatform:give('spritesheet', leftPlatform.texture, ORIGINAL_CUBE_SIZE * 3, ORIGINAL_CUBE_SIZE, 1,
                                                           1, 1, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                           MapInstance:getBlockCoord(809) )
    leftPlatform:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
    leftPlatform:give('platform_level_component', rightPlatform, leftPulleyLine, pulleyHeight * SCALED_CUBE_SIZE)
    leftPlatform:give('foreground')
    leftPlatform:give('tile_component')

    rightPlatform:give('position', {x = rightCoordinate[1] * SCALED_CUBE_SIZE, y = rightCoordinate[2] * SCALED_CUBE_SIZE}, 
                                   {x = 3 * SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE},
                                   {x = 0, y = 0, w = 3 * SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE / 2})
    rightPlatform:give('texture', BLOCK_TILESHEET_IMG)
    rightPlatform:give('spritesheet', rightPlatform.texture, ORIGINAL_CUBE_SIZE * 3, ORIGINAL_CUBE_SIZE, 1,
                                                            1, 1, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                                            MapInstance:getBlockCoord(809) )
    rightPlatform:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
    rightPlatform:give('platform_level_component', leftPlatform, rightPulleyLine, pulleyHeight * SCALED_CUBE_SIZE)

    rightPlatform:give('foreground')
    rightPlatform:give('tile_component')

    return leftPlatform
end

function MapSystem:createBackgroundEntity(coordinateX, coordinateY, entityID) 
    local world = self:getWorld()
    local entity = Concord.entity(world)
    entity:give('position', {x = (coordinateX-1) * SCALED_CUBE_SIZE, y = (coordinateY-1) * SCALED_CUBE_SIZE},
                            {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    entity:give('texture', BLOCK_TILESHEET_IMG, false, false)
    entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
                                               ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                                               MapInstance:getBlockCoord(entityID))
    entity:give('background')
    return entity
end

function MapSystem:addPlatformsLevel()
    for _, platformLevelLocation in ipairs(self.scene:getLevelData().platformLevelLocations) do
        self:createPlatformLevelEntity(platformLevelLocation)
    end
end