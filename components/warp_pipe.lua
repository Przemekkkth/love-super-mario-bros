WarpPipeComponent = Concord.component('warp_pipe_component', function(component, playerLocation, cameraLocation, 
                                                                                 inDirection, outDirection, 
                                                                                 cameraFreeze, backgroundColor, 
                                                                                 levelType, newLevel)
    component.playerLocation = playerLocation
    component.cameraLocation   = cameraLocation

    component.inDirection   = inDirection
    component.outDirection   = outDirection
    component.cameraFreeze   = cameraFreeze
    component.backgroundColor   = backgroundColor
    component.levelType   = levelType
    component.newLevel   = newLevel
end)

function WarpPipeComponent:removed()
    self.playerLocation = nil
    self.cameraLocation = nil

    self.inDirection = nil
    self.outDirection = nil
    self.cameraFreeze = nil
    self.backgroundColor = nil
    self.levelType = nil
    self.newLevel = nil
end

function WarpPipeComponent:destroy()
    self:removed()
end