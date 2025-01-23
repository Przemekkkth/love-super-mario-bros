BridgeComponent = Concord.component('bridge_component', function(component) 
    component.connectedBridgeParts = {}
end)

function BridgeComponent:removed()
    self.connectedBridgeParts = nil
end

function BridgeComponent:destroy()
    self:removed()
end