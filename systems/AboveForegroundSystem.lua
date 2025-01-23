AboveForegroundSystem = Concord.system({ pool = { 'above_foreground' } })

function AboveForegroundSystem:getEntities()
    return self.pool
end