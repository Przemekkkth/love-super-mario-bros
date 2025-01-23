CollectibleSystem = Concord.system({ pool = { 'collectible' } })

function CollectibleSystem:update()
    if not self:isEnabled() then
        return
    end

    for _, entity in ipairs(self.pool) do
        local collectible = entity.collectible
        if entity:has('left_collision_component') and entity:has('gravity_component') then
            entity.moving_component.velocity.x = COLLECTIBLE_SPEED
        end

        if entity:has('right_collision_component') and entity:has('gravity_component') then
            entity.moving_component.velocity.x = -COLLECTIBLE_SPEED
        end

        if collectible.collectibleType == COLLECTIBLE_TYPE.SUPER_STAR then
            if entity:has('bottom_collision_component') then
                entity.moving_component.velocity.y = -10.0
            end
        end

        entity:remove('top_collision_component')
        entity:remove('bottom_collision_component')
        entity:remove('left_collision_component')
        entity:remove('right_collision_component')
    end
end

function CollectibleSystem:getEntities()
    return self.pool
end