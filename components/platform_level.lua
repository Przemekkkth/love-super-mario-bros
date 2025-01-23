PlatformLevelComponent = Concord.component('platform_level_component', function(component, other, pulleyLine, pulleyHeight)
    component.otherPlatform = other
    component.pulleyLine = pulleyLine
    component.pulleyHeight = pulleyHeight
    component.pulleyLines = {}
end)

function PlatformLevelComponent:getOtherPlatform()
    return self.otherPlatform
end

function PlatformLevelComponent:removed()
    self.otherPlatform = nil
    self.pulleyLine = nil
    self.pulleyHeight = nil
    self.pulleyLines = nil
 end
 
 function PlatformLevelComponent:destroy()
    self:removed()
 end