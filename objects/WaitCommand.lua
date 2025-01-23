WaitCommand = Command:extend()

function WaitCommand:new(seconds)
    if seconds >= 0 then
        self.ticks = math.floor(seconds * MAX_FPS)
    else
        self.ticks = 0
    end
end

function WaitCommand:execute()
    self.ticks = self.ticks - 1
end

function WaitCommand:isFinished()
    return self.ticks <= 0
end