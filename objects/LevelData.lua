LevelData = Object:extend()

function LevelData:new()
    self.playerStart   = {x = 0, y = 0}
    self.levelType     = LEVEL_TYPE.NONE
    self.cameraStart   = {x = 0, y = 0}
    self.backgroundColor = BACKGROUND_COLOR_BLACK
    self.cameraMax = 0
    self.nextLevel  = {x = 0, y = 0}
    self.teleportPoints = {}
    --Vector2i, Vector2i, Vector2i, Direction, Direction, bool, BackgroundColor, LevelType, Vector2i
    self.warpPipeLocation = {}

    --Vector2i, PlatformMotionType, Direction, Vector2i, bool
    self.movingPlatformDirections = {}

    --Vector2i, Vector2i, int
    self.platformLevelLocations = {}

    --Vector2i, int, RotationDirection, int
    self.fireBarLocations = {}

    --Vector2i, Vector2i, Vector2i, int, Vector2i, int, BackgroundColor, LevelType
    --
    self.vineLocations = {}

    --Vector2i, string
    self.floatingTextLocations = {}
end

function LevelData:destroy()
    self.playerStart   = nil
    self.levelType     = nil
    self.cameraStart   = nil
    self.backgroundColor = nil
    self.cameraMax = nil
    self.nextLevel  = nil
    self.teleportPoints = nil
    --Vector2i, Vector2i, Vector2i, Direction, Direction, bool, BackgroundColor, LevelType, Vector2i
    self.warpPipeLocation = nil

    --Vector2i, PlatformMotionType, Direction, Vector2i, bool
    self.movingPlatformDirections = nil

    --Vector2i, Vector2i, int
    self.platformLevelLocations = nil

    --Vector2i, int, RotationDirection, int
    self.fireBarLocations = nil

    --Vector2i, Vector2i, Vector2i, int, Vector2i, int, BackgroundColor, LevelType
    --
    self.vineLocations = nil

    --Vector2i, string
    self.floatingTextLocations = nil
end

function LevelData:setPlayerStart(pos)
    self.playerStart = pos
end

function LevelData:setLevelType(type)
    if type == 'OVERWORLD' then
        self.levelType = LEVEL_TYPE.OVERWORLD
    elseif type == 'UNDERGROUND' then
        self.levelType = LEVEL_TYPE.UNDERGROUND
    elseif type == 'UNDERWATER' then
        self.levelType = LEVEL_TYPE.UNDERWATER
    elseif type == 'CASTLE' then
        self.levelType = LEVEL_TYPE.CASTLE
    elseif type == 'START_UNDERGROUND' then
        self.levelType = LEVEL_TYPE.START_UNDERGROUND
    else
        error('No found: '..type..' level type.')
    end
end

function LevelData:getLevelType()
    return self.levelType
end

function LevelData:setCameraStart(pos)
    self.cameraStart = pos
end

function LevelData:setBackgroundColor(color)
    if color == 'BLACK' then
        self.backgroundColor = BACKGROUND_COLOR_BLACK
    elseif color == 'BLUE' then
        self.backgroundColor = BACKGROUND_COLOR_BLUE
    end
end

function LevelData:setCameraMax(max)
    self.cameraMax = max
end

function LevelData:getCameraMax()
    return self.cameraMax
end

function LevelData:setNextLevel(pos)
    self.nextLevel = pos
end

function LevelData:floatingTextLocations()
    return self.floatingTextLocations
end

function LevelData:setFloatingTextLocations(val)
    self.floatingTextLocations = val
end

function LevelData:warpPipeLocation()
    return self.warpPipeLocation
end

function LevelData:setWarpPipeLocation(val)
    self.warpPipeLocation = val
end

function LevelData:movingPlatformDirections()
    return self.movingPlatformDirections
end

function LevelData:setMovingPlatformDirections(val)
    self.movingPlatformDirections = val
end

function LevelData:platformLevelLocations()
    return self.platformLevelLocations
end

function LevelData:setPlatformLevelLocations(val)
    self.platformLevelLocations = val
end

function LevelData:fireBarLocations()
    return self.fireBarLocations
end

function LevelData:serFireBarLocations(val)
    self.fireBarLocations = val
end

function LevelData:vineLocations()
    return self.vineLocations
end

function LevelData:setVineLocations(val)
    self.vineLocations = val
end

function LevelData:clearData()
    self.playerStart   = {x = 0, y = 0}
    self.levelType     = LEVEL_TYPE.NONE
    self.cameraStart   = {x = 0, y = 0}
    self.backgroundColor = BACKGROUND_COLOR_BLACK
    self.cameraMax = 0
    self.nextLevel  = {x = 0, y = 0}
    self.teleportPoints = {}
    --Vector2i, Vector2i, Vector2i, Direction, Direction, bool, BackgroundColor, LevelType, Vector2i
    self.warpPipeLocation = {}

    --Vector2i, PlatformMotionType, Direction, Vector2i, bool
    self.movingPlatformDirections = {}

    --Vector2i, Vector2i, int
    self.platformLevelLocations = {}

    --Vector2i, int, RotationDirection, int
    self.fireBarLocations = {}

    --Vector2i, Vector2i, Vector2i, int, Vector2i, int, BackgroundColor, LevelType
    self.vineLocations = {}

    --Vector2i, string
    self.floatingTextLocations = {}
end