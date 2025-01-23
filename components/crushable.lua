CrushableComponent = Concord.component('crushable_component', function(component, whenCrushed) 
    component.whenCrushed = whenCrushed
end)

function CrushableComponent:removed()
    self.whenCrushed = nil
 end
 
 function CrushableComponent:destroy()
    self:removed()
 end