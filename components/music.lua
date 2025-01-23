Musicomponent = Concord.component('music_component', function(component, id) 
    component.musicId = id
end)

function Musicomponent:removed()
    self.musicId = nil
 end
 
 function Musicomponent:destroy()
    self:removed()
 end