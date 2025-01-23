AddScoreDestroyed = Concord.component('add_score_component', function(component, score, addCoin) 
    component.score = score
    component.addCoin = addCoin
end)

function AddScoreDestroyed:removed()
    self.score = nil
    self.addCoin = nil
end

function AddScoreDestroyed:destroy()
    self:removed()
end