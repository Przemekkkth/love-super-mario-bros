SoundSystem = Concord.system()

function SoundSystem:init(world)

end

function SoundSystem:update()
    if not self:isEnabled() then
        return
    end

    local world = self:getWorld()
    for _, entity in ipairs(world:getEntities()) do
        if entity:has('sound_component') then
            local sound = entity.sound_component
            playSound(sound.soundId)
            world:removeEntity(entity)
        elseif entity:has('music_component') then
            stopMusic()
            local music = entity.music_component
            playMusic(music.musicId)
            world:removeEntity(entity)
        end
    end
end