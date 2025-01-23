ParticleSystem = Concord.system({ pool = { 'particle' } })

function ParticleSystem:getEntities()
    return self.pool
end