AnimationComponent = Concord.component('animation_component', function(component, frameIDs, framesPerSecond, coordinateSupplier, repeated)
    component.frameIDs = frameIDs
    component.framesPerSecond = framesPerSecond
    component.coordinateSupplier = coordinateSupplier
    if repeated == nil then
        component.repeated = true
    else
        component.repeated = repeated
    end

    component.frameCount = #component.frameIDs
    component.playing = true
    component.frameDelay = math.floor(MAX_FPS / component.framesPerSecond)
    component.frameTimer = 0
    component.currentFrame = 0
end)

function AnimationComponent:setPlaying(val)
    self.playing = val
end

function AnimationComponent:setFramesPerSecond(fps)
    self.framesPerSecond = fps
    self.frameDelay = math.floor(MAX_FPS / self.framesPerSecond)
end

function AnimationComponent:removed()
    self.frameIDs = nil
    self.framesPerSecond = nil
    self.coordinateSupplier = nil
    self.repeated = nil

    self.frameCount = nil
    self.playing = nil
    self.frameDelay = nil
    self.frameTimer = nil
    self.currentFrame = nil
end

function AnimationComponent:destroy()
    self:removed()
end