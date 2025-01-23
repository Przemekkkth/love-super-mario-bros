TrampolineComponent = Concord.component('trampoline_component', function(component, bottomEntity, topIDS, bottomIDS)
    component.topExtendedID = topIDS[1]
    component.topMediumRetractedID = topIDS[2]
    component.topRetractedID = topIDS[3]

    component.bottomExtendedID = bottomIDS[1]
    component.bottomMediumRetractedID = bottomIDS[2]
    component.bottomRetractedID = bottomIDS[3]

    component.currentSequenceIndex = 0
    component.bottomEntity = bottomEntity
end)

function TrampolineComponent:removed()
    self.topExtendedID = nil
    self.topMediumRetractedID = nil
    self.topRetractedID = nil

    
    self.bottomExtendedID = nil
    self.bottomMediumRetractedID = nil
    self.bottomRetractedID = nil

    self.currentSequenceIndex = nil
    self.bottomEntity = nil
end

function TrampolineComponent:destroy()
    self:removed()
end