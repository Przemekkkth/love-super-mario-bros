ProjectileSystem = Concord.system({ pool = { 'projectile' } })

function ProjectileSystem:getEntities()
    return self.pool
end