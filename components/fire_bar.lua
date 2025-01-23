FireBarComponent = Concord.component('fire_bar_component', function(component, rotationPoint, barPosition, 
                                                                                      startAngle, direction) 
    component.pointOfRotation = rotationPoint
    component.barPosition = barPosition
    component.barAngle = startAngle
    component.direction = direction
end)

-- Calculate Y position based on angle
function FireBarComponent:calculateYPosition(angle)
    local angleRadians = math.rad(angle) -- Convert degrees to radians
    return math.sin(angleRadians) * self.barPosition
end

-- Calculate X position based on angle
function FireBarComponent:calculateXPosition(angle)
    local angleRadians = math.rad(angle) -- Convert degrees to radians
    return math.cos(angleRadians) * self.barPosition
end

function FireBarComponent:removed()
    self.pointOfRotation = nil
    self.barPosition = nil
    self.barAngle = nil
    self.direction = nil
 end
 
 function FireBarComponent:destroy()
    self:removed()
 end