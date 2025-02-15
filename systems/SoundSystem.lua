SoundSystem = Concord.system()

function SoundSystem:init(world)

end

function SoundSystem:update()
    if not self:isEnabled() then
        return
    end

    local world = self:getWorld()
    local filterSystem = world:getSystem(FilterSystem)
    for _, entity in ipairs(filterSystem:getSoundEntities()) do
        local sound = entity.sound_component
        playSound(sound.soundId)
        world:removeEntity(entity)
    end

    for _, entity in ipairs(filterSystem:getMusicEntities()) do
        stopMusic()
        local music = entity.music_component
        playMusic(music.musicId)
        world:removeEntity(entity)
    end
end