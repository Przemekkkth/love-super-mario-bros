MenuScene = Object:extend()

function MenuScene:new()
    self.menuWorld = Concord.world()
    self.optionsWorld = Concord.world()
    self.backgroundMap = Map('assets/data/MenuBackground/MenuBackground_Background.csv')
    self:createMenuEntities()
    self.menuWorld:addSystems(RenderSystem, MenuSystem, BackgroundSystem)
    self.optionsWorld:addSystems(RenderSystem, OptionsSystem, BackgroundSystem)

    self:optionsSystem():setEnabled(false)
    love.graphics.setBackgroundColor(BACKGROUND_COLOR_BLUE)

    self.finished = false
end

function MenuScene:update(dt)
    self.menuWorld:emit('update')
    self.optionsWorld:emit('update')

    if self:optionsSystem():isEnabled() then
        if self:optionsSystem():isFinished() then
            self:optionsSystem():setEnabled(false)
            self:menuSystem():setEnabled(true)
            self.menuWorld:emit('showMenuText')
            return
        end
    end

    if input:pressed('MENU_ACCEPT') then
        if self.menuWorld:getSystem(MenuSystem):levelSelected() then
            self.finished = true
            local level = self.menuWorld:getSystem(MenuSystem):getSelectedLevel()
            local subLevel = self.menuWorld:getSystem(MenuSystem):getSelectedSublevel()
            gotoScene('GameScene', level, subLevel)
        elseif self.menuWorld:getSystem(MenuSystem):optionsSelected() then
           self:optionsSystem():setEnabled(true)
           self:optionsSystem():setFinished(false)
           self:menuSystem():setEnabled(false)
           self.menuWorld:emit('hideMenuText')
        end
    end
end

function MenuScene:draw()
    self.menuWorld:emit('draw')
    if self:optionsSystem():isEnabled() then
        self.optionsWorld:emit('draw')
    end
end

function MenuScene:createMenuEntities()
    for i = 1, #self.backgroundMap.levelData do
        for j = 1, #self.backgroundMap.levelData[i] do
            local entityID = self.backgroundMap.levelData[i][j]
            if entityID ~= -1 then
                local entity = Concord.entity(self.menuWorld)
                entity:give('position', {x = (j-1) * SCALED_CUBE_SIZE, y = (i-1) * SCALED_CUBE_SIZE}, {x = SCALED_CUBE_SIZE, y = SCALED_CUBE_SIZE} )
                entity:give('texture', BLOCK_TILESHEET_IMG)
                entity:give('background')
                entity:give('spritesheet', entity.texture, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE,
                 1, 1, 1, ORIGINAL_CUBE_SIZE, ORIGINAL_CUBE_SIZE, MapInstance:getBlockCoord(entityID) )
            end
        end
    end
end

function MenuScene:isFinished()
    return self.finished
end

function MenuScene:optionsSystem()
    return self.optionsWorld:getSystem(OptionsSystem)
end

function MenuScene:menuSystem()
    return self.menuWorld:getSystem(MenuSystem)
end