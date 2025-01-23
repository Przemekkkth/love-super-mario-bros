TextureComponent = Concord.component('texture', function(entity, texture, horizontalFlip, verticalFlip)
    entity.texture = texture
    entity.horizontalFlip = horizontalFlip or false
    entity.verticalFlip = verticalFlip or false
    entity.sourceRect = {x = 0, y = 0, width = entity.texture:getWidth(), height = entity.texture:getHeight()}
    entity.visible = true
    entity:setSize(entity.sourceRect.width, entity.sourceRect.height)
end)

function TextureComponent:setSize(x, y)
    self.sizeX = x
    self.sizeY = y
end

function TextureComponent:getTexture()
    return self.texture
end

function TextureComponent:getSourceRect()
    return self.sourceRect
end

function TextureComponent:setHorizontalFlipped(val)
    self.horizontalFlipped = val
end

function TextureComponent:isHorizontalFlipped()
    return self.horizontalFlipped
end

function TextureComponent:setVerticalFlipped(val)
    self.verticalFlipped = val
end

function TextureComponent:isVerticalFlipped()
    return self.verticalFlipped
end

function TextureComponent:setVisible(val)
    self.visible = val
end

function TextureComponent:isVisible()
    return self.visible
end

function TextureComponent:draw(x, y)
    if not self.visible then
        return
    end

    local scaleX = self.horizontalFlipped and -1 or 1
    local scaleY = self.verticalFlipped and -1 or 1

    love.graphics.draw(
        self.texture,
        x, y, --position
        0, -- rotation
        self.sizeX / self.sourceRect.width, self.sizeY / self.sourceRect.height, -- Skalowanie (flipy)
        scaleX == -1 and self.sourceRect.width or 0, -- offset for x flip
        scaleY == -1 and self.sourceRect.height or 0 -- offset for y flip
    )
end

function TextureComponent:removed()
    --print('TextureComponent:removed()')
    self.texture = nil
    self.horizontalFlip = nil
    self.verticalFlip = nil
    self.sourceRect = nil
    self.visible = nil
end

function TextureComponent:destroy()
    self:removed()
end