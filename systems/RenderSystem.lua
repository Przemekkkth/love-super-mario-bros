RenderSystem = Concord.system()

function RenderSystem:init(world)
    self.transitionRendering = false
end

function RenderSystem:draw()
    if not self:isEnabled() then
        return
    end
    
    local world = self:getWorld()
    local entities = world:getEntities()

    self:drawBackground()
    self:drawForeground()
    self:drawProjectiles()
    self:drawCollectibles()
    self:drawEnemies()

    for _, entity in ipairs(entities) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('text') and entity:has('floating_text') then
                self:renderText(entity, entity.text.followCamera)
            end
        end
    end

    self:drawPlayer()
    self:drawAboveForeground()
    self:drawParticles()

    for _, entity in ipairs(entities) do
        if entity:has('position') and entity:has('texture') and entity:has('icon') then
            self:renderEntity(entity, false)
        end
    end

    for _, entity in ipairs(entities) do
        if entity:has('position') and entity:has('text') then
            if not entity:has('floating_text') then
                self:renderText(entity, entity.text.followCamera)
            end
        end
    end
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

function RenderSystem:drawLayerInCameraRange(layerName) --position & texture always exists. layer means component name
    for _, entity in ipairs(self:getWorld():getEntities()) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') and entity:has(layerName) then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawLayer(layerName) --position & texture always exists. layer means component name
    for _, entity in ipairs(self:getWorld():getEntities()) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') and entity:has(layerName) then
                self:renderEntity(entity, true)
            end
        end
    end
end

function RenderSystem:drawBackground()
    local world = self:getWorld()
    if world:getSystem(BackgroundSystem) == nil then
        return
    end

    local backgrounds = world:getSystem(BackgroundSystem):getEntities()
    for _, entity in ipairs(backgrounds) do
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
    local world = self:getWorld()
    if world:getSystem(ForegroundSystem) == nil then
        return
    end

    local foregrounds = world:getSystem(ForegroundSystem):getEntities()
    for _, entity in ipairs(foregrounds) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawProjectiles()
    local world = self:getWorld()
    if world:getSystem(ProjectileSystem) == nil then
        return
    end

    local projectiles = world:getSystem(ProjectileSystem):getEntities()
    for _, entity in ipairs(projectiles) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                self:renderEntity(entity, true)
            end
        end
    end
end

function RenderSystem:drawCollectibles()
    local world = self:getWorld()
    if world:getSystem(CollectibleSystem) == nil then
        return
    end
    local collectibles = world:getSystem(CollectibleSystem):getEntities()
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

function RenderSystem:drawEnemies()
    local world = self:getWorld()
    if world:getSystem(EnemySystem) == nil then
        return
    end

    local enemies = world:getSystem(EnemySystem):getEntities()
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

function RenderSystem:drawPlayer()
    local world = self:getWorld()
    if world:getSystem(PlayerSystem) == nil then
        return
    end

    if not self.transitionRendering then
        self:renderEntity( world:getSystem(PlayerSystem):getMario(), true)
    end
end

function RenderSystem:drawAboveForeground()
    local world = self:getWorld()
    if world:getSystem(AboveForegroundSystem) == nil then
        return
    end

    local aboveforegrounds = world:getSystem(AboveForegroundSystem):getEntities()
    for _, entity in ipairs(aboveforegrounds) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                if CameraInstance:inCameraRange(entity.position) then
                    self:renderEntity(entity, true)
                end
            end
        end
    end
end

function RenderSystem:drawParticles()
    local world = self:getWorld()
    if world:getSystem(ParticleSystem) == nil then
        return
    end

    local particles = world:getSystem(ParticleSystem):getEntities()
    for _, entity in ipairs(particles) do
        if not self.transitionRendering then 
            if entity:has('position') and entity:has('texture') then
                self:renderEntity(entity, true)
            end
        end
    end
end