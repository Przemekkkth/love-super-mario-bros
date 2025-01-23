Command = Object:extend()

function Command:new()

end

function Command:execute()
    error("execute method must be implemented in derived classes")
end

function Command:isFinished()
    return true
end