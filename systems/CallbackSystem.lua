CallbackSystem = Concord.system({ pool = { 'wait_until_component' } })

function CallbackSystem:init(world) --onAddedToWorld(world))
end

function CallbackSystem:update()
    if not self:isEnabled() then
        return
    end
    
    for _, entity in ipairs(self.pool) do
        local waitUntil = entity.wait_until_component
        if waitUntil.condition(entity) then
            waitUntil.doAfter(entity)
        end
    end

    local world = self:getWorld()
    for _, entity in ipairs(world:getEntities()) do
        if entity:has('callback_component') then
            local callback = entity.callback_component
            callback.time = callback.time - 1
            if callback.time == 0 then
                callback.callback(entity)
                entity:remove('callback_component')
            end
        end

        if entity:has('timer_component') then
            local timer = entity.timer_component
            timer.time = timer.time - 1
            if timer.time == 0 then
                timer.onExecute(entity)
                timer.time = timer.delay
            end
        end

        if entity:has('destroy_delayed_component') then
            local destroy = entity.destroy_delayed_component
            if destroy.time > 0 then
                destroy.time = destroy.time - 1
            else
                world:removeEntity(entity)
            end
        end
    end
end
