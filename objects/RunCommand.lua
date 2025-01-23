RunCommand = Command:extend()

function RunCommand:new(execute, finished)
    self.onExecute = execute
    self.finishedSupplier = finished or function() return true end
end

function RunCommand:execute()
    self.onExecute()
end

function RunCommand:isFinished()
    return self.finishedSupplier()
end