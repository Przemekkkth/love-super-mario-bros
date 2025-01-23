EndingBlinkComponent = Concord.component('ending_blink_component', function(component, speed, time) 
    component.blinkSpeed = speed
    component.time = time
    component.current = 0
end)

function EndingBlinkComponent:removed()
    self.blinkSpeed = nil
    self.time = nil
    self.current = nil
 end
 
 function EndingBlinkComponent:destroy()
    self:removed()
 end