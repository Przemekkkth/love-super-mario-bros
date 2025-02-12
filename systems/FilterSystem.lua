FilterSystem = Concord.system({ 
    bg = { 'background' },
    fg = {'foreground'}, 
    above_fg = {'above_foreground'},
    particle = {'particle'}, 
    projectile = {'projectile'}, 
    block_bump = {'block_bump_component'},
    fire_bar = {'fire_bar_component'},
    moving_platform = {'moving_platform_component'},
    platform_level = {'platform_level_component'},
    floating_text = {'floating_text'},
    icon = {'icon'},
    text = {'text'},
    create_floating_text = {'create_floating_text_component'},
    add_score = {'add_score_component'},
    add_lives = {'add_lives_component'},
    sound = {'sound_component'},
    music = {'music_component'}
})

function FilterSystem:getBackgroundEntities()
    return self.bg
end

function FilterSystem:getForegroundEntities()
    return self.fg
end

function FilterSystem:getAboveForegroundEntities()
    return self.above_fg
end

function FilterSystem:getParticleEntities()
    return self.particle
end

function FilterSystem:getProjectileEntities()
    return self.projectile
end

function FilterSystem:getBlockBumpEntities()
    return self.block_bump
end

function FilterSystem:getFireBarEntities()
    return self.fire_bar
end

function FilterSystem:getMovingPlatformEntities()
    return self.moving_platform
end

function FilterSystem:getPlatformLevelEntities()
    return self.platform_level
end

function FilterSystem:getFloatingTextEntities()
    return self.floating_text
end

function FilterSystem:getIconEntities()
    return self.icon
end

function FilterSystem:getTextEntities()
    return self.text
end

function FilterSystem:getCreateFloatingTextEntities()
    return self.create_floating_text
end

function FilterSystem:getAddScoreEntities()
    return self.add_score
end

function FilterSystem:getAddLivesEntities()
    return self.add_lives
end

function FilterSystem:getSoundEntities()
    return self.sound
end

function FilterSystem:getMusicEntities()
    return self.music
end