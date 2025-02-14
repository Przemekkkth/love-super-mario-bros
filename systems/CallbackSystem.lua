CallbackSystem = Concord.system()

function CallbackSystem:update()
    if not self:isEnabled() then
        return
    end

    local filterSystem = self:getWorld():getSystem(FilterSystem)
    local world = self:getWorld()

    for _, entity in ipairs(filterSystem:getWaitUntilEntities()) do
        local waitUntil = entity.wait_until_component
        if waitUntil.condition(entity) then
            waitUntil.doAfter(entity)
        end
    end

    for _, entity in ipairs(filterSystem:getCallbackEntities()) do
        local callback = entity.callback_component
        callback.time = callback.time - 1
        if callback.time == 0 then
            callback.callback(entity)
            entity:remove('callback_component')
        end
    end

    for _, entity in ipairs(filterSystem:getTimerEntities()) do
        local timer = entity.timer_component
        timer.time = timer.time - 1
        if timer.time == 0 then
            timer.onExecute(entity)
            timer.time = timer.delay
        end
    end

    for _, entity in ipairs(filterSystem:getDestroyDelayedEntities()) do
        local destroy = entity.destroy_delayed_component
        if destroy.time > 0 then
            destroy.time = destroy.time - 1
        else
            world:removeEntity(entity)
        end
    end
end
