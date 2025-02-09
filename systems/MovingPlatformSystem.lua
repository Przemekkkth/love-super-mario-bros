MovingPlatformSystem = Concord.system({ pool = { 'moving_platform_component' } })

function MovingPlatformSystem:getEntities()
    return self.pool
end