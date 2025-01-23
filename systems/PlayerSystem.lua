PlayerSystem = Concord.system()

PlayerSystem.inputEnabled = true
PlayerSystem.inGameStart = false

function PlayerSystem:init(world) --onAddedToWorld(world))
    self.mario = Concord.entity(world)
    self.xDir = 0
    self.left = 0
    self.right = 0
    self.jump = 0
    self.duck = 0
    self.launchFireball = 0
 
    self.holdFireballTexture = 0
    self.jumpHeldTime = 0
 
    self.trampolineCollided = false
    self.currentState = ANIMATION_STATE.STANDING
    self.running = 0
    self.jumpHeld = 0
    self.underwater = false
    self.underwaterControllerX = PIDController(0.20, 0, 0.02, 60)
end

function PlayerSystem:setScene(scene)
    self.scene = scene
    local startCoordinates = self.scene:getLevelData().playerStart
    self.mario:give('position', {x = startCoordinates.x * SCALED_CUBE_SIZE, y = startCoordinates.y * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    self.mario:give('texture', PLAYER_TILESHEET_IMG, false, false)
    self.mario:give('spritesheet', self.mario.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 9, 0,
                                                       ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, MapInstance:getPlayerCoord(0))
    self.mario.texture:setVisible(true)
    self.mario:give('moving_component', {x = 0, y = 0}, {x = 0, y = 0})
    self.mario:give('player')
    self.mario:give('frozen_component')
end

function PlayerSystem:isInputEnabled() 
    return PlayerSystem.inputEnabled
end

function PlayerSystem:isGameStart()
    return PlayerSystem.inGameStart;
end

function PlayerSystem:enableInput(val)
    PlayerSystem.inputEnabled = val
end

function PlayerSystem:setGameStart(val)
    PlayerSystem.inGameStart = val;
end

function PlayerSystem:isSmallMario()
    return self.mario.player.playerState == PLAYER_STATE.SMALL_MARIO
end

function PlayerSystem:isSuperMario()
    return self.mario.player.playerState == PLAYER_STATE.SUPER_MARIO
end

function PlayerSystem:isFireMario()
    return self.mario.player.playerState == PLAYER_STATE.FIRE_MARIO
end

function PlayerSystem:isSuperStar()
    return self.mario.player.superStar
end

function PlayerSystem:setUnderwater(val)
    self.underwater = val
end
 
function PlayerSystem:onGameOver(outOfBounds)
    local world = self:getWorld()
    local position = self.mario.position
    local spritesheet = self.mario.spritesheet

    if outOfBounds and (self:isSuperMario() or self:isFireMario() ) then
        position.scale.y = SCALED_CUBE_SIZE
        position.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}

        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)
        spritesheet:setSpritesheetCoordinates(MapInstance:getBlockCoord(1))
        self.mario.player.playerState = PLAYER_STATE.SMALL_MARIO
    end

    if self:isSuperMario() then
        self.mario.player.superStar = false
    end

    if self.underwater then
        self.underwater = false
    end

    if not outOfBounds and (self:isSuperMario() or self:isFireMario()) then
        self:shrink()
        return
    end

    local move = self.mario.moving_component
    move.velocity.x = 0
    move.acceleration.x = 0
    move.velocity.y = -12.5

    self.mario:give('particle')
    spritesheet:setSpritesheetCoordinates(MapInstance:getBlockCoord(1))
    self.currentState = ANIMATION_STATE.GAMEOVER

    self.mario:give('callback_component', 
    function(entity) 
        entity:remove('particle')
        self.scene:restartLevel()
    end, 180)

    self.scene:stopTimer()
    self.scene:stopMusic()

    local deathSound = Concord.entity(world)
    deathSound:give('sound_component', SOUND_ID.DEATH)
end

function PlayerSystem:shrink()
    local world = self:getWorld()
    self.mario.player.playerState = PLAYER_STATE.SMALL_MARIO
    local shrinkSound = Concord.entity(world)
    shrinkSound:give('sound_component', SOUND_ID.PIPE)

    self.mario:give('animation_component', 
    {25, 45, 46, 25, 45, 46, 25, 45, 46},   --frameIDs
    8,                                      --framesPerSecond
    MapInstance.PlayerIDCoordinates, false) --coordinateSupplier

    self.mario:give('frozen_component')
    self.mario:give('callback_component',
    function(entity)
        local position = self.mario.position
        local spritesheet = self.mario.spritesheet
        -- shortens the player
        position.scale.y = SCALED_CUBE_SIZE
        position.hitbox.h = SCALED_CUBE_SIZE
        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE)
        spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(1))
        self.mario:remove('frozen_component')
        self.mario:give('ending_blink_component', 10, 150)
    end, 45)
end

function PlayerSystem:grow(growType)
    local world = self:getWorld()
    if growType == GROW_TYPE.ONEUP then
        local addLives = Concord.entity(world)
        addLives:give('add_lives_component')

        local floatingText = Concord.entity(world)
        floatingText:give('create_floating_text_component', self.mario, '1-UP')
    elseif growType == GROW_TYPE.SUPER_STAR then
        self.mario.player.superStar = true
        self.mario:give('ending_blink_component', 1, 600)
        self.mario:give('callback_component', 
        function(entuty) 
            self.mario.player.superStar = false
            self.scene:resumeLastPlayedMusic()
        end, 600)

        local superStarMusic = Concord.entity(world)
        superStarMusic:give('music_component', MUSIC_ID.SUPER_STAR)
    elseif growType == GROW_TYPE.MUSHROOM then
        local addScore = Concord.entity(world)
        addScore:give('add_score_component', 1000)

        local floatingText = Concord.entity(world)
        floatingText:give('create_floating_text_component', self.mario, '1000')

        local powerUpSound = Concord.entity(world)
        powerUpSound:give('sound_component', SOUND_ID.POWER_UP_COLLECT)
        
        if self:isSuperMario() or self:isFireMario() then
            return
        end

        local position = self.mario.position
        local spritesheet = self.mario.spritesheet

        position:setTop(position:getTop() - position.scale.y) -- Makes the player taller
        position.scale.y = SCALED_CUBE_SIZE * 2
        position.hitbox.h = SCALED_CUBE_SIZE * 2
        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE * 2)
        self.mario:give('animation_component', 
                    {46, 45, 25, 46, 45, 25, 46, 45, 25}, --frameIDs
                    12,                                   --framesPerSecond
                    MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
        self.mario:give('frozen_component')
        self.mario:give('callback_component', 
        function(mario) 
            self.mario.player.playerState = PLAYER_STATE.SUPER_MARIO
            self.mario:remove('frozen_component')
        end, 45)
    elseif growType == GROW_TYPE.FIRE_FLOWER then
        if not self:isSuperMario() then
            self:grow(GROW_TYPE.MUSHROOM)
            return
        end

        local addScore = Concord.entity(world)
        addScore:give('add_score_component', 1000)

        local floatingText = Concord.entity(world)
        floatingText:give('create_floating_text_component', self.mario, '1000')

        local powerUpSound = Concord.entity(world)
        powerUpSound:give('sound_component', SOUND_ID.POWER_UP_COLLECT)

        if self:isFireMario() then
            return
        end

        self.mario:give('animation_component', 
        {350, 351, 352, 353, 350, 351, 352, 353, 350, 351, 352, 353}, --frameIDs
        12,                                   --framesPerSecond
        MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
        self.mario:give('frozen_component')
        self.mario:give('callback_component', 
        function(entity) 
            self.mario.player.playerState = PLAYER_STATE.FIRE_MARIO
            self.mario:remove('frozen_component')
        end, 60)
    end
end

function PlayerSystem:createBlockDebris(block)
    local world = self:getWorld()
    local blockPosition = block.position
    local texture = block.texture

    local debris1 = Concord.entity(world)
    debris1:give('position', {x = blockPosition:getLeft(), y = blockPosition:getTop() - SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    debris1:give('gravity_component')
    debris1:give('moving_component', {x = -8.0, y = -2.0}, {x = 0, y = 0})
    debris1:give('texture', BLOCK_TILESHEET_IMG, true)
    debris1:give('spritesheet', debris1.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
        ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, block.destructible_component.debrisCoordinates)
    debris1:give('particle')
    debris1:give('destroy_outside_camera_component')
    --Top Right
    local debris2 = Concord.entity(world)
    debris2:give('position', {x = blockPosition:getLeft(), y = blockPosition:getTop() - SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    debris2:give('gravity_component')
    debris2:give('moving_component', {x = 8.0, y = -2.0}, {x = 0, y = 0})
    debris2:give('texture', BLOCK_TILESHEET_IMG, true)
    debris2:give('spritesheet', debris2.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
        ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, block.destructible_component.debrisCoordinates)
    debris2:give('particle')
    debris2:give('destroy_outside_camera_component')
    --Bottom Left
    local debris3 = Concord.entity(world)
    debris3:give('position', {x = blockPosition:getLeft(), y = blockPosition:getTop()}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    debris3:give('gravity_component')
    debris3:give('moving_component', {x = -8.0, y = -2.0}, {x = 0, y = 0})
    debris3:give('texture', BLOCK_TILESHEET_IMG, true)
    debris3:give('spritesheet', debris3.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
        ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, block.destructible_component.debrisCoordinates)
    debris3:give('particle')
    debris3:give('destroy_outside_camera_component')
    --Bottom Right
    local debris4 = Concord.entity(world)
    debris4:give('position', {x = blockPosition:getLeft(), y = blockPosition:getTop()}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    debris4:give('gravity_component')
    debris4:give('moving_component', {x = 8.0, y = -2.0}, {x = 0, y = 0})
    debris4:give('texture', BLOCK_TILESHEET_IMG, true)
    debris4:give('spritesheet', debris4.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
        ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, block.destructible_component.debrisCoordinates)
    debris4:give('particle')
    debris4:give('destroy_outside_camera_component')
end

function PlayerSystem:reset()
    local startCoordinates = self.scene:getLevelData().playerStart
    local position = self.mario.position
    local move = self.mario.moving_component
    position.position.x = startCoordinates.x * SCALED_CUBE_SIZE
    position.position.y = (position.scale.y == SCALED_CUBE_SIZE * 2) and (startCoordinates.y - 1) * SCALED_CUBE_SIZE or startCoordinates.y * SCALED_CUBE_SIZE

    CameraInstance:setCameraX(self.scene:getLevelData().cameraStart.x * SCALED_CUBE_SIZE)
    CameraInstance:setCameraY(self.scene:getLevelData().cameraStart.y * SCALED_CUBE_SIZE)

    move.velocity.x = 0
    move.velocity.y = 0
    move.acceleration.x = 0
    move.acceleration.y = 0

    self.mario.texture:setVisible(true)
    self.mario.texture:setHorizontalFlipped(false)
    self.mario:remove('frozen_component')
    if self.scene:getLevelData().levelType ~= LEVEL_TYPE.START_UNDERGROUND then
        self.mario:give('gravity_component')
        self.mario:remove('friction_exempt_component')
        self.mario:remove('collision_exempt_component')
        CameraInstance:setCameraFrozen(false)
        PlayerSystem:enableInput(true)
    else
        CameraInstance:setCameraFrozen(true)
        PlayerSystem:setGameStart(true)
        PlayerSystem:enableInput(false)

        self.mario:give('friction_exempt_component')
        self.mario:give('collision_exempt_component')

        self.mario:remove('gravity_component')
        move.velocity.x = 1.6
    end

    self.currentState = ANIMATION_STATE.STANDING
end

function PlayerSystem:checkTrampolineCollisions()
    local world = self:getWorld()
    local position = self.mario.position
    local move = self.mario.moving_component

    processEntitiesWithComponents(world, {'trampoline_component'}, 
        function(entity) 
            local trampoline = entity.trampoline_component
            local trampolinePosition = entity.position
            local trampolineTexture = entity.spritesheet

            local bottomEntity = trampoline.bottomEntity
            local bottomTexture = bottomEntity.spritesheet

            if not AABBCollision(position, trampolinePosition) or not CameraInstance:inCameraRange(trampolinePosition) then
                trampoline.currentSequenceIndex = 0
                self.trampolineCollided = false
                return
            end

            if trampoline.currentSequenceIndex > 20 then
                return
            end

            self.trampolineCollided = true
            entity:remove('tile_component')

            if trampoline.currentSequenceIndex == 0 then --Currently extended, set to half retracted
                trampolineTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.topMediumRetractedID))
                bottomTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.bottomMediumRetractedID))
                trampolinePosition.hitbox = {x = 0, y = 16, w = SCALED_CUBE_SIZE, h = 16}
            elseif trampoline.currentSequenceIndex == 1 then --Currently half retracted, set to retracted
                trampolineTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.topRetractedID))
                bottomTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.bottomRetractedID))
                trampolinePosition.hitbox = {x = 0, y = 32, w = SCALED_CUBE_SIZE, h = 0}
            elseif trampoline.currentSequenceIndex == 2 then --Currently retracted, set to half retracted and launch the player
                trampolineTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.topMediumRetractedID))
                bottomTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.bottomMediumRetractedID))
                trampolinePosition.hitbox = {x = 0, y = 16, w = SCALED_CUBE_SIZE, h = 16}
                move.velocity.y = -11.0
            elseif trampoline.currentSequenceIndex == 3 then --Currently half retracted, set to extended
                trampolineTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.topExtendedID))
                bottomTexture:setSpritesheetCoordinates(MapInstance:getBlockCoord(trampoline.bottomExtendedID))
                trampolinePosition.hitbox = {x = 0, y = 0, w = SCALED_CUBE_SIZE, h = SCALED_CUBE_SIZE}
                move.velocity.y = -11.0
            end

            trampoline.currentSequenceIndex = trampoline.currentSequenceIndex + 1
            if position:getCenterY() > trampolinePosition:getBottom() then
                position:setCenterY(trampolinePosition:getBottom())
            end
        end
    )
end

function PlayerSystem:updateGroundVelocity()
    local world = self:getWorld()

    local texture = self.mario.texture
    local move    = self.mario.moving_component

    --The textures only get flipped if the player is on the ground
    if self.left > 0 then
        texture:setHorizontalFlipped(true)
    elseif self.right > 0 then
        texture:setHorizontalFlipped(false)
    end

    -- Updates the acceleration
    move.acceleration.x = self.xDir * MARIO_ACCELERATION_X

    if self.running > 0 then
        -- a weird number that will max the velocity at 5
        move.acceleration.x = move.acceleration.x * 1.3297872340425531914
    else
        -- a weird number that will max the velocity to 3
        move.acceleration.x = move.acceleration.x * 0.7978723404255319148936
    end

    if self.jump > 0 and self.jumpHeld > 0 and not self.trampolineCollided then
        self.jumpHeld = 1
        move.velocity.y = -7.3
        local jumpSound = Concord.entity(world)
        jumpSound:give('sound_component', SOUND_ID.JUMP)
    end

    if self.duck > 0 and (self:isSuperMario() or self:isFireMario()) then
        self.currentState = ANIMATION_STATE.DUCKING
        move.acceleration.x = 0
        -- Slows the player down
        if move.velocity.x > 1.5 then
            move.velocity.x = move.velocity.x - 0.5
        elseif move.velocity.x < -1.5 then
            move.velocity.x = move.velocity.x + 0.5 
        end
    elseif math.abs(move.velocity.x) > 0.2 or math.abs(move.acceleration.x) > 0.2 then
        -- If the player should be drifting
        if (move.velocity.x > 0 and move.acceleration.x < 0) or (move.velocity.x < 0 and move.acceleration.x > 0) then
            self.currentState = ANIMATION_STATE.DRIFTING
        else
            self.currentState = ANIMATION_STATE.WALKING
        end
    else
        self.currentState = ANIMATION_STATE.STANDING
    end
end

function PlayerSystem:updateAirVelocity()
    local move = self.mario.moving_component
    move.acceleration.x = self.xDir * MARIO_ACCELERATION_X
    if self.running > 0 then
        if (move.acceleration.x >= 0 and move.velocity.x >= 0) or (move.acceleration.x <= 0 and move.velocity.x <= 0) then
            move.acceleration.x = move.acceleration.x * 1.5957446808510638297
        else
            move.acceleration.x = move.acceleration.x * 0.35
        end
    end

    --- Changes mario's acceleration while in the air (the longer you jump the higher mario will go
    if self.jumpHeld > 0 and move.velocity.y < -1.0 then
        if self.running > 0 and math.abs(move.velocity.x) > 3.5 then
            move.acceleration.y = -0.414
        else
            move.acceleration.y = -0.412
        end
    else
        move.acceleration.y = 0
    end
    
    if self.duck > 0 and (self:isSuperMario() or self:isFireMario()) then
        self.currentState = ANIMATION_STATE.DUCKING
    else
        self.currentState = ANIMATION_STATE.JUMPING
    end
end

function PlayerSystem:updateWaterVelocity()
    local world = self:getWorld()
    local move = self.mario.moving_component
    local texture = self.mario.texture

    if self.mario:has('friction_exempt_component') then
        self.mario:give('friction_exempt_component')
    end

    if not self.mario:has('bottom_collision_component') and not self.mario:has('wait_until_component') then
        self.currentState = ANIMATION_STATE.SWIMMING
    elseif self.mario:has('bottom_collision_component') then
        if math.abs(move.velocity.x) >= 0.1 then
            self.currentState = ANIMATION_STATE.SWIMMING_WALK
        else
            self.currentState = ANIMATION_STATE.STANDING
        end 
    end

    if self.currentState == ANIMATION_STATE.SWIMMING or self.currentState == ANIMATION_STATE.SWIMMING_JUMP then
        if self.left > 0 then
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, -3.0)
            texture:setHorizontalFlipped(true)
        elseif self.right > 0 then
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, 3.0)
            texture:setHorizontalFlipped(false)
        else
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, 0.0)
        end
    else
        if self.left > 0 then
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, -1.0)
            texture:setHorizontalFlipped(true)
        elseif self.right > 0 then
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, 1.0)
            texture:setHorizontalFlipped(false)
        else
            move.velocity.x = move.velocity.x + self.underwaterControllerX:calculateWithSetpoint(move.velocity.x, 0.0)
        end
    end

    move.acceleration.y = -0.5

    if move.velocity.y > MAX_UNDERWATER_Y then
        move.velocity.y = MAX_UNDERWATER_Y
    end

    if self.jump > 0 and self.jumpHeld > 0 then
        move.velocity.y = -3.5
        self.jumpHeld = 1

        local jumpSound = Concord.entity(world)
        jumpSound:give('sound_component', SOUND_ID.STOMP)

        self.currentState = ANIMATION_STATE.SWIMMING_JUMP
        self.mario:give('wait_until_component', function(entity) return not entity:has('animation_component') end,
                                                function(entity) 
                                                    self.currentState = ANIMATION_STATE.SWIMMING
                                                    entity:remove('wait_until_component')
                                                end)
    end
end

function PlayerSystem:updateCamera()
    local position = self.mario.position
    local move = self.mario.moving_component

    if not CameraInstance:isFrozen() then
        if position.position.x + 16 > CameraInstance:getCameraCenterX() and move.velocity.x > 0.0 then
            CameraInstance:increaseCameraX(move.velocity.x)
        end

        if position.position.x <= CameraInstance:getCameraLeft() then
            position.position.x = CameraInstance:getCameraLeft()
        end

        if position:getRight() >= CameraInstance:getCameraMaxX() then
            position:setRight(CameraInstance:getCameraMaxX())
        end

        if CameraInstance:getCameraRight() >= CameraInstance:getCameraMaxX() then
            CameraInstance:setCameraRight(CameraInstance:getCameraMaxX())
        end

        CameraInstance:updateCameraMin()

        if #self.scene:getLevelData().teleportPoints == 0 then
            return
        end

        for teleportPoint in ipairs(self.scene:getLevelData().teleportPoints) do
            if math.abs(position.position.x - (teleportPoint.x * SCALED_CUBE_SIZE)) < 2.5 then
                local cameraDifference = (teleportPoint.y - teleportPoint.x) * SCALED_CUBE_SIZE
                position.position.x = teleportPoint.y * SCALED_CUBE_SIZE
                CameraInstance:increaseCameraX(cameraDifference)
                CameraInstance:updateCameraMin()
            end
        end
    end
end

function PlayerSystem:update()
    if not self:isEnabled() then
        return
    end

    self:handleInput()

    local world = self:getWorld()
    local position = self.mario.position
    local move = self.mario.moving_component

    if FlagSystem:isClimbing() then
        self.currentState = ANIMATION_STATE.SLIDING
        self:setState(self.currentState)
        self:updateCamera()
        return
    end

    if WarpSystem:isWarping() then
        if move.velocity.x ~= 0 then
            self.currentState = ANIMATION_STATE.WALKING
        end
        if move.velocity.x == 0 or move.velocity.y ~= 0 then
            self.currentState = ANIMATION_STATE.STANDING
        end
        self:setState(self.currentState)
        self:updateCamera()
        return
    end

    if WarpSystem:isClimbing() then
        if move.velocity.y ~= 0 then
            self.currentState = ANIMATION_STATE.CLIMBING
        else
            self.currentState = ANIMATION_STATE.SLIDING
        end
        self:setState(self.currentState)
        self:updateCamera()
        return
    end

    if not PlayerSystem.isInputEnabled() then
        if self.scene:getLevelData().levelType == LEVEL_TYPE.START_UNDERGROUND and PlayerSystem:isGameStart() then
            move.velocity.x = 1.6
        end

        if move.velocity.x ~= 0 and move.velocity.y == 0 then
            self.currentState = ANIMATION_STATE.WALKING
        elseif move.velocity.y ~= 0 then
            self.currentState = ANIMATION_STATE.JUMPING
        else
            self.currentState = ANIMATION_STATE.STANDING
        end

        self:setState(self.currentState)
        self:updateCamera()
        return
    end

    if self.currentState ~= ANIMATION_STATE.GAMEOVER then 
        self:checkGameTime()
    end

    if self.currentState ~= ANIMATION_STATE.GAMEOVER then  -- If the player isn't dead
        if self.underwater then
            self:updateWaterVelocity()
        elseif self.mario:has('bottom_collision_component') then
            self:updateGroundVelocity()
        else
            self:updateAirVelocity()
        end
    else
        self:setState(ANIMATION_STATE.GAMEOVER)
        return
    end

    -- Hold the launching texture
    if self.holdFireballTexture > 0 then
        self.currentState = ANIMATION_STATE.LAUNCH_FIREBALL
    end

    if position.position.y >= CameraInstance:getCameraY() + SCREEN_HEIGHT + SCALED_CUBE_SIZE and not self.mario:has('frozen_component') and not WarpSystem:hasClimbed() then
        self:onGameOver(true)
        return 
    end

    local platformMoved = false

    --Move mario with the platforms
    processEntitiesWithComponents(world, {'moving_platform_component', 'moving_component'}, 
    function(entity)
        if not AABBCollision(position, entity.position) or platformMoved then
            return
        end

        local platformMove = entity.moving_component
        position.position.x = position.position.x + platformMove.velocity.x
        position.position.y = position.position.y + platformMove.velocity.y

        if position.position.x + 16 > CameraInstance:getCameraCenterX() and platformMove.velocity.x > 0 then
            CameraInstance:increaseCameraX(platformMove.velocity.x)
        end

        platformMoved = true
    end)

    self:checkTrampolineCollisions()

    -- Launch fireballs
    if self:isFireMario() and self.launchFireball > 0 then
        self:createFireball()
        self.launchFireball = 0
        local fireballSound = Concord.entity(world)
        fireballSound:give('sound_component', SOUND_ID.FIREBALL)
    end

    -- Enemy collision
    self:checkEnemyCollisions()

    -- Projectile Collision
    local projectiles = world:getSystem(ProjectileSystem):getEntities()
    for _, projectile in ipairs(projectiles) do
        local projectilePosition = projectile.position
        if projectile:has('position') then
            if (not CameraInstance:inCameraRange(projectilePosition)) or (not AABBTotalCollision(position, projectilePosition) or self:isSuperStar() or (self.mario:has('ending_blink_component') or self.mario:has('frozen_component') or self.mario:has('particle'))) then
            else
                if projectile.projectile.type ~= PROJECTTILE_TYPE.FIREBALL then
                    self:onGameOver(false)
                end
            end
        end
    end

    -- Break blocks
    processEntitiesWithComponents(world, {'bumpable_component', 'position', 'bottom_collision_component'}, 
    function(breakable)
        if move.velocity.y > 0 or not AABBCollision(breakable.position, position) or position.position.y < breakable.position.position.y then
            return
        end

        -- Destroy the block if the player is Super Mario
        if not self:isSmallMario() then
            if not breakable:has('mystery_box_component') and breakable:has('destructible_component') and AABBCollision(breakable.position, position) then
                -- This allows the enemy system to that the enemy should be destroyed, otherwise
                -- the enemy will fall as normal
                breakable:give('block_bump_component')
                breakable:give('callback_component', 
                function(breakable) 
                    self:createBlockDebris(breakable)
                    world:removeEntity(breakable)
                    local breakSound = Concord.entity(world)
                    breakSound:give('sound_component', SOUND_ID.BLOCK_BREAK)
                end, 1)
                return
            end
        end

        -- If the player is in normal state, make the block bump
        if not breakable:has('block_bump_component') then
            breakable:give('block_bump_component', {-3, -3, -2, -1, 1, 2, 3, 3})
            local bumpSound = Concord.entity(world)
            bumpSound:give('sound_component', SOUND_ID.BLOCK_HIT)
        end

        breakable:remove('bottom_collision_component')
        if breakable:has('mystery_box_component') then
            local mysteryBox = breakable.mystery_box_component
            if breakable:has('invisible_block_component') then
                breakable:remove('invisible_block_component')
                move.velocity.y = 0
                move.acceleration.y = 0
            end

            mysteryBox.whenDispensed(breakable)
            breakable:remove('animation_component')
            breakable.spritesheet:setSpritesheetCoordinates(mysteryBox.deactivatedCoordinates)
            breakable:remove('bumpable_component')
        end
    end)

    local collectibles = world:getSystem(CollectibleSystem):getEntities()
    for _, collectible in ipairs(collectibles) do
        if collectible:has('position') then
            if (not CameraInstance:inCameraRange(collectible.position)) or (not AABBTotalCollision(collectible.position, position)) then
            else
                local collect = collectible.collectible
                local type = collect.collectibleType
                if type == COLLECTIBLE_TYPE.MUSHROOM or type == COLLECTIBLE_TYPE.SUPER_STAR or type == COLLECTIBLE_TYPE.FIRE_FLOWER then
                    self:grow(type)
                    world:removeEntity(collectible)
                elseif type == COLLECTIBLE_TYPE.COIN then
                    local coinScore = Concord.entity(world)
                    coinScore:give('add_score_component', 100, true)
                    local coinSound = Concord.entity(world)
                    coinSound:give('sound_component', SOUND_ID.COIN)
                    self:grow(type)
                    world:removeEntity(collectible)
                elseif type == COLLECTIBLE_TYPE.ONE_UP then
                    local coinSound = Concord.entity(world)
                    coinSound:give('sound_component', SOUND_ID.COIN)
                    self:grow(type)
                    world:removeEntity(collectible)
                end
            end
        end
    end

    self:updateCamera()
    -- Updates the textures for whichever state the player is currently in
    self:setState(self.currentState)

    -- This resets the collision/jumping states to avoid conflicts during the next game tick
    if self.mario:has('top_collision_component') then
        self.mario:remove('top_collision_component')
    end

    if self.mario:has('right_collision_component') then
        self.mario:remove('right_collision_component')
    end

    if self.mario:has('bottom_collision_component') then
        self.mario:remove('bottom_collision_component')
    end

    if self.mario:has('left_collision_component') then
        self.mario:remove('left_collision_component')
    end
end

function PlayerSystem:checkEnemyCollisions()
    local world = self:getWorld()
    local position = self.mario.position
    local move = self.mario.moving_component
    local enemyCrushed = false

    processEntitiesWithComponents(world, {'enemy', 'position'}, 
        function(enemy)
            if not AABBTotalCollision(enemy.position, position) or self.mario:has('frozen_component') or enemy:has('dead_component') or self.currentState == ANIMATION_STATE.GAMEOVER then
                return
            end

            local enemyMove = enemy.moving_component
            local enemyPosition = enemy.position
            local enemyType = enemy.enemy.type 

            if enemy.enemy.type == ENEMY_TYPE.KOOPA_SHELL then
                if self:isSuperStar() then
                    enemyMove.velocity.x = 0
                    enemy:give('enemy_destroyed_component')
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                end

                if move.velocity.y > 0.0 then
                    if enemyMove.velocity.x ~= 0 then
                        enemyMove.velocity.x = 0
                        move.velocity.y = -ENEMY_BOUNCE
                        enemyCrushed = true
                    else
                        enemyMove.velocity.x = 6.0
                    end
                -- Hit from left side
                elseif position:getLeft() <= enemyPosition:getLeft() and position:getRight() < enemyPosition:getRight() and move.velocity.y <= 0.0 then
                    enemyMove.velocity.x = 6.0
                elseif position:getLeft() > enemyPosition:getLeft() and position:getRight() > enemyPosition:getRight() then
                    enemyMove.velocity.x = -6.0
                end
            elseif enemy.enemy.type == ENEMY_TYPE.FIRE_BAR then
                if not self:isSuperStar() and not self.mario:has('ending_blink_component') then
                    self:onGameOver(false)
                end
            elseif enemy.enemy.type == ENEMY_TYPE.KOOPA_PARATROOPA then
                if self:isSuperStar() then
                    enemyMove.velocity.x = 0;
                    enemy:give('enemy_destroyed_component')
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                    return;
                end
                
                if move.velocity.y > 0 and enemy:has('crushable_component') then
                    enemy:give('crushed_component')
                    position:setBottom(enemyPosition:getTop())
                    move.velocity.y = -MARIO_BOUNCE
                    enemyCrushed = true

                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                elseif not enemyCrushed and move.velocity.x <= 0 and not (self.mario:has('frozen_component') or self.mario:has('ending_blink_component')) then
                    self:onGameOver(false)
                elseif enemyCrushed then
                    enemy:give('crushed_component')
                    enemyMove.velocity.x = 0
                    move.velocity.y = -MARIO_BOUNCE

                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                end
            elseif enemy.enemy.type == ENEMY_TYPE.CHEEP_CHEEP then
                if self:isSuperStar() then
                    enemyMove.velocity.x = 0
                    enemy:give('enemy_destroyed_component')
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                    return
                end

                if (move.velocity.y > 0) or (move.velocity.y == 0 and enemyMove.velocity.y < 0) and enemy:has('crushable_component') then
                    enemy:give('crushed_component')
                    enemyMove.velocity.x = 0
                    move.velocity.y = -MARIO_BOUNCE
                    enemyCrushed = true
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                elseif not enemyCrushed and move.velocity.y <= 0 and not (self.mario:has('frozen_component') or self.mario:has('ending_blink_component') ) then
                    self:onGameOver(false)
                elseif enemyCrushed then
                    enemy:give('crushed_component')
                    enemyMove.velocity.x = 0
                    move.velocity.y = -MARIO_BOUNCE

                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)   
                else
                    if self:isSuperStar() then
                        enemyMove.velocity.x = 0
                        enemy:give('enemy_destroyed_component')
                        local score = Concord.entity(world)
                        score:give('add_score_component', 100)  
                        return
                    end

                    if move.velocity.y > 0 and enemy:has('crsuhable_component') then
                        enemy:give('crushed_component')
                        enemyMove.velocity.x = 0
                        move.velocity.y = -MARIO_BOUNCE
                        enemyCrushed = true
                        local score = Concord.entity(world)
                        score:give('add_score_component', 100)
                    elseif not enemyCrushed and move.velocity.y <= 0 and not (self.mario:has('frozen_component') and self.mario:has('ending_blink_component')) then
                        self:onGameOver(false)
                    elseif enemyCrushed then
                        enemy:give('crushed_component')
                        enemyMove.velocity.x = 0
                        move.velocity.y = -MARIO_BOUNCE
                        local score = Concord.entity(world)
                        score:give('add_score_component', 100)
                    end
                end
            else
                if self:isSuperStar() then
                    enemy.moving_component.velocity.x = 0
                    enemy:give('enemy_destroyed_component')
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                    return
                end
                if move.velocity.y > 0 and enemy:has('crushable_component') then
                    enemy:give('crushed_component')
                    enemy.moving_component.velocity.x = 0
                    move.velocity.y = -MARIO_BOUNCE
                    enemyCrushed = true
                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                elseif not enemyCrushed and move.velocity.y <= 0 and not (self.mario:has('frozen_component') and self.mario:has('ending_blink_component')) then
                    self:onGameOver()
                elseif enemyCrushed then
                    enemy:give('crushed_component')
                    enemy.moving_component.velocity.x = 0
                    move.velocity.y = -MARIO_BOUNCE

                    local score = Concord.entity(world)
                    score:give('add_score_component', 100)
                end
            end
        end)
end

function PlayerSystem:createFireball()
    local world = self:getWorld()
    self.holdFireballTexture = 1
    self.currentState = ANIMATION_STATE.LAUNCH_FIREBALL

    local tempCallback = Concord.entity(world)
    tempCallback:give('callback_component', function(entity) 
        self.holdFireballTexture = 0
        world:removeEntity(entity)
    end, 6)
 
    local fireball = Concord.entity(world)
    fireball:give('position', {x = 0, y = 0}, {x = SCALED_CUBE_SIZE / 2, y = SCALED_CUBE_SIZE / 2}, {x = 0, y = 0, w = 16, h = 16})
    local position = fireball.position
    fireball:give('texture', PLAYER_TILESHEET_IMG, false, false)
    fireball:give('spritesheet', fireball.texture, ORIGINAL_CUBE_SIZE / 2, ORIGINAL_CUBE_SIZE / 2, 1,
                                 9, 0, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, MapInstance:getPlayerCoord(246))

    fireball:give('moving_component', {x = 0, y = 5}, {x = 0, y = 0})
    local move = fireball.moving_component

    fireball:give('friction_exempt_component')
    fireball:give('gravity_component')
    fireball:give('destroy_outside_camera_component')
    local marioTexture = self.mario.texture
 
    if marioTexture:isHorizontalFlipped() then
        position:setRight(self.mario.position:getLeft())
        move.velocity.x = -PROJECTILE_SPEED
    else
        position:setLeft(self.mario.position:getRight())
        move.velocity.x = PROJECTILE_SPEED
    end
 
    position:setTop(self.mario.position:getTop() + 4)   
    fireball:give('wait_until_component', 
    function(entity) 
        return (entity:has('left_collision_component') or entity:has('right_collision_component') or not CameraInstance:inCameraRange(entity.position))
    end,
    function(entity) 
        entity:remove('wait_until_component')
        if entity:has('left_collision_component') or entity:has('right_collision_component') then
            entity.spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(247))
            entity:give('destroy_delayed_component', 4)
            entity:remove('moving_component'):remove('gravity_component'):remove('friction_exempt_component')

            local fireballHitSound = Concord.entity(world)
            fireballHitSound:give('sound_component', SOUND_ID.BLOCK_HIT)
        else
            world:removeEntity(entity)
        end
    end
    )
 
    fireball:give('projectile', PROJECTTILE_TYPE.FIREBALL)
 
    return fireball
end

function PlayerSystem:setState( newState) 
    local spritesheet = self.mario.spritesheet
    local position = self.mario.position

    if self.mario:has('frozen_component') then
        return
    end

    if newState == ANIMATION_STATE.STANDING then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end

        if self:isFireMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(225))
        elseif self:isSuperMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(25))
        else
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(0))
        end

    elseif newState == ANIMATION_STATE.WALKING then
        local fireFrameIDS = {227, 228, 229}
        local superFrameIDS = {27, 28, 29}
        local normalFrameIDS = {2, 3, 4}
        if not self.mario:has('animation_component') then
            if self:isFireMario() then
                self.mario:give('animation_component', 
                fireFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            elseif self:isSuperMario() then
                self.mario:give('animation_component', 
                superFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            else
                self.mario:give('animation_component', 
                normalFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            end
            return
        end

        if self.mario.animation_component.frameIDs ~= superFrameIDS and self.mario.animation_component.frameIDs ~= normalFrameIDS and self.mario.animation_component.frameIDs ~= fireFrameIDS then
            -- If the player already has an animation but it is not the correct one
            local animation = self.mario.animation_component
            if self:isFireMario() then
                animation.frameIDs = fireFrameIDS
                animation.frameCount = 3
            elseif self:isSuperMario() then
                animation.frameIDs = superFrameIDS
                animation.frameCount = 3
            else
                animation.frameIDs = normalFrameIDS
                animation.frameCount = 3
            end
        end

        if self.running > 0 then
            self.mario.animation_component:setFramesPerSecond(12)
        else
            self.mario.animation_component:setFramesPerSecond(8)
        end
    elseif newState == ANIMATION_STATE.SWIMMING then
        local fireFrameIDS = {232, 233}
        local superFrameIDS = {32, 33}
        local normalFrameIDS = {7, 8}
        if not self.mario:has('animation_component') then
            if self:isFireMario() then
                self.mario:give('animation_component', 
                fireFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            elseif self:isSuperMario() then
                self.mario:give('animation_component', 
                superFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            else
                self.mario:give('animation_component', 
                normalFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            end
        end

        if self.mario.animation_component.frameIDs ~= superFrameIDS and self.mario.animation_component.frameIDs ~= normalFrameIDS and self.mario.animation_component.frameIDs ~= fireFrameIDS then
            -- If the player already has an animation but it is not the correct one
            local animation = self.mario.animation_component
            if self:isFireMario() then
                animation.frameIDs = fireFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(16)
            elseif self:isSuperMario() then
                animation.frameIDs = superFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(16)
            else
                animation.frameIDs = normalFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(16)
            end
        end
    elseif newState == ANIMATION_STATE.SWIMMING_JUMP then
        local fireFrameIDS = {232, 233, 234, 235, 236, 237}
        local superFrameIDS = {32, 33, 34, 35, 36, 37}
        local normalFrameIDS = {7, 8, 9, 10, 11}
        if not self.mario:has('animation_component') then
            if self:isFireMario() then
                self.mario:give('animation_component', 
                fireFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
            elseif self:isSuperMario() then
                self.mario:give('animation_component', 
                superFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
            else
                self.mario:give('animation_component', 
                normalFrameIDS,                --frameIDs
                16,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
            end
        end

        if self.mario.animation_component.frameIDs ~= superFrameIDS and self.mario.animation_component.frameIDs ~= normalFrameIDS and self.mario.animation_component.frameIDs ~= fireFrameIDS then
            -- If the player already has an animation but it is not the correct one
            local animation = self.mario.animation_component
            if self:isFireMario() then
                animation.frameIDs = fireFrameIDS
                animation.frameCount = 6
                animation.repeated = false
                animation:setFramesPerSecond(16)
            elseif self:isSuperMario() then
                animation.frameIDs = superFrameIDS
                animation.frameCount = 6
                animation.repeated = false
                animation:setFramesPerSecond(16)
            else
                animation.frameIDs = normalFrameIDS
                animation.frameCount = 6
                animation.repeated = false
                animation:setFramesPerSecond(16)
            end
        end
    elseif newState == ANIMATION_STATE.SWIMMING_WALK then
        local fireFrameIDS = {227, 228, 229}
        local superFrameIDS = {27, 28, 29}
        local normalFrameIDS = {2, 3, 4}
        if not self.mario:has('animation_component') then
            if self:isFireMario() then
                self.mario:give('animation_component', 
                fireFrameIDS,                --frameIDs
                4,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            elseif self:isSuperMario() then
                self.mario:give('animation_component', 
                superFrameIDS,                --frameIDs
                4,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            else
                self.mario:give('animation_component', 
                normalFrameIDS,                --frameIDs
                4,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            end
            return
        end

        if self.mario.animation_component.frameIDs ~= superFrameIDS and self.mario.animation_component.frameIDs ~= normalFrameIDS and self.mario.animation_component.frameIDs ~= fireFrameIDS then
            -- If the player already has an animation but it is not the correct one
            local animation = self.mario.animation_component
            if self:isFireMario() then
                animation.frameIDs = fireFrameIDS
                animation.frameCount = 3
                animation:setFramesPerSecond(4)
            elseif self:isSuperMario() then
                animation.frameIDs = superFrameIDS
                animation.frameCount = 3
                animation:setFramesPerSecond(4)
            else
                animation.frameIDs = normalFrameIDS
                animation.frameCount = 3
                animation:setFramesPerSecond(4)
            end
        end
    elseif newState == ANIMATION_STATE.DRIFTING then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end
        if self:isFireMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(230))
        elseif self:isSuperMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(30))
        else
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(5))
        end
    elseif newState == ANIMATION_STATE.JUMPING then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end
        if self:isFireMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(231))
        elseif self:isSuperMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(31))
        else
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(6))
        end
    elseif newState == ANIMATION_STATE.DUCKING then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end

        if self:isFireMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(226))
        elseif self:isSuperMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(26))
        end
    elseif newState == ANIMATION_STATE.LAUNCH_FIREBALL then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end

        if self.mario:has('bottom_collision_component') then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(240))
        else
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(243))
        end
    elseif newState == ANIMATION_STATE.CLIMBING then
        local fireFrameIDS = {238, 239}
        local superFrameIDS = {38, 39}
        local normalFrameIDS = {13, 14}
        if not self.mario:has('animation_component') then
            if self:isFireMario() then
                self.mario:give('animation_component', 
                fireFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            elseif self:isSuperMario() then
                self.mario:give('animation_component', 
                superFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            else
                self.mario:give('animation_component', 
                normalFrameIDS,                --frameIDs
                8,                                   --framesPerSecond
                MapInstance.PlayerIDCoordinates)      --coordinateSupplier
            end
        end

        if self.mario.animation_component.frameIDs ~= superFrameIDS and self.mario.animation_component.frameIDs ~= normalFrameIDS and self.mario.animation_component.frameIDs ~= fireFrameIDS then
            -- If the player already has an animation but it is not the correct one
            local animation = self.mario.animation_component
            if self:isFireMario() then
                animation.frameIDs = fireFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(8)
            elseif self:isSuperMario() then
                animation.frameIDs = superFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(8)
            else
                animation.frameIDs = normalFrameIDS
                animation.frameCount = 2
                animation:setFramesPerSecond(8)
            end
        end
    elseif newState == ANIMATION_STATE.SLIDING then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end

        if self:isFireMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(238))
        elseif self:isSuperMario() then
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(38))
        else
            spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(13))
        end
    elseif newState == ANIMATION_STATE.GAMEOVER then
        if self.mario:has('animation_component') then
            self.mario:remove('animation_component')
        end
        spritesheet:setSpritesheetCoordinates(MapInstance:getPlayerCoord(1))
    end

    if newState == ANIMATION_STATE.DUCKING then
        position.hitbox.h = 32
        position.hitbox.y = 32
    else
        position.hitbox.h = position.scale.y
        position.hitbox.y = 0
    end
end

function PlayerSystem:checkGameTime()
    if self.scene:getTimeLeft() <= 0 then
        self:onGameOver(true)
    end
end

function PlayerSystem:handleInput()
    if not PlayerSystem:isInputEnabled() then
        self.left = 0
        self.right = 0
        self.running = 0
        self.jump = 0
        self.duck = 0
        self.xDir = 0
        return
    end

    if input:pressed('LEFT') or input:down('LEFT') then
        self.left = 1
    else
        self.left = 0
    end
  
    if input:pressed('RIGHT') or input:down('RIGHT') then
        self.right = 1
    else
        self.right = 0
    end
    self.xDir = self.right - self.left

    if input:pressed('Sprint') or input:down('Sprint') then
        self.running = 1
    else
        self.running = 0
    end
    
    if input:pressed('JUMP') then
        self.jump = 1
    else
        self.jump = 0
    end

    if input:down('JUMP') then
        self.jumpHeld = 1
    else
        self.jumpHeld = 0
    end
    
    if input:pressed('DUCK') or input:down('DUCK') then
        self.duck = 1
    else
        self.duck = 0
    end

    if input:pressed('FIREBALL') then
        self.launchFireball = 1
    else
        self.launchFireball = 0
    end
end

function PlayerSystem:getPlayerState()
    return self.mario.player.playerState
end

function PlayerSystem:setPlayerState(val)
    if val == PLAYER_STATE.SUPER_MARIO then
        self.mario:remove('animation_component')
        local position = self.mario.position
        local spritesheet = self.mario.spritesheet

        position:setTop(position:getTop() - position.scale.y) -- Makes the player taller
        position.scale.y = SCALED_CUBE_SIZE * 2
        position.hitbox.h = SCALED_CUBE_SIZE * 2
        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE * 2)
        self.mario:give('animation_component', 
                    {46, 45, 25, 46, 45, 25, 46, 45, 25},   --frameIDs
                    12,                                     --framesPerSecond
                    MapInstance.PlayerIDCoordinates, false)  --coordinateSupplier
        self.mario.player.playerState = PLAYER_STATE.SUPER_MARIO
    elseif val == PLAYER_STATE.FIRE_MARIO then
        self.mario:remove('animation_component')
        local position = self.mario.position
        local spritesheet = self.mario.spritesheet
        position:setTop(position:getTop() - position.scale.y) -- Makes the player taller
        position.scale.y = SCALED_CUBE_SIZE * 2
        position.hitbox.h = SCALED_CUBE_SIZE * 2
        spritesheet:setEntityHeight(ORIGINAL_CUBE_SIZE * 2)

        self.mario:give('animation_component', 
        {350, 351, 352, 353, 350, 351, 352, 353, 350, 351, 352, 353}, --frameIDs
        12,                                   --framesPerSecond
        MapInstance.PlayerIDCoordinates, false)      --coordinateSupplier
        self.mario.player.playerState = PLAYER_STATE.FIRE_MARIO
    end
end

function PlayerSystem:getMario()
    return self.mario
end