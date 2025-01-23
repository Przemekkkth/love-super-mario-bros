PositionComponent = Concord.component('position', function(e, position, scale, hitbox)
    e.position = position or {x = 0, y = 0}  -- Default to (0, 0) if not provided
    e.scale = scale or {x = 1, y = 1}        -- Default scale to (1, 1)
    e.hitbox = hitbox or {x = 0, y = 0, w = e.scale.x, h = e.scale.y}
end)

function PositionComponent:getRight()
    return self.position.x + self.scale.x
end

function PositionComponent:getLeft()
    return self.position.x
end

function PositionComponent:getTop()
    return self.position.y
end

function PositionComponent:getBottom()
    return self.position.y + self.scale.y
end

function PositionComponent:getCenterX()
    return self.position.x + self.scale.x / 2
end

function PositionComponent:getCenterY()
    return self.position.y + self.scale.y / 2
end

function PositionComponent:setTop(value)
    self.position.y = value
end

function PositionComponent:setBottom(value)
    self.position.y = value - self.scale.y
end

function PositionComponent:setLeft(value)
    self.position.x = value
end

function PositionComponent:setRight(value)
    self.position.x = value - self.scale.x
end

function PositionComponent:setCenterX(value)
    self.position.x = value - self.scale.x / 2
end

function PositionComponent:setCenterY(value)
    self.position.y = value - self.scale.y / 2
end

function PositionComponent:removed()
    self.position = nil
    self.scale = nil
    self.hitbox = nil
 end
 
 function PositionComponent:destroy()
    self:removed()
 end