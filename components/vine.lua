VineComponent = Concord.component('vine_component', function(component, coordinates, teleport, 
                                                                        camera, resetValue,
                                                                        resetLocation,  newCameraMax,  
                                                                        newBackgroundColor, newLevelType, vineParts) 
    
    component.coordinates = coordinates
    component.teleportCoordinates = teleport
    component.cameraCoordinates =  camera
    component.resetYValue = resetValue
    component.resetTeleportLocation = resetLocation
    component.newCameraMax = newCameraMax
    component.newBackgroundColor = newBackgroundColor
    component.newLevelType = newLevelType
    component.vineParts = vineParts
    
end)

function VineComponent:removed()
    self.coordinates = nil
    self.teleportCoordinates = nil
    self.cameraCoordinates = nil
    self.resetYValue = nil
    self.resetTeleportLocation = nil
    self.newCameraMax = nil
    self.newBackgroundColor = nil
    self.newLevelType = nil
    self.vineParts = nil
end

function VineComponent:destroy()
    self:removed()
end