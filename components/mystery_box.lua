MysteryBoxComponent = Concord.component('mystery_box_component', function(component, type, dispensed)
    component.type = type
    --component.dispensed = dispensed
    component.whenDispensed = dispensed or function(entity) end
    component.deactivatedCoordinates = {x = 0, y = 0}
end)

function MysteryBoxComponent:removed()
    self.type = nil
    self.whenDispensed = nil
    self.deactivatedCoordinates = nil
 end
 
 function MysteryBoxComponent:destroy()
    self:removed()
 end