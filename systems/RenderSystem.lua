RenderSystem = Concord.system()

function RenderSystem:init(world)
    self.transitionRendering = false
    self.world = world
end

function RenderSystem:draw()
    local filterSystem = self.world:getSystem(FilterSystem) 
    if not self:isEnabled() or filterSystem == nil then
        return
    end

    self:drawBackground()
    self:drawForeground()
    self:drawProjectile()
    self:drawCollectible()
    self:drawEnemy()
    self:drawFloatingText()
    self:drawPlayer()
    self:drawAboveForeground()
    self:drawParticle()
    self:drawIcon()
    self:drawText()
end

function RenderSystem:setTransitionRendering(transition)
    self.transitionRendering = transition
end

function RenderSystem:isTransitionRendering()
    return self.transitionRendering
end

function RenderSystem:renderEntity(entity, cameraBound)
    local position    = entity.position
    local texture     = entity.texture

    if not texture:isVisible() then
        return
    end

    local screenPositionX = position.position.x
    local screenPositionY = position.position.y
    if cameraBound then
        screenPositionX = position.position.x - CameraInstance:getCameraX()
        screenPositionY = position.position.y - CameraInstance:getCameraY()
    end

    screenPositionX = math.floor(screenPositionX)
    screenPositionY = math.floor(screenPositionY)
    
    if entity:has('spritesheet') then
        -- To Do
        local spritesheet = entity.spritesheet
        spritesheet:draw(screenPositionX, screenPositionY)
    else
        texture:setSize(position.scale.x, position.scale.y)
        texture:draw(screenPositionX, screenPositionY)
    end
end

function RenderSystem:renderText(entity, followCamera)
    local followCamera = followCamera or false
    local position = entity.position
    local text     = entity.text

    local screenPositionX = position.position.x
    local screenPositionY = position.position.y
    if followCamera then
        screenPositionX = position.position.x - CameraInstance:getCameraX()
        screenPositionY = position.position.y - CameraInstance:getCameraY()
    end

    screenPositionX = math.floor(screenPositionX)
    screenPositionY = math.floor(screenPositionY)
    if text:isVisible() then
        text:draw(screenPositionX, screenPositionY)
    end
end

function RenderSystem:drawBackground()
    local filterSystem = self.world:getSystem(FilterSystem) 
    if filterSystem == nil then
        return
    end
    for _, entity in ipairs(filterSystem:getBackgroundEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawForeground()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getForegroundEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawProjectile()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getProjectileEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawCollectible()
    if self.world:getSystem(CollectibleSystem) == nil then
        return
    end
    local collectibles = self.world:getSystem(CollectibleSystem):getEntities()
    for _, entity in ipairs(collectibles) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawEnemy()
    if self.world:getSystem(EnemySystem) == nil then
        return
    end

    local enemies = self.world:getSystem(EnemySystem):getEntities()
    for _, entity in ipairs(enemies) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawFloatingText()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getFloatingTextEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('text') then
                self:renderText(entity, entity.text.followCamera)
            end
        end
    end
end

function RenderSystem:drawPlayer()
    if self.world:getSystem(PlayerSystem) == nil then
        return
    end

    if not self.transitionRendering then
        self:renderEntity( self.world:getSystem(PlayerSystem):getMario(), true)
    end
end

function RenderSystem:drawAboveForeground()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getAboveForegroundEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawParticle()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getParticleEntities()) do
        if not self.transitionRendering then
            if entity:has('position') and entity:has('texture') then
                self:renderEntity(entity, true)
            end
        end
    end
end

function RenderSystem:drawIcon()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getIconEntities()) do
        if entity:has('position') and entity:has('texture') then
            self:renderEntity(entity, false)
        end
    end
end

function RenderSystem:drawText()
    local filterSystem = self.world:getSystem(FilterSystem) 
    for _, entity in ipairs(filterSystem:getTextEntities()) do
        if entity:has('position') then
            if not entity:has('floating_text') then
                self:renderText(entity, entity.text.followCamera)
            end
        end
    end
end