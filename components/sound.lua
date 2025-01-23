SoundComponent = Concord.component('sound_component', function(component, id) 
    component.soundId = id
end)

function SoundComponent:removed()
    self.soundId = nil
 end
 
 function SoundComponent:destroy()
    self:removed()
 end