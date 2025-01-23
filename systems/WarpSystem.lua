WarpSystem = Concord.system()

WarpSystem.warping = false
WarpSystem.climbing = false
WarpSystem.climbed = false

function WarpSystem:init(world)
    WarpSystem:setWarping(false)
    self.up = 0
    self.down = 0
    self.left = 0
    self.right = 0
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

function WarpSystem:update()
    if not self:isEnabled() then
        return
    end
    
    self:handleInput()
    local world = self:getWorld()
    for _, entity in ipairs(world:getEntities()) do
        -- Warp pipe checking
        if entity:has('warp_pipe_component') and entity:has('position') then
            local warpPipe = entity.warp_pipe_component
            local player = world:getSystem(PlayerSystem):getMario()

    
            if not AABBCollision(entity.position, player.position) or WarpSystem:isWarping() then
            else
                local playerMove = player.moving_component
                if warpPipe.inDirection == DIRECTION.UP then
                    if self.up > 0 or playerMove.velocity.y < 0.0 then
                        self:warp(world, entity, player)
                    end
                elseif warpPipe.inDirection == DIRECTION.DOWN then
                    if self.down > 0 or playerMove.velocity.y > 0.0 then
                        self:warp(world, entity, player)
                    end
                elseif warpPipe.inDirection == DIRECTION.LEFT then
                    if self.left > 0 or playerMove.velocity.x < 0.0 then
                        self:warp(world, entity, player)
                    end
                elseif warpPipe.inDirection == DIRECTION.RIGHT then
                    if self.right > 0 or playerMove.velocity.x > 0.0 then
                        self:warp(world, entity, player)
                    end
                end 
            end
        end

        --Vine checking
        if entity:has('vine_component') and entity:has('position') then
            local player = world:getSystem(PlayerSystem):getMario()
    
            playerPosition = player.position
            playerMove     = player.moving_component
            if not AABBTotalCollision(playerPosition, entity.position) or (WarpSystem:isClimbing() and playerMove.velocity.y ~= 0) then
            else
                player:give('collision_exempt_component')
                player:give('friction_exempt_component')
                player:remove('gravity_component')
        
                player.texture:setHorizontalFlipped(true)
                playerPosition:setLeft(entity.position:getRight() - SCALED_CUBE_SIZE / 2)
                WarpSystem:setClimbing(true)
                PlayerSystem:enableInput(false)
        
                playerMove.velocity.x = 0
                playerMove.acceleration.x = 0
                playerMove.velocity.y = 0
                playerMove.acceleration.y = 0
        
                if self.up then
                    self:climb(world, entity, player)
                end
            end
        end
    end

    -- If the player is below the Y level where it gets teleported
    if WarpSystem.climbed then
        local player
        for _, e in ipairs(world:getEntities()) do
            if e:has('player') and e:has('position') and e:has('moving_component') then
                player = e
                break
            end
        end

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

function WarpSystem:warp(world, pipe, player)
    if WarpSystem:isWarping() then
        return
    end

    CommandScheduler:addCommand(WarpCommand(self.scene, world, pipe, player))
end

function WarpSystem:climb(world, vine, player)
    CommandScheduler:addCommand(VineCommand(self.scene, self, world, vine, player))
end