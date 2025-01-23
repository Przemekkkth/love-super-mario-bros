PiranhaPlantComponent = Concord.component('piranha_plant_component', function(component)
    component.pipeCoordinates = {x = 0, y = 0}
    component.inPipe = false
end)

function PiranhaPlantComponent:removed()
    self.pipeCoordinates = nil
    self.inPipe = nil
 end
 
 function PiranhaPlantComponent:destroy()
    self:removed()
 end