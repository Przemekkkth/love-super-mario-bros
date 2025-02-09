BlockBumpSystem = Concord.system({ pool = { 'block_bump_component' } })

function BlockBumpSystem:getEntities()
    return self.pool
end