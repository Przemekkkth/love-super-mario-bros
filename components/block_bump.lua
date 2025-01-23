BlockBumpComponent = Concord.component('block_bump_component', function(component, yChanges)
    component.yChanges = yChanges
    component.yChangeIndex = 1
end)

function BlockBumpComponent:removed()
    self.yChanges = nil
    self.yChangeIndex = nil
end

function BlockBumpComponent:destroy()
    self:removed()
end
