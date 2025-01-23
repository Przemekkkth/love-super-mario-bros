PrintCommand = Command:extend()

function PrintCommand:new(message)
    self.message = message
end

function PrintCommand:execute()
    print(self.message)
end