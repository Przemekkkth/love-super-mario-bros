TextComponent = Concord.component('text', function(entity, text, fontSize, followCamera, visible)
    entity.text = text
    entity.fontSize = fontSize
    entity.followCamera = followCamera or false
    if visible == nil then
        entity.visible = true
    else
        entity.visible = visible
    end
end)

function TextComponent:isVisible()
    return self.visible
end

function TextComponent:setVisible(val)
    self.visible = val
end

function TextComponent:draw(x, y)
    if not self:isVisible() then
        return
    end

    if self.fontSize == 16 then
        love.graphics.setFont(NORMAL_FONT_16)
    elseif self.fontSize == 15 then
        love.graphics.setFont(NORMAL_FONT_15)
    elseif self.fontSize == 12 then
        love.graphics.setFont(NORMAL_FONT_12)
    elseif self.fontSize == 10 then
        love.graphics.setFont(NORMAL_FONT_10)
    end
    love.graphics.print(self.text, x, y)
end

function TextComponent:setText(val)
    self.text = val
end

function TextComponent:removed()
    self.text = nil
    self.fontSize = nil
    self.followCamera = nil
    self.visible = nil
end

function TextComponent:destroy()
    self:removed()
end