WaitUntilComponent = Concord.component('wait_until_component', function(component, condition, doAfter)
    component.condition = condition or function(entity) return false end
    component.doAfter   = doAfter or function(entity) end
end)

function WaitUntilComponent:removed()
    self.condition = nil
    self.doAfter = nil
end

function WaitUntilComponent:destroy()
    self:removed()
end