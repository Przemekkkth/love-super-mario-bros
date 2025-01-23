DestroyDelayedComponent = Concord.component('destroy_delayed_component', function(component, time) 
    component.time = time or 0
end)

function DestroyDelayedComponent:removed()
    self.time = nil
 end
 
 function DestroyDelayedComponent:destroy()
    self:removed()
 end