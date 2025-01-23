CallbackComponent = Concord.component('callback_component', function(component, callback, time)
    component.callback = callback or function(entity) end
    component.time = time or 0
end)

function CallbackComponent:removed()
    self.callback = nil
    self.time = nil
end

function CallbackComponent:destroy()
    self:removed()
end