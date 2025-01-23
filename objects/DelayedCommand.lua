DelayedCommand = Command:extend()

function DelayedCommand:new(onExecute, delay)
    self.onExecute = onExecute
    if delay >= 0 then
        self.ticks = delay * MAX_FPS
    else
        self.ticks = 0
    end
end

function DelayedCommand:execute()
    self.ticks = self.ticks - 1
    if self.ticks == 0 then
        self.onExecute()
    end
end

function DelayedCommand:isFinished()
    return self.ticks <= 0
end
