PhysicsSystem = Concord.system()

function checkCollisionY(solid, position, move, adjustPosition)
    local solidPosition = solid.position
    local direction = COLLISION_DIRECTION.NONE

    if move.velocity.y >= 0.0 then
        --If falling
        if AABBTotalCollisionX8(position.position.x + position.hitbox.x + (TILE_ROUNDNESS / 2),
                                position.position.y + position.hitbox.y + move.velocity.y,
                                position.hitbox.w - TILE_ROUNDNESS, position.hitbox.h,
                                solidPosition.position.x + (TILE_ROUNDNESS / 2),
                                solidPosition.position.y, solidPosition.hitbox.w - TILE_ROUNDNESS,
                                solidPosition.hitbox.h) then
            local topDistance = math.abs(solidPosition:getTop() - (position:getBottom() + move.velocity.y))
            local bottomDistance = math.abs((position:getTop() + move.velocity.y) - solidPosition:getBottom())

            if topDistance < bottomDistance then
                if adjustPosition then
                    position:setBottom(solidPosition:getTop());
                end
            end
            solid:give('top_collision_component')
            direction = COLLISION_DIRECTION.BOTTOM
        end
    else
        --Jumping
        if AABBTotalCollisionX8(position.position.x + position.hitbox.x + TILE_ROUNDNESS,
        position.position.y + position.hitbox.y + move.velocity.y,
        position.hitbox.w - (TILE_ROUNDNESS * 2), position.hitbox.h,
        solidPosition.position.x + TILE_ROUNDNESS, solidPosition.position.y,
        solidPosition.hitbox.w - (TILE_ROUNDNESS * 2),
        solidPosition.hitbox.h) then
            local topDistance = math.abs(solidPosition:getTop() - (position:getBottom() + move.velocity.y))
            local bottomDistance = math.abs( (position:getTop() + move.velocity.y) - solidPosition:getBottom())

            if topDistance > bottomDistance then
                if adjustPosition then
                    position:setTop(solidPosition:getBottom())
                end
            end
            solid:give('bottom_collision_component')
            direction = COLLISION_DIRECTION.TOP
        end
    end

    return direction
end

function checkCollisionX(solid, position, move, adjustPosition)
    local solidPosition = solid.position
    local direction = COLLISION_DIRECTION.NONE


    if AABBTotalCollisionX4(position.position.x + position.hitbox.x + move.velocity.x,
                            position.position.y + position.hitbox.y, position.hitbox.w,
                            position.hitbox.h - (TILE_ROUNDNESS * 2), solidPosition) then
        local leftDistance = math.abs((position.position.x + position.hitbox.x + move.velocity.x) -
                                solidPosition:getRight())
        local rightDistance = math.abs( (position.position.x + position.hitbox.x + position.hitbox.w + move.velocity.x) - solidPosition:getLeft())
        if leftDistance < rightDistance then
            if adjustPosition then
                -- Entity is inside block, push out
                if position:getLeft() < solidPosition:getRight() then
                    position.position.x = position.position.x + math.min(0.5, solidPosition:getRight() - position:getLeft())
                else
                    -- The entity is about to get inside the block
                    position:setLeft(solidPosition:getRight())
                end
            end
            solid:give('right_collision_component')
            direction = COLLISION_DIRECTION.LEFT
        else
            if adjustPosition then
                -- Entity is inside block, push out
                if position:getRight() > solidPosition:getLeft() then
                    position.position.x = position.position.x - math.min(0.5, position:getRight() - solidPosition:getLeft())
                else
                    -- The entity is about to get inside the block
                    position:setRight(solidPosition:getLeft())
                end
            end
            solid:give('left_collision_component')
            direction = COLLISION_DIRECTION.RIGHT
        end
    end

    return direction
end

function PhysicsSystem:init(world) --onAddedToWorld(world))
end

function PhysicsSystem:updateFireBars() 
    local world = self:getWorld()
    processEntitiesWithComponents(world, {'fire_bar_component', 'position'},
    function(entity)
        local fireBar = entity.fire_bar_component
        local position = entity.position

        if fireBar.barAngle > 360 then
            fireBar.barAngle = fireBar.barAngle - 360
        elseif fireBar.barAngle < 0 then
            fireBar.barAngle = fireBar.barAngle + 360
        end

        position.position.x = fireBar:calculateXPosition(fireBar.barAngle) + fireBar.pointOfRotation.x 
        position.position.y = -fireBar:calculateYPosition(fireBar.barAngle) + fireBar.pointOfRotation.y
    end)
end
 
function PhysicsSystem:updateMovingPlatforms() 
    local world = self:getWorld()
    processEntitiesWithComponents(world, {'moving_platform_component', 'moving_component', 'position'},
    function(entity)
        local platform = entity.moving_platform_component
        local platformMove = entity.moving_component
        local position = entity.position
        local motionType = platform.motionType
        local ySpeedFactor = 2.8 -- It was 3.8
        if motionType == PLATFORM_MOTION_TYPE.ONE_DIRECTION_REPEATED then
            if platform.movingDirection == DIRECTION.LEFT or platform.movingDirection == DIRECTION.RIGHT then
                if position.position.x < platform.minPoint then
                    position.position.x = platform.maxPoint
                elseif position.position.x > platform.maxPoint then
                    position.position.x = platform.minPoint
                end
            elseif platform.movingDirection == DIRECTION.UP or platform.movingDirection == DIRECTION.DOWN then
                if position.position.y < platform.minPoint then
                    position.position.y = platform.maxPoint
                elseif position.position.y > platform.maxPoint then
                    position.position.y = platform.minPoint
                end
            end
        elseif motionType == PLATFORM_MOTION_TYPE.BACK_AND_FORTH then
            if platform.movingDirection == DIRECTION.LEFT then
                if position:getLeft() <= platform.minPoint then
                    platform.movingDirection = DIRECTION.RIGHT
                else
                    local newVelocity = -platform:calculateVelocity(position:getRight() - platform.minPoint, (platform.maxPoint - platform.minPoint) / ySpeedFactor)
                    platformMove.velocity.x = newVelocity
                end
            elseif platform.movingDirection == DIRECTION.RIGHT then
                if position:getRight() >= platform.maxPoint then
                    platform.movingDirection = DIRECTION.LEFT
                else
                    local newVelocity = platform:calculateVelocity(platform.maxPoint - position:getLeft(), (platform.maxPoint - platform.minPoint) / ySpeedFactor)
                    platformMove.velocity.x = newVelocity
                end
            elseif platform.movingDirection == DIRECTION.UP then
                if position:getTop() <= platform.minPoint then
                    platform.movingDirection = DIRECTION.DOWN
                else
                    local newVelocity = -platform:calculateVelocity(position:getBottom() - platform.minPoint, (platform.maxPoint - platform.minPoint) / ySpeedFactor)
                    platformMove.velocity.y = newVelocity
                end
            elseif platform.movingDirection == DIRECTION.DOWN then
                if position:getBottom() >= platform.maxPoint then
                    platform.movingDirection = DIRECTION.UP
                else
                    local newVelocity = platform:calculateVelocity(platform.maxPoint - position:getTop(), (platform.maxPoint - platform.minPoint) / ySpeedFactor)
                    platformMove.velocity.y = 1--newVelocity
                end
            end
        elseif motionType == PLATFORM_MOTION_TYPE.GRAVITY then
            if entity:has('top_collision_component') then
                --platformMove.acceleration.y = 0.1
                platformMove.velocity.y = 1
            else
                platformMove.acceleration.y = 0
                platformMove.velocity.y = platformMove.velocity.y * 0.92
            end

            entity:remove('top_collision_component')
        end
    end)
end
 
function PhysicsSystem:updatePlatformLevels() 
--To Do
    local world = self:getWorld()
    processEntitiesWithComponents(world, {'platform_level_component'},
    function(entity)
        local platformLevel = entity.platform_level_component
        local platformPosition = entity.position
        local platformMove = entity.moving_component

        if not CameraInstance:inCameraRange(platformPosition) then
            return
        end

        local linePosition = platformLevel.pulleyLine.position
        linePosition.scale.y = platformPosition:getTop() - linePosition:getTop()
        local otherPlatform = platformLevel:getOtherPlatform()

        -- If the level reaches max height
        if platformPosition:getTop() < platformLevel.pulleyHeight then
            platformPosition:setTop(platformLevel.pulleyHeight)
            platformMove.velocity.x = 0
            platformMove.velocity.y = 0

            otherPlatform.moving_component.acceleration.y = 0
            otherPlatform:give('gravity_component')
            otherPlatform:give('collision_exempt_component')
            otherPlatform:give('destroy_outside_camera_component')

            otherPlatform:remove('platform_level_component')
            entity:remove('platform_level_component')
            return
        end

        if not entity:has('top_collision_component') then
            --Slows the platform down if the other platform isn't accelerating
            if otherPlatform.moving_component.acceleration.y == 0 then
                platformMove.velocity.y = platformMove.velocity.y * 0.92
                -- Sets the 2 platforms to have opposite velocities
                otherPlatform.moving_component.velocity.y = -platformMove.velocity.y
            end

            platformMove.acceleration.y = 0
            return
        end

        platformMove.acceleration.y = 0.12
        -- Sets the 2 platforms to have opposite velocities
        otherPlatform.moving_component.velocity.y = -platformMove.velocity.y
        -- NEW CODE
        if platformMove.velocity.y > 1 then
            platformMove.velocity.y = 1
        elseif platformMove.velocity.y < -1 then
            platformMove.velocity.y = -1
        end
        --END NEW CODE
        entity:remove('top_collision_component')
    end)
end

function PhysicsSystem:update()
    if not self:isEnabled() then
        return
    end
    
    local world = self:getWorld()
    --Update gravity for entities that have a gravity component
    processEntitiesWithComponents(world, {'gravity_component', 'moving_component'},
    function(entity) 
        if not CameraInstance:inCameraRange(entity.position) and not (entity:has('move_outside_camera_component') or entity:has('player')) 
            or entity:has('frozen_component') then
                return
        end
        entity.moving_component.velocity.y = entity.moving_component.velocity.y + 0.575
    end)

    --Change the y position of the block being bumped
    processEntitiesWithComponents(world, {'block_bump_component', 'position'},
    function(entity) 
        local blockBump = entity.block_bump_component
        if blockBump.yChanges == nil then
            entity:remove('block_bump_component')
            return
        end
        entity.position.position.y = entity.position.position.y + blockBump.yChanges[blockBump.yChangeIndex]
        blockBump.yChangeIndex = blockBump.yChangeIndex + 1
        if blockBump.yChangeIndex > #blockBump.yChanges then
            entity:remove('block_bump_component')
        end
    end)

    --Main Physics update loop
    processEntitiesWithComponents(world, {'moving_component', 'position'},
    function(entity) 
        if entity:has('frozen_component') then
            return
        end

        if not CameraInstance:inCameraRange(entity.position) and not (entity:has('move_outside_camera_component') or entity:has('player')) then
            if entity:has('destroy_outside_camera_component') then
                world:removeEntity(entity)
            end

            return
        end

        local move = entity.moving_component
        local position = entity.position

        position.position.x = position.position.x + move.velocity.x
        position.position.y = position.position.y + move.velocity.y

        move.velocity.x = move.velocity.x + move.acceleration.x
        move.velocity.y = move.velocity.y + move.acceleration.y
        
        if not ( entity:has('enemy') or entity:has('collectible') ) and not entity:has('friction_exempt_component') then
            move.velocity.x = move.velocity.x * FRICTION 
        end

        if move.velocity.x > MAX_SPEED_X then
            move.velocity.x = MAX_SPEED_X
        end

        if move.velocity.x < -MAX_SPEED_X then
            move.velocity.x = -MAX_SPEED_X
        end

        if move.velocity.y > MAX_SPEED_Y then
            move.velocity.y = MAX_SPEED_Y
        end

        processEntitiesWithComponents(world, {'tile_component', 'foreground'},
        function(other)
            --We don't check collisions of particles
            if entity == other or other:has('particle') or entity:has('particle') then
                return
            end

            local collidedDirectionVertical
            local collidedDirectionHorizontal

            if entity:has('collision_exempt_component') or entity:has('invisible_block_component') then
                collidedDirectionVertical = checkCollisionY(other, position, move, false)
                collidedDirectionHorizontal = checkCollisionX(other, position, move, false)
            else
                collidedDirectionVertical = checkCollisionY(other, position, move, true)
                collidedDirectionHorizontal = checkCollisionX(other, position, move, true)

                if collidedDirectionVertical ~= COLLISION_DIRECTION.NONE then
                    move.velocity.y = 0.0
                    move.acceleration.y = 0.0
                end

                if collidedDirectionHorizontal ~= COLLISION_DIRECTION.NONE then
                    move.velocity.x = 0.0
                    move.acceleration.x = 0.0
                end

                if collidedDirectionVertical == COLLISION_DIRECTION.TOP then
                    entity:give('top_collision_component')
                elseif collidedDirectionVertical == COLLISION_DIRECTION.BOTTOM then
                    entity:give('bottom_collision_component')
                end

                if collidedDirectionHorizontal == COLLISION_DIRECTION.LEFT then
                    entity:give('left_collision_component')
                elseif collidedDirectionHorizontal == COLLISION_DIRECTION.RIGHT then
                    entity:give('right_collision_component')
                end
                
            end
        end)

        if math.abs(move.velocity.y) < MARIO_ACCELERATION_X / 2 and move.acceleration.y == 0.0 then
            move.velocity.y = 0
        end

        if math.abs(move.velocity.x) < MARIO_ACCELERATION_X / 2 and move.velocity.x == 0.0 then
            move.velocity.x = 0
        end
    end)

    -- Update the spinning of the fire bars
    self:updateFireBars()
 
    -- Update the velocities for the moving platforms
    self:updateMovingPlatforms()
 
    -- Update the velocities for the platform levels
    self:updatePlatformLevels()
end