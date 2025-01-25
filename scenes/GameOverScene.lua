GameOverScene = Object:extend()

function GameOverScene:new(level, subLevel)
    love.graphics.setBackgroundColor(BACKGROUND_COLOR_BLACK)
    CameraInstance:setCameraX(0)
    CameraInstance:setCameraY(0)

    self.world = Concord.world()
    self.world:addSystems(SoundSystem, RenderSystem)

    self.gameOverText = Concord.entity(self.world)
    self.gameOverText:give('position', {x = 10 * SCALED_CUBE_SIZE, y = 6.5 * SCALED_CUBE_SIZE})
    self.gameOverText:give('text', 'GAME OVER', 20)

    self.gameOverSound = Concord.entity(self.world)
    self.gameOverSound:give('sound_component', SOUND_ID.GAME_OVER)

    self.timer = 0
end

function GameOverScene:update(dt)
    self.world:emit('update')
    self.timer = self.timer + 1
    if self.timer > 4.5 * MAX_FPS then
        self:destroyWorldEntities()
        gotoScene('MenuScene')
    end
end

function GameOverScene:draw()
    self.world:emit('draw')
end

function GameOverScene:destroyWorldEntities()
    for _, entity in ipairs(self.world:getEntities()) do
        if entity:has('sound_component') then
            entity.sound_component:destroy()
        end

        if entity:has('text') then
            entity.text:destroy()
        end
    end
end

