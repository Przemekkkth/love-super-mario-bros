SpritesheetComponent = Concord.component('spritesheet', function(entity, texture, entityWidth, entityHeight, xOffset, yOffset, gridGapWidth, gridWidth, gridHeight, spritesheetCoordinates)
    entity.texture = texture
    entity.entityWidth = entityWidth
    entity.entityHeight = entityHeight
    entity.xOffset = xOffset
    entity.yOffset = yOffset
    entity.gridGapWidth = gridGapWidth
    entity.gridWidth = gridWidth
    entity.gridHeight = gridHeight
    entity.spritesheetCoordinates = spritesheetCoordinates
    entity.sourceRect = {}
    entity.sourceRect.x = entity.xOffset + ((entity.spritesheetCoordinates.x) * entity.gridGapWidth) +
    ((entity.spritesheetCoordinates.x) * entity.gridWidth)
    entity.sourceRect.y = entity.yOffset + ((entity.spritesheetCoordinates.y) * entity.gridGapWidth) +
    ((entity.spritesheetCoordinates.y) * entity.gridHeight)
    entity.sourceRect.w = entity.entityWidth
    entity.sourceRect.h = entity.entityHeight

    entity.quad = love.graphics.newQuad(entity.sourceRect.x, entity.sourceRect.y, entity.sourceRect.w, entity.sourceRect.h, entity.texture:getTexture())
end)

function SpritesheetComponent:setSpritesheetCoordinates(coords)
    self.spritesheetCoordinates = coords
    self.sourceRect.x = self.xOffset + ((self.spritesheetCoordinates.x) * self.gridGapWidth) +
    ((self.spritesheetCoordinates.x) * self.gridWidth)
    self.sourceRect.y = self.yOffset + ((self.spritesheetCoordinates.y) * self.gridGapWidth) +
    ((self.spritesheetCoordinates.y) * self.gridHeight)

    self.sourceRect.w = self.entityWidth
    self.sourceRect.h = self.entityHeight

    self.quad = love.graphics.newQuad(self.sourceRect.x, self.sourceRect.y, self.sourceRect.w, self.sourceRect.h, self.texture:getTexture())
end

function SpritesheetComponent:setSpritesheetXCoordinates(xCoordinate)
    self.spritesheetCoordinates.x = xCoordinate
    self.sourceRect.x = self.xOffset + ((self.spritesheetCoordinates.x) * self.gridGapWidth) +
    ((self.spritesheetCoordinates.x) * self.gridWidth)
    self.sourceRect.y = self.yOffset + ((self.spritesheetCoordinates.y) * self.gridGapHeight) +
    ((self.spritesheetCoordinates.y) * self.gridHeight)

    self.sourceRect.w = self.entityWidth
    self.sourceRect.h = self.entityHeight

    self.quad = love.graphics.newQuad(self.sourceRect.x, self.sourceRect.y, self.sourceRect.w, self.sourceRect.h, self.texture:getTexture())
end

function SpritesheetComponent:setEntityHeight(newEntityHeight)
    self.entityHeight = newEntityHeight
    self.sourceRect.h = self.entityHeight
    self.quad = love.graphics.newQuad(self.sourceRect.x, self.sourceRect.y, self.sourceRect.w, self.sourceRect.h, self.texture:getTexture())
end

function SpritesheetComponent:setEntityWidth(newEntityWidth)
    self.entityWidth = newEntityWidth
    self.sourceRect.w = self.entityWidth
    self.quad = love.graphics.newQuad(self.sourceRect.x, self.sourceRect.y, self.sourceRect.w, self.sourceRect.h, self.texture:getTexture())
end

function SpritesheetComponent:setGridHeight(newGridHeight)
    self.gridHeight = newGridHeight
    self.sourceRect.y = self.yOffset + ((self.spritesheetCoordinates.y) * self.gridGapHeight) +
    ((self.spritesheetCoordinates.y) * self.gridHeight)
    self.quad = love.graphics.newQuad(self.sourceRect.x, self.sourceRect.y, self.sourceRect.w, self.sourceRect.h, self.texture:getTexture())
end

function SpritesheetComponent:getSpritesheetCoordinates()
    return self.spritesheetCoordinates
end

function SpritesheetComponent:getSourceRect()
    return self.sourceRect
end

function SpritesheetComponent:draw(x, y)
    if not self.texture:isVisible() then
        return
    end

    local scaleX = self.texture:isHorizontalFlipped() and -1 or 1
    local scaleY = self.texture:isVerticalFlipped() and -1 or 1
    local xPosOffset = 0
    if self.texture:isHorizontalFlipped() then
        xPosOffset = 32
    end

    local yPosOffset = 0
    if self.texture:isVerticalFlipped() then
        yPosOffset = 32
    end
    love.graphics.draw(self.texture:getTexture(), self.quad, x + xPosOffset, y + yPosOffset, 0, 2 * scaleX, 2 * scaleY)
end

function SpritesheetComponent:removed()
    self.texture = nil
    self.entityWidth = nil
    self.entityHeight = nil
    self.xOffset = nil
    self.yOffset = nil
    self.gridGapWidth = nil
    self.gridWidth = nil
    self.gridHeight = nil
    self.spritesheetCoordinates = nil
    self.sourceRect = nil
    self.quad = nil
end

function SpritesheetComponent:destroy()
    self:removed()
end