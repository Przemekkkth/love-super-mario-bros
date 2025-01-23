LOGO_IMG = love.graphics.newImage('assets/sprites/icons/logo.png')
LOGO_IMG:setFilter("nearest", "nearest")

LOVE_LOGO_IMG = love.graphics.newImage('assets/love_app_icon.png')
LOVE_LOGO_IMG:setFilter("nearest", "nearest")

AVATAR_IMG = love.graphics.newImage('assets/avatar.png')
AVATAR_IMG:setFilter("linear", "linear")

OPTIONS_BACKGROUND_IMG = love.graphics.newImage('assets/sprites/icons/optionsbackground.png')
OPTIONS_BACKGROUND_IMG:setFilter("nearest", "nearest")

OPTIONS_INFOBACKGROUND_IMG = love.graphics.newImage('assets/sprites/icons/optionsinfobackground.png')
OPTIONS_INFOBACKGROUND_IMG:setFilter("nearest", "nearest")

BLOCK_TILESHEET_IMG = love.graphics.newImage('assets/sprites/blocks/BlockTileSheet.png')
BLOCK_TILESHEET_IMG:setFilter("nearest", "nearest")

ENEMY_TILESHEET_IMG = love.graphics.newImage('assets/sprites/characters/EnemySpriteSheet.png')
ENEMY_TILESHEET_IMG:setFilter("nearest", "nearest")

PLAYER_TILESHEET_IMG = love.graphics.newImage('assets/sprites/characters/PlayerSpriteSheet.png')
PLAYER_TILESHEET_IMG:setFilter("nearest", "nearest")

NORMAL_FONT = love.graphics.newFont('assets/fonts/press-start-2p.ttf', 25)
NORMAL_FONT_16 = love.graphics.newFont('assets/fonts/press-start-2p.ttf', 16)
NORMAL_FONT_15 = love.graphics.newFont('assets/fonts/press-start-2p.ttf', 15)
NORMAL_FONT_12 = love.graphics.newFont('assets/fonts/press-start-2p.ttf', 12)
NORMAL_FONT_10 = love.graphics.newFont('assets/fonts/press-start-2p.ttf', 10)

audio = {}
audio.BLOCKBRAEAK_SFX = love.audio.newSource('assets/sounds/effects/blockbreak.wav', 'static')
audio.BLOCKHIT_SFX    = love.audio.newSource('assets/sounds/effects/blockhit.wav', 'static')
audio.BOWSERFALL_SFX  = love.audio.newSource('assets/sounds/effects/bowserfall.wav', 'static')
audio.BOWSERFIRE_SFX  = love.audio.newSource('assets/sounds/effects/bowserfire.wav', 'static')
audio.CONNONFIRE_SFX  = love.audio.newSource('assets/sounds/effects/cannonfire.wav', 'static')
audio.CASTLECLEAR_SFX = love.audio.newSource('assets/sounds/effects/castleclear.wav', 'static')
audio.COIN_SFX        = love.audio.newSource('assets/sounds/effects/coin.wav', 'static')
audio.DEATH_SFX       = love.audio.newSource('assets/sounds/effects/death.wav', 'static')
audio.FIREBALL_SFX    = love.audio.newSource('assets/sounds/effects/fireball.wav', 'static')
audio.FLAGRAISE_SFX   = love.audio.newSource('assets/sounds/effects/flagraise.wav', 'static')
audio.GAMEOVER_SFX    = love.audio.newSource('assets/sounds/effects/gameover.wav', 'static')
audio.JUMP_SFX        = love.audio.newSource('assets/sounds/effects/jump.wav', 'static')
audio.KICK_SFX        = love.audio.newSource('assets/sounds/effects/kick.wav', 'static')
audio.ONEUP_SFX       = love.audio.newSource('assets/sounds/effects/oneup.wav', 'static')
audio.PAUSE_SFX       = love.audio.newSource('assets/sounds/effects/pause.wav', 'static')
audio.PIPE_SFX        = love.audio.newSource('assets/sounds/effects/pipe.wav', 'static')
audio.POWERUPAPPEAR_SFX = love.audio.newSource('assets/sounds/effects/powerupappear.wav', 'static')
audio.POWERUPCOLLECT_SFX = love.audio.newSource('assets/sounds/effects/powerupcollect.wav', 'static')
audio.SHRINK_SFX      = love.audio.newSource('assets/sounds/effects/shrink.wav', 'static')
audio.STOMP_SFX       = love.audio.newSource('assets/sounds/effects/stomp.wav', 'static')
audio.TIMERTICK_SFX   = love.audio.newSource('assets/sounds/effects/timertick.wav', 'static')

music = {}
music.CASTLE_MFX      = love.audio.newSource('assets/sounds/music/castle.wav', 'stream')
music.GAMEWON_MFX     = love.audio.newSource('assets/sounds/music/gamewon.wav', 'stream')
music.OVERWORLD_MFX   = love.audio.newSource('assets/sounds/music/overworld.wav', 'stream')
music.SUPERSTAR_MFX   = love.audio.newSource('assets/sounds/music/superstar.wav', 'stream')
music.UNDERGROUND_MFX = love.audio.newSource('assets/sounds/music/underground.wav', 'stream')
music.UNDERWATER_MFX  = love.audio.newSource('assets/sounds/music/underwater.wav', 'stream')

function playSound(id)
    if id == SOUND_ID.BLOCK_BREAK then
        audio.BLOCKBRAEAK_SFX:stop()
        audio.BLOCKBRAEAK_SFX:play()
    elseif id == SOUND_ID.BLOCK_HIT then
        audio.BLOCKHIT_SFX:stop()
        audio.BLOCKHIT_SFX:play()
    elseif id == SOUND_ID.BOWSER_FALL then
        audio.BOWSERFALL_SFX:stop()
        audio.BOWSERFALL_SFX:play()
    elseif id == SOUND_ID.BOWSER_FIRE then
        audio.BOWSERFIRE_SFX:stop()
        audio.BOWSERFIRE_SFX:play()
    elseif id == SOUND_ID.CANNON_FIRE then
        audio.CONNONFIRE_SFX:stop()
        audio.CONNONFIRE_SFX:play()
    elseif id == SOUND_ID.COIN then
        audio.COIN_SFX:stop()
        audio.COIN_SFX:play()
    elseif id == SOUND_ID.DEATH then
        audio.DEATH_SFX:stop()
        audio.DEATH_SFX:play()
    elseif id == SOUND_ID.FIREBALL then
        audio.FIREBALL_SFX:stop()
        audio.FIREBALL_SFX:play()
    elseif id == SOUND_ID.FLAG_RAISE then
        audio.FLAGRAISE_SFX:stop()
        audio.FLAGRAISE_SFX:play()
    elseif id == SOUND_ID.GAME_OVER then
        audio.GAMEOVER_SFX:stop()
        audio.GAMEOVER_SFX:play()
    elseif id == SOUND_ID.JUMP then
        audio.JUMP_SFX:stop()
        audio.JUMP_SFX:play()
    elseif id == SOUND_ID.KICK then
        audio.KICK_SFX:stop()
        audio.KICK_SFX:play()
    elseif id == SOUND_ID.ONE_UP then
        audio.ONEUP_SFX:stop()
        audio.ONEUP_SFX:play()
    elseif id == SOUND_ID.PAUSE then
        audio.PAUSE_SFX:stop()
        audio.PAUSE_SFX:play()
    elseif id == SOUND_ID.PIPE then
        audio.PIPE_SFX:stop()
        audio.PIPE_SFX:play()
    elseif id == SOUND_ID.POWER_UP_APPEAR then
        audio.POWERUPAPPEAR_SFX:stop()
        audio.POWERUPAPPEAR_SFX:play()
    elseif id == SOUND_ID.POWER_UP_COLLECT then
        audio.POWERUPCOLLECT_SFX:stop()
        audio.POWERUPCOLLECT_SFX:play()
    elseif id == SOUND_ID.SHRINK then
        audio.SHRINK_SFX:stop()
        audio.SHRINK_SFX:play()
    elseif id == SOUND_ID.STOMP then
        audio.STOMP_SFX:stop()
        audio.STOMP_SFX:play()
    elseif id == SOUND_ID.TIMER_TICK then
        audio.TIMERTICK_SFX:stop()
        audio.TIMERTICK_SFX:play()
    elseif id == SOUND_ID.CASTLE_CLEAR then
        audio.CASTLECLEAR_SFX:stop()
        audio.CASTLECLEAR_SFX:play()
    end
end

function setSoundVolume(val)
    audio.BLOCKBRAEAK_SFX:setVolume(val)
    audio.BLOCKHIT_SFX:setVolume(val)
    audio.BOWSERFALL_SFX:setVolume(val)
    audio.BOWSERFIRE_SFX:setVolume(val)
    audio.CONNONFIRE_SFX:setVolume(val)
    audio.CASTLECLEAR_SFX:setVolume(val)
    audio.COIN_SFX:setVolume(val)
    audio.DEATH_SFX:setVolume(val)
    audio.FIREBALL_SFX:setVolume(val)
    audio.FLAGRAISE_SFX:setVolume(val)
    audio.GAMEOVER_SFX:setVolume(val)
    audio.JUMP_SFX:setVolume(val)
    audio.KICK_SFX:setVolume(val)
    audio.ONEUP_SFX:setVolume(val)
    audio.PAUSE_SFX:setVolume(val)
    audio.PIPE_SFX:setVolume(val)
    audio.POWERUPAPPEAR_SFX:setVolume(val)
    audio.POWERUPCOLLECT_SFX:setVolume(val)
    audio.SHRINK_SFX:setVolume(val)
    audio.STOMP_SFX:setVolume(val)
    audio.TIMERTICK_SFX:setVolume(val)
end

function playMusic(id)
    if id == MUSIC_ID.OVERWORLD then
        music.OVERWORLD_MFX:play()
        music.OVERWORLD_MFX:setLooping(true)
    elseif id == MUSIC_ID.UNDERGROUND then
        music.UNDERGROUND_MFX:play()
        music.UNDERGROUND_MFX:setLooping(true)
    elseif id == MUSIC_ID.CASTLE then
        music.CASTLE_MFX:play()
        music.CASTLE_MFX:setLooping(true)
    elseif id == MUSIC_ID.UNDERWATER then
        music.UNDERWATER_MFX:play()
        music.UNDERWATER_MFX:setLooping(true)
    elseif id == MUSIC_ID.SUPER_STAR then
        music.SUPERSTAR_MFX:play()
        music.SUPERSTAR_MFX:setLooping(true)
    elseif id == MUSIC_ID.GAME_WON then
        music.GAMEWON_MFX:play()
    end
end

function setMusicVolume(val)
    music.CASTLE_MFX:setVolume(val)
    music.GAMEWON_MFX:setVolume(val)
    music.OVERWORLD_MFX:setVolume(val)
    music.SUPERSTAR_MFX:setVolume(val)
    music.UNDERGROUND_MFX:setVolume(val)
    music.UNDERWATER_MFX:setVolume(val)
end

function pauseMusic()
    love.audio.pause()
end

function resumeMusic(id)
    playMusic(id)
end

function stopMusic()
    love.audio.stop()
end