HammerBroComponent = Concord.component('hammer_bro_component', function(component, throwHammer)
    component.lastJumpTime = 0
    component.lastThrowTime = 0
    component.lastMoveTime = 0
    component.hammer = nil
 
    component.lastMoveDirection = DIRECTION.NONE
 
    component.throwHammer = throwHammer
end)

function HammerBroComponent:removed()
    self.lastJumpTime = nil
    self.lastThrowTime = nil
    self.lastMoveTime = nil
    self.hammer = nil
    self.lastMoveDirection = nil
    self.throwHammer = nil
 end
 
 function HammerBroComponent:destroy()
    self:removed()
 end