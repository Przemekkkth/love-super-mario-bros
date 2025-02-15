EnemyComponent = Concord.component('enemy', function(component, type)
    component.type = type
    component.crushed = false
end)

function EnemyComponent:removed()
    self.type = nil
 end
 
 function EnemyComponent:destroy()
    self:removed()
 end