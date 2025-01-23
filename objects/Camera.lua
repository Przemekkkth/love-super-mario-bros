Camera = Object:extend()

function Camera:new()
    self.cameraX = 0.0
    self.cameraY = 0.0
    self.cameraMinX = 0.0
    self.cameraMaxX = 0.0
    self.frozen = false
end

function Camera:setCameraX(val)
    self.cameraX = val
end

function Camera:setCameraY(val)
    self.cameraY = val
end

function Camera:increaseCameraX(val)
    self.cameraX = self.cameraX + val
end
 
function Camera:updateCameraMin()
    self.cameraMinX = self.cameraX
end
 
function Camera:setCameraLeft(val)
    self.cameraMinX = val
end
 
function Camera:setCameraRight(val)
    self:setCameraX(val - SCREEN_WIDTH)
end

function Camera:setCameraFrozen(val)
    self.frozen = val
end
 
function Camera:setCameraMinX(val) 
    self.cameraMinX = val
end
 
function Camera:setCameraMaxX(val) 
    self.cameraMaxX = val
end
 
function Camera:getCameraX() 
    return self.cameraX
end

function Camera:getCameraY() 
    return self.cameraY
end
 
function Camera:getCameraCenterX() 
    return self:getCameraX() + (SCREEN_WIDTH / 2)
end

function Camera:getCameraCenterY() 
    return self:getCameraY() + (SCREEN_HEIGHT / 2)
end

function Camera:getCameraLeft()
    return self:getCameraX()
end

function Camera:getCameraRight()
    return self:getCameraX() + SCREEN_WIDTH
end
 
function Camera:getCameraMinX()
    return self.cameraMinX
end

function Camera:getCameraMaxX()
    return self.cameraMaxX
end

function Camera:isFrozen()
    return self.frozen
end

function Camera:inCameraRange(position)
    return self:inCameraXRange(position) and self:inCameraYRange(position)
end
 
function Camera:inCameraXRange(position)
    return position.position.x + position.scale.x >= self:getCameraX() and
    position.position.x <= self:getCameraX() + SCREEN_WIDTH
end

function Camera:inCameraYRange(position)
    return position.position.y + position.scale.y >= self:getCameraY() and
           position.position.y <= self:getCameraY() + SCREEN_HEIGHT
end
