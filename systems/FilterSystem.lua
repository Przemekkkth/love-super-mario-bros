FilterSystem = Concord.system({ 
    bgPool = { 'background' },
    fgPool = {'foreground'}, 
    above_fgPool = {'above_foreground'},
    particlePool = {'particle'}, 
    projectilePool = {'projectile'}, 
    block_bumpPool = {'block_bump_component'},
    fire_barPool = {'fire_bar_component'},
    moving_platformPool = {'moving_platform_component'},
    platform_levelPool = {'platform_level_component'},
    floating_textPool = {'floating_text'},
    iconPool = {'icon'},
    textPool = {'text'},
    create_floating_textPool = {'create_floating_text_component'},
    add_scorePool = {'add_score_component'},
    add_livesPool = {'add_lives_component'},
    soundPool = {'sound_component'},
    musicPool = {'music_component'},
    waitUntilPool = {'wait_until_component'},
    callbackPool = {'callback_component'},
    timerPool = {'timer_component'},
    destroyDelayedPool = {'destroy_delayed_component'},
    warpPipePool = {'warp_pipe_component'},
    vinePool = {'vine_component'},
    flagPolePool = {'flag_pole_component'},
    flagPool = {'flag_component'},
    axePool = {'axe_component'},
    movingPool = {'moving_component'},
    endingBlinkPool = {'ending_blink_component'},
    animationPool = {'animation_component'},
    pauseAnimationPool = {'pause_animation_component'}
})

function FilterSystem:getBackgroundEntities()
    return self.bgPool
end

function FilterSystem:getForegroundEntities()
    return self.fgPool
end

function FilterSystem:getAboveForegroundEntities()
    return self.above_fgPool
end

function FilterSystem:getParticleEntities()
    return self.particlePool
end

function FilterSystem:getProjectileEntities()
    return self.projectilePool
end

function FilterSystem:getBlockBumpEntities()
    return self.block_bumpPool
end

function FilterSystem:getFireBarEntities()
    return self.fire_barPool
end

function FilterSystem:getMovingPlatformEntities()
    return self.moving_platformPool
end

function FilterSystem:getPlatformLevelEntities()
    return self.platform_levelPool
end

function FilterSystem:getFloatingTextEntities()
    return self.floating_textPool
end

function FilterSystem:getIconEntities()
    return self.iconPool
end

function FilterSystem:getTextEntities()
    return self.textPool
end

function FilterSystem:getCreateFloatingTextEntities()
    return self.create_floating_textPool
end

function FilterSystem:getAddScoreEntities()
    return self.add_scorePool
end

function FilterSystem:getAddLivesEntities()
    return self.add_livesPool
end

function FilterSystem:getSoundEntities()
    return self.soundPool
end

function FilterSystem:getMusicEntities()
    return self.musicPool
end

function FilterSystem:getWaitUntilEntities()
    return self.waitUntilPool
end

function FilterSystem:getCallbackEntities()
    return self.callbackPool
end

function FilterSystem:getTimerEntities()
    return self.timerPool
end

function FilterSystem:getDestroyDelayedEntities()
    return self.destroyDelayedPool
end

function FilterSystem:getWarpPipeEntities()
    return self.warpPipePool
end

function FilterSystem:getVineEntities()
    return self.vinePool
end

function FilterSystem:getFlagPoleEntities()
    return self.flagPolePool
end

function FilterSystem:getFlagEntities()
    return self.flagPool
end

function FilterSystem:getAxeEntities()
    return self.axePool
end

function FilterSystem:getMovingEntities()
    return self.movingPool
end

function FilterSystem:getEndingBlinkEntities()
    return self.endingBlinkPool
end

function FilterSystem:getAnimationEntities()
    return self.animationPool
end

function FilterSystem:getPauseAnimationEntitites()
    return self.pauseAnimationPool
end