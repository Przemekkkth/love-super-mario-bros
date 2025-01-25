OptionsSystem = Concord.system()

function OptionsSystem:init(world)
    self.finished = false

    self:createKeyUnderline(world)
    self:createOptionsBackground(world)
    self:createInfoBackground(world)
--LEFT KEY
    self:createLeftTextInfo(world)
--RIGHT KEY
    self:createRightTextInfo(world)
--JUMP KEY
    self:createJumpTextInfo(world)
--DUCK KEY
    self:createDuckTextInfo(world)
--SPRINT KEY
    self:createSprintTextInfo(world)
--FIREBALL KEY
    self:createFireballTextInfo(world)
--MUTE KEY
    self:createMuteText(world)
    self:createGoToBack(world)
end

function OptionsSystem:isFinished()
   return self.finished
end

function OptionsSystem:setFinished(val)
   self.finished = val
end

function OptionsSystem:update()
   self:handleInput()
end

function OptionsSystem:handleInput()
   if not self:isEnabled() then
      return
   end

   if input:pressed('MENU_ESCAPE') then
      self.finished = true
   end
end

function OptionsSystem:createCursor(world)
    local cursor = Concord.entity(world)
    cursor:give('position', {x = 5 * SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
    cursor:give('text', '>', 16)
end

function OptionsSystem:createKeyUnderline(world)
    local keyUnderline = Concord.entity(world)
    keyUnderline:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
    keyUnderline:give('text', '_', 16, false, false)
end

function OptionsSystem:createOptionsBackground(world)
    local optionsBackground = Concord.entity(world)
    optionsBackground:give('position', {x = 4.5 * SCALED_CUBE_SIZE, y = 1.5 * SCALED_CUBE_SIZE}, {x = 16 * SCALED_CUBE_SIZE, y = 12 * SCALED_CUBE_SIZE})
    optionsBackground:give('texture', OPTIONS_BACKGROUND_IMG, false)
    optionsBackground:give('icon')
end

function OptionsSystem:createInfoBackground(world)
    local infoBackground = Concord.entity(world)
    infoBackground:give('position', {x = 5.5 * SCALED_CUBE_SIZE, y = 10 * SCALED_CUBE_SIZE}, {x = 14 * SCALED_CUBE_SIZE, y = 3 * SCALED_CUBE_SIZE})
    infoBackground:give('icon')
end

function OptionsSystem:createLeftTextInfo(world)
    local leftKeybindText = Concord.entity(world)
    leftKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
    leftKeybindText:give('text', 'LEFT KEY:', 16)

    local leftKeyName = Concord.entity(world)
    leftKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 2 * SCALED_CUBE_SIZE})
    leftKeyName:give('text', 'A, <-', 16)
end

function OptionsSystem:createRightTextInfo(world)
    local rightKeybindText = Concord.entity(world)
    rightKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 3 * SCALED_CUBE_SIZE})
    rightKeybindText:give('text', 'RIGHT KEY:', 16)

    local rightKeyName = Concord.entity(world)
    rightKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 3 * SCALED_CUBE_SIZE})
    rightKeyName:give('text', 'D, ->', 16)
end

function OptionsSystem:createJumpTextInfo(world)
    local jumpKeybindText = Concord.entity(world)
    jumpKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 4 * SCALED_CUBE_SIZE})
    jumpKeybindText:give('text', 'JUMP KEY:', 16)

    local jumpKeyName = Concord.entity(world)
    jumpKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 4 * SCALED_CUBE_SIZE})
    jumpKeyName:give('text', 'SPACE', 16)
end

function OptionsSystem:createDuckTextInfo(world)
    local duckKeybindText = Concord.entity(world)
    duckKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 5 * SCALED_CUBE_SIZE})
    duckKeybindText:give('text', 'DUCK KEY:', 16)

    local duckKeyName = Concord.entity(world)
    duckKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 5 * SCALED_CUBE_SIZE})
    duckKeyName:give('text', 'S, down arrow', 16)
end

function OptionsSystem:createSprintTextInfo(world)
    local sprintKeybindText = Concord.entity(world)
    sprintKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 6 * SCALED_CUBE_SIZE})
    sprintKeybindText:give('text', 'SPRINT KEY:', 16)

    local sprintKeyName = Concord.entity(world)
    sprintKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 6 * SCALED_CUBE_SIZE})
    sprintKeyName:give('text', 'Left Shift', 16)
end

function OptionsSystem:createFireballTextInfo(world)
    local fireballKeybindText = Concord.entity(world)
    fireballKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 7 * SCALED_CUBE_SIZE})
    fireballKeybindText:give('text', 'FIREBALL KEY:', 16)

    local fireballKeyName = Concord.entity(world)
    fireballKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 7 * SCALED_CUBE_SIZE})
    fireballKeyName:give('text', 'Q', 16)
end

function OptionsSystem:createMuteText(world)
    local muteKeybindText = Concord.entity(world)
    muteKeybindText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 8 * SCALED_CUBE_SIZE})
    muteKeybindText:give('text', 'TOGGLE MUTE KEY:', 16)

    local muteKeyName = Concord.entity(world)
    muteKeyName:give('position', {x = 14 * SCALED_CUBE_SIZE, y = 8 * SCALED_CUBE_SIZE})
    muteKeyName:give('text', 'M', 16)
end

function OptionsSystem:createGoToBack(world)
    local gobackText = Concord.entity(world)
    gobackText:give('position', {x = 6 * SCALED_CUBE_SIZE, y = 10 * SCALED_CUBE_SIZE})
    gobackText:give('text', 'Go Back: Escape', 16)
end

