WaitUntilCommand = Command:extend()

function WaitUntilCommand:new(condition)
    self.condition = condition
end

function WaitUntilCommand:execute()

end

function WaitUntilCommand:isFinished()
    return self.condition()
end
