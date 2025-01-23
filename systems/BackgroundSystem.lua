BackgroundSystem = Concord.system({ pool = { 'background' } })

function BackgroundSystem:getEntities()
    return self.pool
end