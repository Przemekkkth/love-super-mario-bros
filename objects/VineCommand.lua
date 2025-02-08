VineCommand = SequenceCommand:extend()

function VineCommand:new(scene, world, vine)
    VineCommand.super.new(self, {})
    local vineComponent = vine.vine_component
    local warpSystem = world:getSystem(WarpSystem)
    local player = world:getSystem(PlayerSystem):getMario()
    local playerMove = player.moving_component
    local playerPosition = player.position

    playerMove.velocity.y = -1.5
    warpSystem:setTeleportLevelY(vineComponent.resetYValue * SCALED_CUBE_SIZE)
    warpSystem:setTeleportPlayerCoordinates({x = vineComponent.resetTeleportLocation[1] * SCALED_CUBE_SIZE, y = vineComponent.resetTeleportLocation[2] * SCALED_CUBE_SIZE})
    warpSystem:setTeleportCameraCoordinates({x = vineComponent.resetTeleportLocation[1] * SCALED_CUBE_SIZE - 2 * SCALED_CUBE_SIZE,
                                             y = vineComponent.resetTeleportLocation[2] * SCALED_CUBE_SIZE - SCALED_CUBE_SIZE})

    local vineParts = vineComponent.vineParts

    self:addCommands({
        --When the player is out of camera range, change the camera location
        WaitUntilCommand(function() return not CameraInstance:inCameraRange(playerPosition) end),
        RunCommand(function()
            warpSystem:setTeleportCameraMax(CameraInstance:getCameraMaxX())
            CameraInstance:setCameraX(vineComponent.cameraCoordinates[1] * SCALED_CUBE_SIZE)
            CameraInstance:setCameraY(vineComponent.cameraCoordinates[2] * SCALED_CUBE_SIZE)

            warpSystem:setTeleportLevelType(scene:getLevelData().levelType)
            scene:setCurrentLevelType(scene:getLevelData().levelType)
            scene:setLevelMusic(vineComponent.newLevelType)

            -- Move the vines upwards
            for _, vinePiece in ipairs(vineParts) do
                vinePiece.moving_component.velocity.y = -1
            end
            -- Sets mario's position to be at the bottom of the vine
            playerPosition:setTop(vineParts[#vineParts].position:getTop())

        end),
        -- Wait until the vine has fully moved up, and then stop the vines from growing more
        WaitUntilCommand(function() 
            return vineParts[1].position:getTop() <= (vineComponent.teleportCoordinates[2] * SCALED_CUBE_SIZE) - (SCALED_CUBE_SIZE * 4)
        end),
        RunCommand(function()
            for _, vinePiece in ipairs(vineParts) do
                vinePiece.moving_component.velocity.y = 0.0
                vinePiece:remove('vine_component')
            end
        end),
        -- Wait until the player has climbed to the top of the vine, then end the sequence
        WaitUntilCommand(function() 
            return playerPosition:getBottom() <= vineParts[2].position:getBottom()
        end),
        RunCommand(function()
            -- Moves the player away from the vine
            playerPosition:setLeft( vineParts[1].position:getRight() )
            player.texture:setHorizontalFlipped(false)
            player:give('gravity_component')
            player:remove('friction_exempt_component')
            player:remove('collision_exempt_component')

            PlayerSystem:enableInput(true)
            WarpSystem:setClimbing(false)
            WarpSystem:setClimbed(true)
        end)
    })
end

function VineCommand:execute()
    VineCommand.super.execute(self)
end

function VineCommand:isFinished()
    return VineCommand.super.isFinished(self)
end
