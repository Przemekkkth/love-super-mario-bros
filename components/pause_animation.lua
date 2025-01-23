PauseAnimationComponent = Concord.component('pause_animation_component', function(component, frame, length)
    component.frame = frame
    component.length = length
end)

function PauseAnimationComponent:pause(length)
    self.timer = length
end

function PauseAnimationComponent:removed()
    self.frame = nil
    self.length = nil
 end
 
 function PauseAnimationComponent:destroy()
    self:removed()
 end