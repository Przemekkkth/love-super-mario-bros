ForegroundSystem = Concord.system({ pool = { 'foreground' } })

function ForegroundSystem:getEntities()
    return self.pool
end