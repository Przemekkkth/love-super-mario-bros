Level = Object:extend()

Level.directionMap = {
    {'NONE' , DIRECTION.NONE},
    {'UP', DIRECTION.UP},
    {'DOWN', DIRECTION.DOWN},
    {'LEFT', DIRECTION.LEFT},
    {'RIGHT', DIRECTION.RIGHT}
}

Level.backgroundColorMap = {
    {"BLACK", BACKGROUND_COLOR_BLACK},
    {"BLUE", BACKGROUND_COLOR_BLUE}
}

Level.levelTypeMap = {
    {'NONE', LEVEL_TYPE.NONE},
    {'OVERWORLD', LEVEL_TYPE.OVERWORLD},
    {'UNDERGROUND', LEVEL_TYPE.UNDERGROUND},
    {'UNDERWATER', LEVEL_TYPE.UNDERWATER},
    {'CASTLE', LEVEL_TYPE.CASTLE},
    {'START_UNDERGROUND', LEVEL_TYPE.START_UNDERGROUND}
}

Level.motionTypeMap = {
    {'NONE', PLATFORM_MOTION_TYPE.NONE},
    {'ONE_DIRECTION_REPEATED', PLATFORM_MOTION_TYPE.ONE_DIRECTION_REPEATED},
    {'ONE_DIRECTION_CONTINUOUS', PLATFORM_MOTION_TYPE.ONE_DIRECTION_CONTINUOUS},
    {'BACK_AND_FORTH', PLATFORM_MOTION_TYPE.BACK_AND_FORTH},
    {'GRAVITY', PLATFORM_MOTION_TYPE.GRAVITY}
}

Level.rotationTypeMap = {
    {'NONE', ROTATION_DIRECTION.NONE},
    {'CLOCKWISE', ROTATION_DIRECTION.CLOCKWISE},
    {'COUNTER_CLOCKWISE', ROTATION_DIRECTION.COUNTER_CLOCKWISE}
}

function Level:new()
    self.data = LevelData()
end

function Level:loadLevelData(levelProperties) -- levelProperties => JSON object
    local object = JSON.decode(levelProperties)
    self.data:setPlayerStart({x = object.PLAYER_START[1], y = object.PLAYER_START[2]})
    self.data:setLevelType(object.LEVEL_TYPE)
    self.data:setCameraStart({x = object.CAMERA_START[1], y = object.CAMERA_START[2]})
    self.data:setCameraMax(object.CAMERA_MAX)
    self.data:setBackgroundColor(object.BACKGROUND_COLOR)
    self.data:setNextLevel({x = object.NEXT_LEVEL[1], y = object.NEXT_LEVEL[2]})
    self.data:setFloatingTextLocations(object.FLOATING_TEXT)
    self.data:setWarpPipeLocation(object.WARP_PIPE)
    self.data:setMovingPlatformDirections(object.MOVING_PLATFORM)
    self.data:setPlatformLevelLocations(object.PLATFORM_LEVEL)
    self.data:serFireBarLocations(object.FIRE_BAR)
    self.data:setVineLocations(object.VINE)
end

function Level:getData()
    return self.data
end

function Level:convertDirectionTextToType(val)
    for key, value in ipairs(Level.directionMap) do
        if value[1] == val then
            return value[2]
        end
    end

    return val
end

function Level:convertBGColorTextToType(val)
    for key, value in ipairs(Level.backgroundColorMap) do
        if value[1] == val then
            return value[2]
        end
    end

    return val
end

function Level:convertLevelTextToType(val)
    for key, value in ipairs(Level.levelTypeMap) do
        if value[1] == val then
            return value[2]
        end
    end

    return val
end


function Level:convertMotionTextToType(val)
    for key, value in ipairs(Level.motionTypeMap) do
        if value[1] == val then
            return value[2]
        end
    end

    return val
end

function Level:convertRotationTextToType(val)
    for key, value in ipairs(Level.rotationTypeMap) do
        if value[1] == val then
            return value[2]
        end
    end

    return val
end