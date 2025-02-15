WarpSystem = Concord.system()

WarpSystem.warping = false
WarpSystem.climbing = false
WarpSystem.climbed = false

function WarpSystem:init(world)
    WarpSystem:setWarping(false)
    self.world = world
    self.up = 0
    self.down = 0
    self.left = 0
    self.right = 0
end

function WarpSystem:update()
    if not self:isEnabled() then
        return
    end
    
    self:handleInput()

    local filterSystem = self.world:getSystem(FilterSystem)

    for _, entity in ipairs(filterSystem:getWarpPipeEntities()) do
        if entity:has('position') then
            local pipe = entity
            local warpPipe = entity.warp_pipe_component
            local player = self.world:getSystem(PlayerSystem):getMario()

            if AABBCollision(pipe.position, player.position) and not WarpSystem:isWarping() then
                local playerMove = player.moving_component
                if warpPipe.inDirection == DIRECTION.UP then
                    if self.up > 0 or playerMove.velocity.y < 0.0 then
                        self:warp(pipe)
                    end
                elseif warpPipe.inDirection == DIRECTION.DOWN then
                    if self.down > 0 or playerMove.velocity.y > 0.0 then
                        self:warp(pipe)
                    end
                elseif warpPipe.inDirection == DIRECTION.LEFT then
                    if self.left > 0 or playerMove.velocity.x < 0.0 then
                        self:warp(pipe)
                    end
                elseif warpPipe.inDirection == DIRECTION.RIGHT then
                    if self.right > 0 or playerMove.velocity.x > 0.0 then
                        self:warp(pipe)
                    end
                end 
            end
        end
    end

    for _, entity in ipairs(filterSystem:getVineEntities()) do
        if entity:has('position') then
            local vine = entity
            local player = self.world:getSystem(PlayerSystem):getMario()
            local warpSystem = self.world:getSystem(WarpSystem) 
    
            playerPosition = player.position
            playerMove     = player.moving_component
            if AABBTotalCollision(playerPosition, vine.position) and (not warpSystem:isClimbing() or playerMove.velocity.y == 0) then
                player:give('collision_exempt_component')
                player:give('friction_exempt_component')
                player:remove('gravity_component')
        
                if playerPosition.position.x > entity.position.position.x + SCALED_CUBE_SIZE / 2 then
                    player.texture:setHorizontalFlipped(true)
                    playerPosition:setLeft(entity.position:getRight() - SCALED_CUBE_SIZE / 2)
                else
                    playerPosition:setRight(entity.position:getLeft() + SCALED_CUBE_SIZE / 2)
                end

                WarpSystem:setClimbing(true)
                PlayerSystem:enableInput(false)
        
                playerMove.velocity.x = 0
                playerMove.acceleration.x = 0
                playerMove.velocity.y = 0
                playerMove.acceleration.y = 0
        
                if self.up then
                    self:climb(vine)
                end
            end
        end
    end
    -- If the player is below the Y level where it gets teleported
    if WarpSystem.climbed then
        local player = self.world:getSystem(PlayerSystem):getMario()
        local playerPosition = player.position
        local playerMove = player.moving_component

        if playerPosition:getTop() > self.teleportLevelY + SCALED_CUBE_SIZE * 3 then
            player:give('frozen_component')
            WarpSystem:setClimbed(false)
            CommandScheduler:addCommand(DelayedCommand(
                function()
                    player:remove('frozen_component')
                    playerMove.velocity.x = 0
                    playerMove.velocity.y = 0
                    playerMove.acceleration.x = 0
                    playerMove.acceleration.y = 0

                    CameraInstance:setCameraX(self.teleportCameraCoordinates.x)
                    CameraInstance:setCameraY(self.teleportCameraCoordinates.y)
                    CameraInstance:setCameraMaxX(self.teleportCameraMax)

                    --TextureManager::Get().SetBackgroundColor(teleportBackgroundColor);
                    self.scene:setCurrentLevelType(self.teleportLevelType)
                    self.scene:setLevelMusic(self.teleportLevelType)

                    playerPosition.position.x = self.teleportPlayerCoordinates.x
                    playerPosition.position.y = self.teleportPlayerCoordinates.y

                    self.teleportPlayerCoordinates = {x = 0, y = 0}
                    self.teleportLevelY = 0
                    self.teleportCameraMax = 0
                    self.teleportBackgroundColor = 0
                    self.teleportLevelType = LEVEL_TYPE.NONE
                end, 2.0
            ))
        end
    end
end

function WarpSystem:setScene(scene)
    self.scene = scene
end

function WarpSystem:isWarping()
    return WarpSystem.warping
end

function WarpSystem:isClimbing()
    return WarpSystem.climbing
end

function WarpSystem:hasClimbed()
    return WarpSystem.climbed
end

function WarpSystem:setWarping(val)
    WarpSystem.warping = val
end

function WarpSystem:setClimbing(val)
    WarpSystem.climbing = val
end

function WarpSystem:setClimbed(val)
    WarpSystem.climbed = val
end

function WarpSystem:setTeleportLevelY(levelY)
    self.teleportLevelY = levelY
end

function WarpSystem:setTeleportPlayerCoordinates(playerCoordinates)
    self.teleportPlayerCoordinates = playerCoordinates
end

function WarpSystem:setTeleportCameraCoordinates(cameraCoordinates)
    self.teleportCameraCoordinates = cameraCoordinates
end

function WarpSystem:setTeleportCameraMax(cameraMax)
    self.teleportCameraMax = cameraMax
end

function WarpSystem:setTeleportBackgroundColor(backgroundColor)
    self.teleportBackgroundColor = backgroundColor
end

function WarpSystem:setTeleportLevelType(levelType)
    self.teleportLevelType = levelType
end

function WarpSystem:handleInput()
    if input:pressed('DUCK') then
        self.down = 1
    else
        self.down = 0
    end

    if input:pressed('LEFT') then
        self.left = 1
    else
        self.left = 0
    end

    if input:pressed('RIGHT') then
        self.right = 1
    else
        self.right = 0
    end

    if input:pressed('MENU_UP') then
        self.up = 1
    else
        self.up = 0
    end
end

function WarpSystem:warp(pipe)
    if WarpSystem:isWarping() then
        return
    end

    local player = self.world:getSystem(PlayerSystem):getMario()
    CommandScheduler:addCommand(WarpCommand(self.scene, self.world, pipe))
end

function WarpSystem:climb(vine)
    local player = self.world:getSystem(PlayerSystem):getMario()
    CommandScheduler:addCommand(VineCommand(self.scene, self.world, vine))
end