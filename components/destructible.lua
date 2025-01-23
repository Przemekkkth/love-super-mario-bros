DestructibleComponent = Concord.component('destructible_component', function(component, debrisCoordinates) 
    component.debrisCoordinates = debrisCoordinates
end)

function DestructibleComponent:removed()
    self.debrisCoordinates = nil
 end
 
 function DestructibleComponent:destroy()
    self:removed()
 end