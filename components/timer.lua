TimerComponent = Concord.component('timer_component', function(component, onExecute, delay)
    component.onExecute = onExecute or function(entity) end
    component.delay = delay
    component.time = delay
end)

function TimerComponent:reset()
    self.time = self.delay
end

function TimerComponent:removed()
    self.onExecute = nil
    self.delay = nil
    self.time = nil
end

function TimerComponent:destroy()
    self:removed()
end