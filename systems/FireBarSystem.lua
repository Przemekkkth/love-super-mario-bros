FireBarSystem = Concord.system({ pool = { 'fire_bar_component' } })

function FireBarSystem:getEntities()
    return self.pool
end