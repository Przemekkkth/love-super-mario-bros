ScoreSystem = Concord.system()

function ScoreSystem:init(world)
    self.world = world
    self.scoreEntity           = Concord.entity(self.world)
    self.coinsEntity           = Concord.entity(self.world)
    self.timerEntity           = Concord.entity(self.world)
    self.worldNumberEntity     = Concord.entity(self.world) 
    self.worldNumberTransition = Concord.entity(self.world)
    self.marioIcon             = Concord.entity(self.world)
    self.livesText             = Concord.entity(self.world)

    self.totalScore = 0;
    self.coins = 0;
    self.time = 400 * MAX_FPS;
    self.gameTime = 400;
    self.scoreCountTime = 0;
    self.lives = 3;
 
    self.timerRunning = false;
 
    self.scene = nil;

    local paddingW = 44
    local paddingH = 16
    local spacingH = 4
    local textHeight = 16
    local availableWidth = SCREEN_WIDTH - paddingW
    local columns = 4
    local columnWidth = availableWidth / columns
 
    self:createMarioText(paddingW, paddingH)
    self:createScoreText(paddingW, paddingH + textHeight + spacingH)
    self:createCoinIcon(paddingW + columnWidth, paddingH + textHeight + spacingH + 2)
    self:createCoinText(paddingW + columnWidth + 18, paddingH + textHeight + spacingH)
    self:createWorldText(paddingW + (2*columnWidth), paddingH)
    self:createWorldNumberText(paddingW + (2*columnWidth), paddingH + textHeight + spacingH)
    self:createTimeText(paddingW + (3*columnWidth), paddingH)
    self:createTimerText(paddingW + (3*columnWidth) + 4, paddingH + textHeight + spacingH)
    self:createWorldNumberTransition(paddingW + (1.5*columnWidth), 10*paddingH + textHeight + spacingH)
    self:createMarioIcon(paddingW + (1.5*columnWidth), 12*paddingH + textHeight + spacingH)
    self:createLivesText(2*paddingW + (1.5*columnWidth), 12*paddingH + textHeight + 3*spacingH)
end

function ScoreSystem:setScene(scene)
    self.scene = scene
    self.worldNumberEntity.text:setText(tostring(self.scene:getLevel())..'-'..tostring(self.scene:getLevel()))
end

function ScoreSystem:createFloatingText(world, originalEntity, text)
    local originalPosition = originalEntity.position
    local scoreText = Concord.entity(world)
    scoreText:give('position', {x = originalPosition:getCenterX(), y = originalPosition:getTop() - 4} )
    scoreText:give('moving_component', {x = 0, y = -1}, {x = 0, y = 0})
    scoreText:give('text', text, 10, true)
    scoreText:give('floating_text')
    scoreText:give('destroy_delayed_component', 35)
    return scoreText
end

function ScoreSystem:update()
    if not self:isEnabled() then
        return
    end
    
    local changeScore = false
    local changeCoin = false
    local changeTime = false
    local world = self:getWorld()
    local filterSystem = world:getSystem(FilterSystem)
    for _, entity in ipairs(filterSystem:getCreateFloatingTextEntities()) do
        local floatingText = entity.create_floating_text_component
        self:createFloatingText(world, floatingText.originalEntity, floatingText.text)
        world:removeEntity(entity)
    end

    for _, entity in ipairs(filterSystem:getAddScoreEntities()) do 
        local score = entity.add_score_component
            if score.score > 0 then
                self.totalScore = self.totalScore + score.score
                changeScore = true
            end

            if score.addCoin then
                self.coins = self.coins + 1
                if self.coins >= 100 then
                    local coinSound = Concord.entity(world)
                    coinSound:give('sound_component', SOUND_ID.ONE_UP)
                    self:increaseLives()
                    self.coins = 0
                end
                changeCoin = true
            end

            world:removeEntity(entity)
    end

    for _, entity in ipairs(filterSystem:getAddLivesEntities()) do
        local livesComponent = entity.add_lives_component
        self.lives = self.lives + 1       
        world:removeEntity(entity)
    end

    if self.timerRunning then
        self.time = self.time - 2
        if self.time % MAX_FPS == 0 then
            self.gameTime = self.gameTime - 1
            changeTime = true
        end
    end
    
    if changeScore then
        local scoreString = tostring(self.totalScore)
        local finalString = ''

        local zerosToAdd = 6 - #scoreString
        local finalString = string.rep('0', zerosToAdd) .. scoreString
        self.scoreEntity.text:setText(finalString)
    end

    if changeCoin then
        local coinString = tostring(self.coins)
        local finalString = ''

        local zerosToAdd = 2 - #coinString
        local finalString = string.rep('0', zerosToAdd) .. coinString
        self.coinsEntity.text:setText('x'..finalString)
    end

    if changeTime then
        local timeString = tostring(self.gameTime)
        local finalString = ''

        local zerosToAdd = 3 - #timeString
        local finalString = string.rep('0', zerosToAdd) .. timeString
        self.timerEntity.text:setText(finalString)
    end
end

function ScoreSystem:createMarioText(x, y)
    local marioText = Concord.entity(self.world)
    marioText:give('position', {x = x, y = y})
    marioText:give('text', 'MARIO', 16)
end

function ScoreSystem:createScoreText(x, y)
    self.scoreEntity:give('position', {x = x, y = y})
    self.scoreEntity:give('text', '000000', 16)
end

function ScoreSystem:createCoinIcon(x, y)
    local coinIcon = Concord.entity(self.world)
    coinIcon:give('position', {x = x, y = y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    coinIcon:give('texture', BLOCK_TILESHEET_IMG, false, false)
    coinIcon:give('spritesheet', coinIcon.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 1, 1,
                                                   ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(754))
    
    coinIcon:give('animation_component', 
                    {754, 755, 756, 757},                --frameIDs
                    8,                                   --framesPerSecond
                    MapInstance.BlockIDCoordinates)      --coordinateSupplier
    coinIcon:give('pause_animation_component', 1, 25)
    coinIcon:give('icon')
end

function ScoreSystem:createCoinText(x, y)
    self.coinsEntity:give('position', {x = x, y = y})
    self.coinsEntity:give('text', 'x00', 16)
end

function ScoreSystem:createWorldText(x, y)
    local worldEntity = Concord.entity(self.world)
    worldEntity:give('position', {x = x, y = y})
    worldEntity:give('text', 'WORLD', 16)
end

function ScoreSystem:createWorldNumberText(x, y)
    self.worldNumberEntity:give('position', {x = x, y = y})
    self.worldNumberEntity:give('text', '0-0', 16)
end

function ScoreSystem:createTimeText(x, y)
    local timeEntity = Concord.entity(self.world)
    timeEntity:give('position', {x = x, y = y})
    timeEntity:give('text', "TIME", 16)
end

function ScoreSystem:createTimerText(x, y, world)
    self.timerEntity:give('position', {x = x, y = y})
    self.timerEntity:give('text', tostring('-'), 16)
end

function ScoreSystem:createWorldNumberTransition(x, y)
    self.worldNumberTransition:give('position', {x = x, y = y})
    self.worldNumberTransition:give('text',  "WORLD1-1", 16)
    self.worldNumberTransition.text:setVisible(false)
end

function ScoreSystem:createMarioIcon(x, y)
    self.marioIcon:give('position', {x = x, y = y}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE})
    self.marioIcon:give('texture', PLAYER_TILESHEET_IMG, false, false)
    self.marioIcon:give('spritesheet', self.marioIcon.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, 1, 9, 0,
                                  ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, MapInstance:getPlayerCoord(0))
    self.marioIcon:give('icon')
    self.marioIcon.texture:setVisible(false)
end

function ScoreSystem:createLivesText(x, y)
    self.livesText:give('position', {x = x, y = y})
    self.livesText:give('text', ' x  '..tostring(self.lives), 16)
    self.livesText.text:setVisible(false)
end

function ScoreSystem:reset()
    self.gameTime = 400
    self.time = 400 * MAX_FPS
    self.timerEntity.text:setText(tostring(self.gameTime))

    self.worldNumberEntity.text:setText(tostring(self.scene:getLevel())..'-'..tostring(self.scene:getSubLevel()))
end

function ScoreSystem:startTimer()
    self.timerRunning = true
end

function ScoreSystem:stopTimer()
    self.timerRunning = false
end

function ScoreSystem:decreaseLives()
    self.lives = self.lives - 1
    self.livesText.text:setText(' x  '..tostring(self.lives))
end

function ScoreSystem:increaseLives()
    self.lives = self.lives + 1
    self.livesText.text:setText(' x  '..tostring(self.lives))
end

function ScoreSystem:scoreCountdown(world)
    if self.gameTime <= 0 then
        self.gameTime = 0
        return
    end

    self.gameTime = self.gameTime - 1
    local timerString = tostring(self.gameTime)
    local finalString = ''

    local zerosToAdd = 3 - #timerString
    finalString = string.rep('0', zerosToAdd) .. timerString
    self.timerEntity.text:setText(finalString)

    local timerTickSound = Concord.entity(world)
    timerTickSound:give('sound_component', SOUND_ID.TIMER_TICK)

    local addScore = Concord.entity(world)
    addScore:give('add_score_component', 100)
end

function ScoreSystem:scoreCountFinished()
    return self.gameTime <= 0
end

function ScoreSystem:getGameTime()
    return self.gameTime
end

function ScoreSystem:getLives()
    return self.lives
end

function ScoreSystem:showTransitionEntities()
    self.worldNumberTransition.text:setText('WORLD '..tostring(self.scene:getLevel())..'-'..tostring(self.scene:getSubLevel()))
    self.worldNumberTransition.text:setVisible(true)
    self.marioIcon.texture:setVisible(true)
    self.livesText.text:setVisible(true)
end

function ScoreSystem:hideTransitionEntities()
    
    self.worldNumberTransition.text:setVisible(false)
    self.marioIcon.texture:setVisible(false)
    self.livesText.text:setVisible(false)
end
