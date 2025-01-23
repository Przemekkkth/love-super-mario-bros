MovingComponent = Concord.component('moving_component', function(component, velocity, acceleration)
    component.velocity = velocity
    component.acceleration = acceleration
end)

function MovingComponent:removed()
    self.velocity = nil
    self.acceleration = nil
 end
 
 function MovingComponent:destroy()
    self:removed()
 end