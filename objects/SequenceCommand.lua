SequenceCommand = Command:extend()

function SequenceCommand:new(commandList)
    self.sequenceSize = 0
    self.currentIndex = 1
    self.sequenceFinished = false
    self.commandSequence = {}
    if commandList then
        self:addCommands(commandList)
    end
end

function SequenceCommand:addCommands(commandList)
    for _, command in ipairs(commandList) do
        table.insert(self.commandSequence, command)
    end

    self.sequenceSize = self.sequenceSize
end

function SequenceCommand:execute()
    self.commandSequence[1]:execute()
    if not self.commandSequence[1]:isFinished() then
        return
    end

    table.remove(self.commandSequence, 1)
    if #self.commandSequence == 0 then
        self.sequenceFinished = true
    end
end

function SequenceCommand:isFinished()
    return self.sequenceFinished
end
