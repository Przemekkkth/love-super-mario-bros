CollectibleComponent = Concord.component('collectible', function(component, type)
   component.collectibleType = type
end)

function CollectibleComponent:removed()
   self.collectibleType = nil
end

function CollectibleComponent:destroy()
   self:removed()
end