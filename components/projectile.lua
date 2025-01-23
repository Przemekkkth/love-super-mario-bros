ProjectileComponent = Concord.component('projectile', function(component, type)
    component.type = type
end)

function ProjectileComponent:removed()
    self.type = nil
 end
 
 function ProjectileComponent:destroy()
    self:removed()
 end