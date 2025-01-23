WarpCommand = SequenceCommand:extend()

function WarpCommand:new(scene, world, pipe, player)
    WarpCommand.super.new(self, {})

    if player:has('particle') or player:has('dead_component') then
        self:addCommands({RunCommand(function() end)})
        return
    end

    local warpPipe = pipe.warp_pipe_component
    local playerPosition = player.position
    local playerMove = player.moving_component

    local pipeLocation = pipe.position.position
    local teleportLocation = warpPipe.playerLocation

    CameraInstance:setCameraLeft(warpPipe.cameraLocation.x)

    WarpSystem:setWarping(true)
    PlayerSystem:enableInput(false)

    scene:stopMusic()

    local pipeSound = Concord.entity(world)
    pipeSound:give('sound_component', SOUND_ID.PIPE)

    player:give('collision_exempt_component')
    player:give('friction_exempt_component')
    player:remove('gravity_component')
    self:addCommands({
        RunCommand(function()
            --Set the player's speed to go in the pipe 
            if warpPipe.inDirection == DIRECTION.UP then
                playerMove.velocity.y = -1
                playerMove.acceleration.y = 0
                playerMove.velocity.x = 0
                playerMove.acceleration.x = 0
            elseif warpPipe.inDirection == DIRECTION.DOWN then
                playerMove.velocity.y = 1
                playerMove.acceleration.y = 0
                playerMove.velocity.x = 0
                playerMove.acceleration.x = 0
            elseif warpPipe.inDirection == DIRECTION.LEFT then
                playerMove.velocity.x = -1
                playerMove.acceleration.y = 0
                playerMove.velocity.x = 0
                playerMove.acceleration.x = 0
            elseif warpPipe.inDirection == DIRECTION.RIGHT then
                playerMove.velocity.x = 1
                playerMove.acceleration.x = 0
                playerMove.velocity.y = 0
                playerMove.acceleration.y = 0
            end
        end),
        --Enter the pipe
        WaitUntilCommand(function() 
            if warpPipe.inDirection == DIRECTION.UP then
                return player.position:getBottom() < pipeLocation.y - 32
            elseif warpPipe.inDirection == DIRECTION.RIGHT then
                return player.position:getLeft() > pipeLocation.x + 32
            elseif warpPipe.inDirection == DIRECTION.DOWN then
                return player.position:getTop() > pipeLocation.y + 32
            elseif warpPipe.inDirection == DIRECTION.LEFT then
                return player.position:getRight() < pipeLocation.x - 32
            else
                return false
            end
        end),
        -- Teleport or go to new level 
        RunCommand(function() 
            if warpPipe.newLevel.x ~= 0 and warpPipe.newLevel.y ~= 0 then
                CameraInstance:setCameraFrozen(false)
                player:remove('collision_exempt_component')
                player:remove('friction_exempt_component')
                love.graphics.setBackgroundColor(BACKGROUND_COLOR_BLACK)
                player:remove('wait_until_component')
                scene:switchLevel(warpPipe.newLevel.x, warpPipe.newLevel.y)
                return
            end
            -- Puts the piranha plants back in the pipe
            processEntitiesWithComponents(world, {'piranha_plant_component'},
            function(entity)
                local piranhaComponent = entity.piranha_plant_component
                if not piranhaComponent.inPipe then
                    entity.position.position.y = piranhaComponent.pipeCoordinates.y 
                    piranhaComponent.inPipe = true
                    entity.moving_component.velocity.y = 0
                    entity.timer_component:reset()
                    entity:remove('wait_until_component')
                end
            end)

            scene:setUnderwater(warpPipe.levelType == LEVEL_TYPE.UNDERWATER)
            scene:setLevelMusic(warpPipe.levelType)

            CameraInstance:setCameraX(warpPipe.cameraLocation.x * SCALED_CUBE_SIZE)
            CameraInstance:setCameraY(warpPipe.cameraLocation.y * SCALED_CUBE_SIZE)
            CameraInstance:updateCameraMin()
            CameraInstance:setCameraFrozen(warpPipe.cameraFreeze)
            love.graphics.setBackgroundColor(warpPipe.backgroundColor)

            if warpPipe.outDirection == DIRECTION.UP then
                playerPosition.position.x = teleportLocation.x * SCALED_CUBE_SIZE
                playerPosition.position.y = teleportLocation.y * SCALED_CUBE_SIZE
                playerPosition.position.y = playerPosition.position.y + 32
        
                playerMove.velocity.y = -1.0
                playerMove.velocity.x = 0.0
                playerMove.acceleration.x = 0.0
            elseif warpPipe.outDirection == DIRECTION.DOWN then
                playerPosition.position.x = teleportLocation.x * SCALED_CUBE_SIZE
                playerPosition.position.y = teleportLocation.y * SCALED_CUBE_SIZE
                playerPosition.position.y = playerPosition.position.y - 32
        
                playerMove.velocity.y = 1.0
                playerMove.velocity.x = 0.0
                playerMove.acceleration.x = 0.0
            elseif warpPipe.outDirection == DIRECTION.LEFT then
                playerPosition.position.x = teleportLocation.x * SCALED_CUBE_SIZE
                playerPosition.position.y = teleportLocation.y * SCALED_CUBE_SIZE
                playerPosition.position.x = playerPosition.position.x + 32
        
                playerMove.velocity.x = -1.0
                playerMove.velocity.y = 0.0
                playerMove.acceleration.y = 0.0
            elseif warpPipe.outDirection == DIRECTION.RIGHT then
                playerPosition.position.x = teleportLocation.x * SCALED_CUBE_SIZE
                playerPosition.position.y = teleportLocation.y * SCALED_CUBE_SIZE
                playerPosition.position.x = playerPosition.position.x - 32
        
                playerMove.velocity.x = 1.0
                playerMove.velocity.y = 0.0
                playerMove.acceleration.y = 0.0
            elseif warpPipe.outDirection == DIRECTION.NONE then
                playerPosition.position.x = teleportLocation.x * SCALED_CUBE_SIZE
                playerPosition.position.y = teleportLocation.y * SCALED_CUBE_SIZE
        
                playerMove.velocity.x = 0.0
                playerMove.velocity.y = 0.0
                playerMove.acceleration.x = 0.0
                playerMove.acceleration.y = 0.0
            end
        end)
        })
        
    -- Extra commands to add on if the pipe doesn't lead to a new level
    if warpPipe.newLevel.x == 0 and warpPipe.newLevel.y == 0 then
        self:addCommands({
            WaitUntilCommand(function()
                if warpPipe.outDirection == DIRECTION.UP then
                    return playerPosition:getBottom() < teleportLocation.y * SCALED_CUBE_SIZE
                elseif warpPipe.outDirection == DIRECTION.DOWN then
                    return playerPosition:getTop() > teleportLocation.y * SCALED_CUBE_SIZE
                elseif warpPipe.outDirection == DIRECTION.LEFT then
                    return playerPosition:getRight() < teleportLocation.x * SCALED_CUBE_SIZE
                elseif warpPipe.outDirection == DIRECTION.RIGHT then
                    return playerPosition:getLeft() > teleportLocation.x * SCALED_CUBE_SIZE
                else
                    return true
                end
            end),
            RunCommand(function()
                WarpSystem:setWarping(false)
                PlayerSystem:enableInput(true)
                PlayerSystem:setGameStart(false)

                playerMove.velocity.x = 0.0
                playerMove.acceleration.x = 0.0
                playerMove.velocity.y = 0.0
                playerMove.acceleration.y = 0.0

                player:give('gravity_component')
                player:remove('collision_exempt_component')
                player:remove('friction_exempt_component')
            end)
        })
    end
end

function WarpCommand:execute()
    WarpCommand.super.execute(self)
end

function WarpCommand:isFinished()
    return WarpCommand.super.isFinished(self)
end
