LakituComponent = Concord.component('lakitu_component', function(component) 
    component.sideChangeTimer = 0
    component.lakituSide = DIRECTION.LEFT
    component.speedController = PIDController(0.06, 0, 0)
end)

function LakituComponent:removed()
    self.sideChangeTimer = nil
    self.lakituSide = nil
    self.speedController = nil
 end
 
 function LakituComponent:destroy()
    self:removed()
 end