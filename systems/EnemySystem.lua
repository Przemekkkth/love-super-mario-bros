EnemySystem = Concord.system({ pool = {'enemy'}})

function EnemySystem:update()
    if not self:isEnabled() then
        return
    end

    local world = self:getWorld()
    local projectiles = world:getSystem(ProjectileSystem):getEntities()
    for _, entity in ipairs(projectiles) do
        if entity:has('position') and entity:has('moving_component') then
            if entity.projectile.type == PROJECTTILE_TYPE.FIREBALL then
                if entity:has('bottom_collision_component') then
                    entity.moving_component.velocity.y = -PROJECTILE_BOUNCE
                    entity:remove('bottom_collision_component')
                end
            end
        end
    end

    -- Main enemy update loop
    local enemies = world:getSystem(EnemySystem):getEntities()
    for _, enemy in ipairs(enemies) do
        if enemy:has('position') then
            local position = enemy.position
            local move = enemy.moving_component
            local enemyComponent = enemy.enemy

            local enemyType = enemyComponent.type
            if enemyType == ENEMY_TYPE.BOWSER then
                self:performBowserActions(enemy)

            elseif enemyType == ENEMY_TYPE.HAMMER_BRO then
                self:performHammerBroActions(world, enemy)

            elseif enemyType == ENEMY_TYPE.LAKITU then
                self:performLakituActions(world, enemy)

            elseif enemyType == ENEMY_TYPE.SPINE then
                -- Turn spine eggs into spiny shells when they hit the ground
                local animation = enemy.animation_component
                local firstAnimationID = 502
                if enemy:has('bottom_collision_component') and animation.frameIDs[1] ~= 502 then
                    animation.frameIDs = {502, 503}
                    animation.currentFrame = 0
                    animation.frameTimer = 0
                    animation:setFramesPerSecond(5)
                end

            elseif enemyType == ENEMY_TYPE.LAVA_BUBBLE then
                local texture = enemy.texture
                -- If going up and upside down
                if move.velocity.y <= 0 and texture:isVerticalFlipped() then
                    texture:setVerticalFlipped(false)
                elseif move.velocity.y > 0 and not texture:isVerticalFlipped() then
                    -- If going down and not upside down
                    texture:setVerticalFlipped(true);
                end
            end

            -- If the enemy is standing on a block and the block gets hit
            if enemy:has('bottom_collision_component') then
                processEntitiesWithComponents(world, {'block_bump_component'},
                function(block) 
                    if AABBCollision(enemy.position, block.position) then
                        enemy:give('enemy_destroyed_component')
                    end
                end)
            end

            -- Enemy + Projectile collisions
            local projectiles = world:getSystem(ProjectileSystem):getEntities()
            for _, projectile in ipairs(projectiles) do
                if projectile:has('moving_component') then
                    local projectilePosition = projectile.position
                    if not AABBCollision(position, projectilePosition) or enemy:has('projectile') or enemy:has('particle') or
                        enemyType == ENEMY_TYPE.LAVA_BUBBLE or enemyType == ENEMY_TYPE.FIRE_BAR or enemyType == ENEMY_TYPE.BULLET_BILL then
                    elseif enemy:has('bowser_component') then
                        if projectile.projectile.type == PROJECTTILE_TYPE.FIREBALL then
                            --TO DO 
                            -- Decrease HP
                        end
                    else
                        enemy:give('enemy_destroyed_component')
                        world:removeEntity(projectile)
                    end
                end
            end

            -- Enemy + Enemy Collision (prevents to enemies from walking through each other)
            local others = world:getSystem(EnemySystem):getEntities()
            for _, other in ipairs(others) do
                local otherPosition = other.position
                if not AABBCollision(position, otherPosition) or enemy == other or enemy:has('dead_component') or enemy:has('piranha_plant_component')
                    or other:has('particle') or enemyType == ENEMY_TYPE.SPINE or enemyType == ENEMY_TYPE.BULLET_BILL then
                --pass
                elseif other.enemy.type == ENEMY_TYPE.KOOPA_SHELL and other.moving_component.velocity.x ~= 0 then
                    enemy:give('enemy_destroyed_component'):give('move_outside_camera_component')

                    local addScore = Concord.entity(world)
                    addScore:give('add_score_component', 100)
                else
                -- If the other enemy is to the left
                    if otherPosition:getLeft() < position:getLeft() and otherPosition:getRight() < position:getRight() then
                        other:give('right_collision_component')
                    end

                -- If the other enemy is to the right
                    if otherPosition:getLeft() > position:getLeft() and otherPosition:getRight() > position:getRight() then
                        other:give('left_collision_component')
                    end
                end
            end

            -- Moves Koopas in the opposite direction if not on the ground
            if CameraInstance:inCameraRange(position) and enemyType == ENEMY_TYPE.KOOPA then
                if not (enemy:has('bottom_collision_component') or enemy:has('dead_component')) and math.abs(move.velocity.y) < 1 then
                    move.velocity.x = move.velocity.x * -1
                    local horizontalFlipped = enemy.texture:isHorizontalFlipped()
                    enemy.texture:setHorizontalFlipped(not horizontalFlipped)
                end
            end

            if enemyType ~= ENEMY_TYPE.PIRANHA_PLANT and enemyType ~= ENEMY_TYPE.CHEEP_CHEEP and 
                enemyType ~= ENEMY_TYPE.BLOOPER and enemyType ~= ENEMY_TYPE.LAKITU and
                enemyType ~= ENEMY_TYPE.LAVA_BUBBLE and enemyType ~= ENEMY_TYPE.BULLET_BILL then
                    -- Reverses the direction of the enemy when it hits a wall or another enemy
                    if enemy:has('left_collision_component') then
                        if enemyType == ENEMY_TYPE.KOOPA_SHELL then
                            move.velocity.x = 6.0
                        else
                            move.velocity.x = ENEMY_SPEED
                        end

                        enemy.texture:setHorizontalFlipped(true)
                        enemy:remove('left_collision_component')
                    elseif enemy:has('right_collision_component') then
                        if enemyType == ENEMY_TYPE.KOOPA_SHELL then
                            move.velocity.x = -6.0
                        else
                            move.velocity.x = -ENEMY_SPEED
                        end

                        enemy.texture:setHorizontalFlipped(false)
                        enemy:remove('right_collision_component')
                    end
            end

            self:checkEnemyDestroyed(enemy)

            if enemyType ~= ENEMY_TYPE.KOOPA_PARATROOPA then 
                enemy:remove('bottom_collision_component')
            end

            enemy:remove('top_collision_component'):remove('left_collision_component'):remove('right_collision_component')
        end
    end
end

function EnemySystem:performBowserActions(entity)
    local world = self:getWorld()
    if not CameraInstance:inCameraRange(entity.position) or entity:has('frozen_component') or entity:has('dead_component') then
        return
    end

    local bowserComponent = entity.bowser_component
    local bowserTexture = entity.texture
    local player = world:getSystem(PlayerSystem):getMario()

    local flipHorizontal = player.position.position.x > entity.position.position.x
    if flipHorizontal ~= bowserTexture:isHorizontalFlipped() then
        if bowserComponent.lastMoveDirection == DIRECTION.LEFT then
            bowserComponent.lastMoveDirection = DIRECTION.RIGHT
        else
            bowserComponent.lastMoveDirection = DIRECTION.LEFT
        end
        bowserTexture:setHorizontalFlipped(flipHorizontal)
    end

    bowserComponent.lastMoveTime = bowserComponent.lastMoveTime + 1
    bowserComponent.lastStopTime = bowserComponent.lastStopTime + 1
    bowserComponent.lastJumpTime = bowserComponent.lastJumpTime + 1 
    bowserComponent.lastAttackTime = bowserComponent.lastAttackTime + 1 

    if bowserComponent.currentMoveIndex == 0 then
        if bowserComponent.lastStopTime >= MAX_FPS * 2 then
            bowserComponent.movements[1](entity)
            bowserComponent.movements[3](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    elseif bowserComponent.currentMoveIndex == 1 then
        if bowserComponent.lastStopTime >= MAX_FPS * 3 then
            bowserComponent.movements[2](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    elseif bowserComponent.currentMoveIndex == 2 then 
        if bowserComponent.lastStopTime >= MAX_FPS * 2 then
            bowserComponent.movements[1](entity)
            bowserComponent.movements[3](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    elseif bowserComponent.currentMoveIndex == 3 then 
        if bowserComponent.lastStopTime >= MAX_FPS * 3 then
            bowserComponent.movements[2](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    elseif bowserComponent.currentMoveIndex == 4 then
        if bowserComponent.lastStopTime >= MAX_FPS * 2 then
            bowserComponent.movements[1](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    elseif bowserComponent.currentMoveIndex == 5 then  
        if bowserComponent.lastStopTime >= MAX_FPS * 3 then
            bowserComponent.movements[2](entity)

            bowserComponent.currentMoveIndex = bowserComponent.currentMoveIndex + 1 
        end
    end

    if bowserComponent.lastAttackTime >= MAX_FPS * 2 then
        local attackSelect = math.random(1, #bowserComponent.attacks)
        local hammerAmount = math.random(6, 10)
        bowserComponent.attacks[attackSelect](entity, hammerAmount);
    end
end

function EnemySystem:performHammerBroActions(world, entity)
    local position = entity.position
    local texture = entity.texture
    local move    = entity.moving_component
    local hammer_bro_component = entity.hammer_bro_component

    if not CameraInstance:inCameraRange(position) then
        return
    end

    local player = world:getSystem(PlayerSystem):getMario()

    local playerPosition = player.position

    if playerPosition.position.x > position.position.x and not texture:isHorizontalFlipped() then
        texture:setHorizontalFlipped(true)
    elseif playerPosition.position.x < position.position.x and texture:isHorizontalFlipped() then
        texture:setHorizontalFlipped(false)
    end

    if hammer_bro_component == nil then
        return
    end
    if hammer_bro_component.hammer ~= nil then
        if not hammer_bro_component.hammer:has('gravity_component') then
            hammer_bro_component.hammer.position:setCenterX(position:getCenterX())
        end
    end

    hammer_bro_component.lastThrowTime = hammer_bro_component.lastThrowTime + 1 
    hammer_bro_component.lastJumpTime = hammer_bro_component.lastJumpTime + 1 
    hammer_bro_component.lastMoveTime = hammer_bro_component.lastMoveTime + 1 

    if hammer_bro_component.lastThrowTime == MAX_FPS * 2 then
        hammer_bro_component.throwHammer(entity)

        if hammer_bro_component.lastJumpTime >= MAX_FPS * 3 then
            CommandScheduler:addCommand(DelayedCommand(function() 
                move.velocity.y = -10 
                hammer_bro_component.lastJumpTime = 0 end, 0.75))
        end
    end

    if hammer_bro_component.lastMoveTime >= MAX_FPS * 2.5 then
        move.velocity.x = -1 * move.velocity.x
        hammer_bro_component.lastMoveTime = 0
    end

end

function EnemySystem:performLakituActions(world, entity)
    local position = entity.position
    local texture = entity.texture
    local move    = entity.moving_component
    local lakituComponent = entity.lakitu_component

    if not CameraInstance:inCameraRange(position) then
        return
    end

    local player = world:getSystem(PlayerSystem):getMario()
    local playerPosition = player.position

    if playerPosition.position.x > position.position.x and not texture:isHorizontalFlipped() then
        texture:setHorizontalFlipped(true)
    elseif playerPosition.position.x < position.position.x and texture:isHorizontalFlipped() then
        texture:setHorizontalFlipped(false);
    end

    lakituComponent.sideChangeTimer = lakituComponent.sideChangeTimer + 1

    if lakituComponent.sideChangeTimer >= MAX_FPS * 8 then
        if lakituComponent.lakituSide == DIRECTION.LEFT then
            lakituComponent.lakituSide = DIRECTION.RIGHT
        else
            lakituComponent.lakituSide = DIRECTION.LEFT
        end
        lakituComponent.sideChangeTimer = 0
    end

    local flag
    for _, entity_ in ipairs(world:getEntities()) do
        if entity_:has('flag_component') then
            flag = entity_
            break
        end
    end

    -- Lakitu stops harassing you if you're near the flag
    if flag.position.position.x - playerPosition.position.x < 30 * SCALED_CUBE_SIZE then
        move.velocity.x = -4.0
        return
    end

    -- If not near the flag, move lakitu to the desired side of the screen
    if lakituComponent.lakituSide == DIRECTION.RIGHT then
        move.velocity.x = lakituComponent.speedController:calculateWithSetpoint(
            position.position.x, CameraInstance:getCameraCenterX() + SCALED_CUBE_SIZE * 6)
    else
        move.velocity.x = lakituComponent.speedController:calculateWithSetpoint(
            position.position.x, CameraInstance:getCameraCenterX() - SCALED_CUBE_SIZE * 6)
    end

     -- Limits the speed to prevent lakitu from going zoooooooooooooooom
     if math.abs(move.velocity.x) > 6.0 then
        if move.velocity.x > 0 then
            move.velocity.x = 6.0
        else
            move.velocity.x = -6.0
        end
     end
end

function EnemySystem:checkEnemyDestroyed(world, enemy)
    if enemy:has('dead_component') then
        return
    end

    local move = enemy.moving_component
    local enemyComponent = enemy.enemy

    if enemyComponent.type == ENEMY_TYPE.PIRANHA_PLANT then
        if enemy:has('enemy_destroyed_component') then
            enemy:give('partice'):give('dead_component'):give('enemy_destroyed_componet'):give('animation_componnet')

            local floatingText = Concord.entity(world)
            floating_text:give('create_floating_text_component', enemy, '100')

            local destroyedSonund = Concord.entity(world)
            destroyedSonund:give('sound_component', SOUND_ID.KICK)

            enemy:give('destroy_delayed_component', 1)
        end

        return
    end

    -- If enemey is crushed
    if enemy:has('crushable_component') and enemy:has('crushed_component') then
        -- When the paratroopa gets it's still crushable
        local removeCrushable = enemyComponent.type ~= ENEMY_TYPE.KOOPA_PARATROOPA
        enemey.crushable_component.whenCrushed(enemy)
        enemey:remove('crushed_component')

        if removeCrushable then
            enemey:remove('crushable_component')
        end

        local destroyedSonund = Concord.entity(world)
        destroyedSonund:give('sound_component', SOUND_ID.STOMP)

        local floatingText = Concord.entity(world)
        floating_text:give('create_floating_text_component', enemy, '100')
    end

    -- Enemies that were destroyed through either a projectile or super star mario
    if enemy:has('enemy_destroyed_component') then
        if enemyComponent.type ~= ENEMY_TYPE.BULLET_BILL then
            move.velocity.y = -ENEMY_BOUNCE
            enemey.texture:setVerticalFlipped(true)
        end

        enemy:give('partice'):give('dead_component'):give('destroy_outside_camera_camera')
        enemy:remove('enemy_destroyed_camera'):remove('animation_component')

        local destroyedSonund = Concord.entity(world)
        destroyedSonund:give('sound_component', SOUND_ID.KICK)

        local floatingText = Concord.entity(world)
        floating_text:give('create_floating_text_component', enemy, '100')
    end
end

function EnemySystem:checkEnemyDestroyed(enemy)
    local world = self:getWorld()
    if enemy:has('dead_component') then
        return
    end

    local move = enemy.moving_component
    local enemyComponent = enemy.enemy

    if enemyComponent.type == ENEMY_TYPE.PIRANHA_PLANT then --Destroy Pirhanna
        if enemy:has('enemy_destroyed_component') then
            enemy:give('particle')
            enemy:give('dead_component')
            enemy:remove('enemy_destroyed_component')
            enemy:remove('animation_component')

            local floatingText = Concord.entity(world)
            floatingText:give('create_floating_text_component', enemy, 100)

            local destroyedSound = Concord.entity(world)
            destroyedSound:give('sound_component', SOUND_ID.KICK)

            enemy:give('destroy_delayed_component', 1)
        end
        return
    end

    -- If enemy is crushed
    if enemy:has('crushable_component') and enemy:has('crushed_component') then
        -- When the paratroopa gets crushed it's still crushable
        local removeCrushable = (enemyComponent.type ~= ENEMY_TYPE.KOOPA_PARATROOPA)
        enemy.crushable_component.whenCrushed(enemy)
        enemy:remove('crushed_component')

        if removeCrushable then
            enemy:remove('crushable_component')
        end

        local floatingText = Concord.entity(world)
        floatingText:give('create_floating_text_component', enemy, 100)

        local stompSound = Concord.entity(world)
        stompSound:give('sound_component', SOUND_ID.STOMP)
    end
    -- Enemies that were destroyed through either a projectile or super star mario
    if enemy:has('enemy_destroyed_component') then
        if enemyComponent.type ~= ENEMY_TYPE.BULLET_BILL then
            move.velocity.y = -ENEMY_BOUNCE
            enemy.texture:setVerticalFlipped(true)
        end

        enemy:give('particle')
        enemy:give('dead_component')
        enemy:give('destroy_outside_camera_component')

        enemy:remove('enemy_destroyed_component')
        enemy:remove('animation_component')

        local floatingText = Concord.entity(world)
        floatingText:give('create_floating_text_component', enemy, 100)

        local destroyedSound = Concord.entity(world)
        destroyedSound:give('sound_component', SOUND_ID.KICK)
    end
end

function EnemySystem:getEntities()
    return self.pool
end