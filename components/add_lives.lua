AddLivesComponent = Concord.component('add_lives_component', function(component, lives)
    component.lives = lives or 1
end)

function AddLivesComponent:removed()
    self.lives = nil
end

function AddLivesComponent:destroy()
    self:removed()
end