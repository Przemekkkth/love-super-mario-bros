PlayerComponent = Concord.component('player', function(component) 
    component.playerState = PLAYER_STATE.SMALL_MARIO;
    component.superStar = false;
end)

function PlayerComponent:removed()
    self.playerState = nil
    self.superStar = nil
 end
 
 function PlayerComponent:destroy()
    self:removed()
 end