BowserComponent = Concord.component('bowser_component', function(component, attacks, movements)
    component.attacks = attacks
    component.movements = movements
    component.distanceMoved = 0
    component.lastAttackTime = 0
    component.lastMoveTime = 0
    component.lastStopTime = 0
    component.lastJumpTime = 0
    component.currentMoveIndex = 0
    component.lastMoveDirection = DIRECTION.NONE
end)

function BowserComponent:removed()
    self.attacks = nil
    self.movements = nil
    self.distanceMoved = nil
    self.lastAttackTime = nil
    self.lastMoveTime = nil
    self.lastStopTime = nil
    self.lastJumpTime = nil
    self.currentMoveIndex = nil
    self.lastMoveDirection = nil
end

function BowserComponent:destroy()
    self:removed()
end
