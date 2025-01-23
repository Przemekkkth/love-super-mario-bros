CommandScheduler = Object:extend()

function CommandScheduler:new()
    self.commandQueue = {}
    self.destroyQueue = {}
end

function CommandScheduler:addCommand(command)
    table.insert(self.commandQueue, command)
end

function CommandScheduler:run()
    for _, command in ipairs(self.commandQueue) do
        command:execute()

        if command:isFinished() then
            table.insert(self.destroyQueue, command) 
        end
    end

    self:emptyDestroyQueue()
end

 function CommandScheduler:emptyDestroyQueue()
    if #self.destroyQueue == 0 then
        return
    end

    for _, command in ipairs(self.destroyQueue) do
        -- Remove the command from the commandQueue
        for i = #self.commandQueue, 1, -1 do
            if self.commandQueue[i] == command then
                table.remove(self.commandQueue, i)
            end
        end

        -- Clean up the command
        --if command.destroy then
        --    command:destroy() -- Call destroy method if it exists
        --end
    end

    -- Clear the destroyQueue and optimize commandQueue memory
    self.destroyQueue = {}
end
