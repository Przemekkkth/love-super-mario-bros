MovingPlatformComponent = Concord.component('moving_platform_component', function(component, motionType, movingDirection,
                                                                                             minMax) 
    component.motionType = motionType
    component.movingDirection = movingDirection
    component.minMax = minMax or {x = 0, y = 0}

    component.minPoint = component.minMax.x
    component.maxPoint = component.minMax.y
end)

function MovingPlatformComponent:calculateVelocity(position, distanceTravel)
    local numerator = math.pow(position - (1.9 * distanceTravel), 2)
    local denominator = 2 * math.pow(distanceTravel, 2)
    return 2 * math.exp(-(numerator / denominator))
end

function MovingPlatformComponent:removed()
    self.motionType = nil
    self.movingDirection = nil
    self.minMax = nil
    self.minPoint = nil
    self.maxPoint = nil
 end
 
 function MovingPlatformComponent:destroy()
    self:removed()
 end