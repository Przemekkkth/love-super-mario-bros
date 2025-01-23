CreateFloatingTextComponent = Concord.component('create_floating_text_component', function(component, originalEntity, text) 
    component.originalEntity = originalEntity
    component.text = text
end)

function CreateFloatingTextComponent:removed()
    self.originalEntity = nil
    self.text = nil
 end
 
 function CreateFloatingTextComponent:destroy()
    self:removed()
 end