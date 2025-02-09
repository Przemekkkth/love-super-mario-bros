PlatformLevelSystem = Concord.system({ pool = { 'platform_level_component' } })

function PlatformLevelSystem:getEntities()
    return self.pool
end