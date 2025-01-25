GameScene = Object:extend()

function GameScene:new(level, subLevel)
    self.paused = false
    self.level = level
    self.subLevel = subLevel
    self.currentMusicID = nil
    self.gameWon = false
    self.pauseSelectedOption = 0  -- 0 is Continue, 1 is Options, 2 is End

    self.foregroundMap = Map()
    self.backgroundMap = Map()
    self.undergroundMap = Map()
    self.enemiesMap = Map()
    self.aboveForegroundMap = Map()
    self.collectiblesMap = Map()

    self.pauseWorld = Concord.world()
    self.pauseWorld:addSystems(RenderSystem)

    self.world = Concord.world()
    self.world:addSystems(RenderSystem, ScoreSystem, AnimationSystem, MapSystem, PlayerSystem, FlagSystem, WarpSystem, PhysicsSystem, CallbackSystem, CollectibleSystem, EnemySystem, SoundSystem)
    self.world:addSystems(BackgroundSystem, ForegroundSystem, AboveForegroundSystem, ProjectileSystem, ParticleSystem)
    self.pauseText = Concord.entity(self.pauseWorld)
    self.pauseText:give('position', {x = 10.8 * SCALED_CUBE_SIZE, y = 4 * SCALED_CUBE_SIZE})
    self.pauseText:give('text', 'PAUSED', 18, false, false)

    self.continueText = Concord.entity(self.pauseWorld)
    self.continueText:give('position', {x = 10.2 * SCALED_CUBE_SIZE, y = 8.5 * SCALED_CUBE_SIZE})
    self.continueText:give('text', 'CONTINUE', 14, false, false)

    self.optionsText = Concord.entity(self.pauseWorld)
    self.optionsText:give('position', {x = 10.2 * SCALED_CUBE_SIZE, y = 9.5 * SCALED_CUBE_SIZE})
    self.optionsText:give('text', 'OPTIONS', 14, false, false)

    self.endText = Concord.entity(self.pauseWorld)
    self.endText:give('position', {x = 10.2 * SCALED_CUBE_SIZE, y = 10.5 * SCALED_CUBE_SIZE})
    self.endText:give('text', 'end', 14, false, false)

    self.selectCursor = Concord.entity(self.pauseWorld)
    self.selectCursor:give('position', {x = 9.5 * SCALED_CUBE_SIZE, y = 10.5 * SCALED_CUBE_SIZE})
    self.selectCursor:give('text', '>', 14, false, false)

    self.is_finished = false

    self:setupLevel()
end

function GameScene:update(dt)
    self:handlePlayerInput()
    self.world:emit('update')

    if self:isFinished() then
        gotoScene('GameOverScene')
    end
end

function GameScene:draw()
    self.world:emit('draw')
    self.pauseWorld:emit('draw')
end

function GameScene:loadLevel(level, subLevel)
    local folderPath = 'assets/data/World'..tostring(level)..'-'..tostring(subLevel)..'/'
    local mapDataPath = folderPath..'World'..tostring(level)..'-'..tostring(subLevel)

    local foregroundPath = mapDataPath..'_Foreground.csv'
    local backgroundPath = mapDataPath..'_Background.csv'
    local undergroundPath = mapDataPath..'_Underground.csv'
    local enemiesPath = mapDataPath..'_Enemies.csv'
    local aboveForegroundPath = mapDataPath..'_Above_Foreground.csv'
    local collectiblesPath = mapDataPath..'_Collectibles.csv'

    local levelPropertiesPath = mapDataPath..'_properties.json'
    local levelData = love.filesystem.read(levelPropertiesPath)
    if levelData then
        self.gameLevel:loadLevelData(levelData)
    else
        error('Not found '..levelPropertiesPath..'.')
    end

    self.foregroundMap:loadMap(foregroundPath)
    self.backgroundMap:loadMap(backgroundPath)
    self.undergroundMap:loadMap(undergroundPath)
    self.enemiesMap:loadMap(enemiesPath)
    self.aboveForegroundMap:loadMap(aboveForegroundPath)
    self.collectiblesMap:loadMap(collectiblesPath)
end

function GameScene:getLevel()
    return self.level
end

function GameScene:getSubLevel()
    return self.subLevel
end

function GameScene:stopTimer()
    self.world:getSystem(ScoreSystem):stopTimer()
end

function GameScene:startTimer()
    self.world:getSystem(ScoreSystem):startTimer()
end

function GameScene:getTimeLeft()
    self.world:getSystem(ScoreSystem):getTimeLeft()
end

function GameScene:scoreCountdown()
    self.world:getSystem(ScoreSystem):scoreCountdown(self.world)
end

function GameScene:scoreCountdownFinished()
    return self.world:getSystem(ScoreSystem):scoreCountFinished()
end

function GameScene:getForegroundMap()
    return self.foregroundMap
end

function GameScene:getBackgroundMap()
    return self.backgroundMap
end

function GameScene:getUndergroundMap()
    return self.undergroundMap
end

function GameScene:getEnemiesMap()
    return self.enemiesMap
end

function GameScene:getAboveForegroundMap()
    return self.aboveForegroundMap
end

function GameScene:getCollectiblesMap()
    return self.collectiblesMap
end

function GameScene:getLevelData()
    return self.gameLevel:getData()
end

function GameScene:getTimeLeft()
    return self.world:getSystem(ScoreSystem):getGameTime()
end

function GameScene:stopMusic()
    stopMusic()
end

function GameScene:pause()
    pauseMusic()
    local pauseSound = Concord.entity(self.world)
    pauseSound:give('sound_component', SOUND_ID.PAUSE)

    self.world:getSystem(PhysicsSystem):setEnabled(false)
    self.world:getSystem(PlayerSystem):setEnabled(false)
    self.world:getSystem(AnimationSystem):setEnabled(false)
    self.world:getSystem(EnemySystem):setEnabled(false)
    self.world:getSystem(CollectibleSystem):setEnabled(false)
    self.world:getSystem(WarpSystem):setEnabled(false)
    self.world:getSystem(FlagSystem):setEnabled(false)
    self.world:getSystem(CallbackSystem):setEnabled(false)
    self.world:getSystem(ScoreSystem):setEnabled(false)

    self.pauseText.text:setVisible(true)
    self.continueText.text:setVisible(true)
    self.optionsText.text:setVisible(true)
    self.endText.text:setVisible(true)
    self.selectCursor.text:setVisible(true)

    self.world:getSystem(ScoreSystem):showTransitionEntities()
end

function GameScene:unpause()
    resumeMusic(self.currentMusicID)

    self.world:getSystem(PhysicsSystem):setEnabled(true)
    self.world:getSystem(PlayerSystem):setEnabled(true)
    self.world:getSystem(AnimationSystem):setEnabled(true)
    self.world:getSystem(EnemySystem):setEnabled(true)
    self.world:getSystem(CollectibleSystem):setEnabled(true)
    self.world:getSystem(WarpSystem):setEnabled(true)
    self.world:getSystem(FlagSystem):setEnabled(true)
    self.world:getSystem(CallbackSystem):setEnabled(true)
    self.world:getSystem(ScoreSystem):setEnabled(true)

    self.pauseText.text:setVisible(false)
    self.continueText.text:setVisible(false)
    self.optionsText.text:setVisible(false)
    self.endText.text:setVisible(false)
    self.selectCursor.text:setVisible(false)

    self.world:getSystem(ScoreSystem):hideTransitionEntities()

    self.pauseSelectedOption = 0
    self.selectCursor.position.y = 8.5 * SCALED_CUBE_SIZE
end

function GameScene:startLevelMusic()
    self:setLevelMusic(self:getLevelData().levelType)
end

function GameScene:setLevelMusic(levelType)
    if levelType == LEVEL_TYPE.OVERWORLD or levelType == LEVEL_TYPE.START_UNDERGROUND then
        self.currentMusicID = MUSIC_ID.OVERWORLD
        local overworldMusic = Concord.entity(self.world)
        overworldMusic:give('music_component', MUSIC_ID.OVERWORLD)
    elseif levelType == LEVEL_TYPE.UNDERGROUND then
        self.currentMusicID = MUSIC_ID.UNDERGROUND
        local undergroundMusic = Concord.entity(self.world)
        undergroundMusic:give('music_component', MUSIC_ID.UNDERGROUND)
    elseif levelType == LEVEL_TYPE.CASTLE then
        self.currentMusicID = MUSIC_ID.CASTLE
        local castleMusic = Concord.entity(self.world)
        castleMusic:give('music_component', MUSIC_ID.CASTLE)
    elseif levelType == LEVEL_TYPE.UNDERWATER then
        self.currentMusicID = MUSIC_ID.UNDERWATER
        local underwaterMusic = Concord.entity(self.world)
        underwaterMusic:give('music_component', MUSIC_ID.UNDERWATER)
    end
end

function GameScene:handlePlayerInput()
    if input:released('PAUSE') then
        self.paused = not self.paused
        if self.paused then
            print('paused')
            self:pause()
        else
            print('unpaused')
            self:unpause()
        end
    end
end

function GameScene:resumeLastPlayedMusic()
    local music = Concord.entity(self.world)
    music:give('music_component', self.currentMusicID)
end

function GameScene:destroyWorldEntities()
    for _, entity in ipairs(self.world:getEntities()) do
        if not entity:has('player') and not entity:has('icon') then
            if entity:has('text') and not entity:has('floating_text') then
            else
                if entity:has('add_lives_component') then
                    entity.add_lives_component:destroy()
                end
                if entity:has('add_score_component') then
                    entity.add_score_component:destroy()
                end
                if entity:has('animation_component') then
                    entity.animation_component:destroy()
                end
                if entity:has('block_bump_component') then
                    entity.block_bump_component:destroy()
                end
                if entity:has('bowser_component') then
                    entity.bowser_component:destroy()
                end
                if entity:has('bridge_component') then
                    entity.bridge_component:destroy()
                end
                if entity:has('callback_component') then
                    entity.callback_component:destroy()
                end
                if entity:has('collectible') then
                    entity.collectible:destroy()
                end
                if entity:has('create_floating_text_component') then
                    entity.create_floating_text_component:destroy()
                end
                if entity:has('crushable_component') then
                   entity.crushable_component:destroy() 
                end
                if entity:has('destroy_delayed_component') then
                    entity.destroy_delayed_component:destroy()
                end

                if entity:has('destructible_component') then
                    entity.destructible_component:destroy()
                end

                if entity:has('ending_blink_component') then
                    entity.ending_blink_component:destroy()
                end

                if entity:has('enemy') then
                    entity.enemy:destroy()
                end

                if entity:has('fire_bar_component') then
                    entity.fire_bar_component:destroy()
                end

                if entity:has('hammer_bro_component') then
                    entity.hammer_bro_component:destroy()
                end

                if entity:has('lakitu_component') then
                    entity.lakitu_component:destroy()
                end

                if entity:has('moving_platform_component') then
                    entity.moving_platform_component:destroy()
                end

                if entity:has('moving_component') then
                    entity.moving_component:destroy()
                end

                if entity:has('music_component') then
                    entity.music_component:destroy()
                end

                if entity:has('mystery_box_component') then
                    entity.mystery_box_component:destroy()
                end

                if entity:has('pause_animation_component') then
                    entity.pause_animation_component:destroy()
                end

                if entity:has('platform_level_component') then
                    entity.platform_level_component:destroy()
                end

                if entity:has('position') then
                    entity.position:destroy()
                end

                if entity:has('projectile') then
                    entity.projectile:destroy()
                end

                if entity:has('sound_component') then
                    entity.sound_component:destroy()
                end

                if entity:has('spritesheet') then
                    entity.spritesheet:destroy()
                end

                if entity:has('text') then
                    entity.text:destroy()
                end

                if entity:has('texture') then
                    entity.texture:destroy()
                end

                if entity:has('timer_component') then
                    entity.timer_component:destroy()
                end

                if entity:has('trampoline_component') then
                    entity.trampoline_component:destroy()
                end

                if entity:has('vine_component') then
                    entity.vine_component:destroy()
                end

                if entity:has('wait_until_component') then
                    entity.wait_until_component:destroy()
                end

                if entity:has('wait_until_component') then
                    entity.wait_until_component:destroy()
                end

                if entity:has('warp_pipe_component') then
                    entity.warp_pipe_component:destroy()
                end

                self.world:removeEntity(entity)
                entity = nil
            end
        end
    end
end

function GameScene:setupLevel()
    local marioState = nil

    self:destroyWorldEntities()

    if self.gameLevel then
        self.gameLevel:getData():destroy()
    end
    self.gameLevel = Level()

    love.graphics.setBackgroundColor(BACKGROUND_COLOR_BLACK)
    self:loadLevel(self.level, self.subLevel)
    self.world:getSystem(ScoreSystem):setScene(self)
    self.world:getSystem(ScoreSystem):showTransitionEntities()
    self.world:getSystem(ScoreSystem):reset()
    self.world:getSystem(RenderSystem):setTransitionRendering(true)

    self.world:getSystem(MapSystem):setScene(self)
    self.world:getSystem(MapSystem):loadEntities()

    local newMarioState = nil
    if self.world:getSystem(PlayerSystem) then
        if self.world:getSystem(PlayerSystem).mario.player then
            newMarioState = self.world:getSystem(PlayerSystem):getPlayerState()
        end
    end

    self.world:getSystem(PlayerSystem):setScene(self)

    if newMarioState ~= nil then
        self.world:getSystem(PlayerSystem):setPlayerState(newMarioState)
    end

    self.world:getSystem(FlagSystem):setScene(self)

    self.world:getSystem(WarpSystem):setScene(self)

    self.world:getSystem(CallbackSystem):setEnabled(false)
    self.world:getSystem(PhysicsSystem):setEnabled(false)
    self.world:getSystem(EnemySystem):setEnabled(false)


    CommandScheduler:addCommand( DelayedCommand(function() 
          self.world:getSystem(CallbackSystem):setEnabled(true)
          self.world:getSystem(PhysicsSystem):setEnabled(true)
          self.world:getSystem(EnemySystem):setEnabled(true)

          love.graphics.setBackgroundColor(self.gameLevel:getData().backgroundColor)
          self:startTimer()
          self.world:getSystem(ScoreSystem):hideTransitionEntities()
          self.world:getSystem(RenderSystem):setTransitionRendering(false)
          self:startLevelMusic()
          self.world:getSystem(PlayerSystem):reset()

          local show_performance_log = false
          if show_performance_log then
            print('Systems ', #self.world:getSystems())
            print('Entities ', #self.world:getEntities())
            print('Memory ', collectgarbage("count")/1024)
          end

          collectgarbage()
          if show_performance_log then
            print("After collection: " .. collectgarbage("count")/1024)
            print("Object count: ")
          end

          local counts = type_count()
          for k, v in pairs(counts) do print(k, v) end
    end, 3.0))
end

function GameScene:switchLevel(level, subLevel)
    CommandScheduler:addCommand( RunCommand(
    function()
        if level == 0 and subLevel == 0 then
            self.gameWon = true
            return
        end

        self.level = level
        self.subLevel = subLevel
        self:setupLevel()
    end) )
end

function GameScene:restartLevel()
    CommandScheduler:addCommand( RunCommand(
    function()
        self.world:getSystem(ScoreSystem):reset()
        self.world:getSystem(ScoreSystem):decreaseLives()

        if self.world:getSystem(ScoreSystem):getLives() <= 0 then
            self.is_finished = true
            return
        end
        self:setupLevel()
    end) )
end

function GameScene:setUnderwater(val)
    self.world:getSystem(PlayerSystem):setUnderwater(val)
end

function GameScene:setCurrentLevelType(levelType) 
    self.currentLevelType = levelType
end

function GameScene:isFinished()
    return self.is_finished
end