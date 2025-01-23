MenuSystem = Concord.system()

function MenuSystem:init(world) --onAddedToWorld(world))
   self.logo = Concord.entity(world)
   self.levelSelectBackground = Concord.entity(world)
   self.aboutText = Concord.entity(world)
   self.selectText = Concord.entity(world)
   self.optionsText = Concord.entity(world)
   self.levelSelectText = Concord.entity(world)
   self.levelNumber = Concord.entity(world)
   self.underline = Concord.entity(world)
   self.cursor = Concord.entity(world)
   self.loveLogo = Concord.entity(world)

   self.levelChange = false
   self.underlineChange = false
   self.levelSelect = false --  // If done selecting a level
   self.selectedLevel = 1
   self.selectedSublevel = 1
   self.maxLevel = 8
   self.maxSublevel = 4
   self.currentFocus = 0       -- 0 is to select, 1 selecting level
   self.currentOption = 0      -- 0 is level select, 1 is options
   self.currentLevelFocus = 0  -- 0 is level, 1 is sublevel
   
   self:createLogo(7 * SCALED_CUBE_SIZE, 2 * SCALED_CUBE_SIZE)
   self:createLevelSelectBackground(5.5 * SCALED_CUBE_SIZE, 9.5 * SCALED_CUBE_SIZE)
   self:createAboutText(5.5 * SCALED_CUBE_SIZE, 8.25 * SCALED_CUBE_SIZE)
   self:createSelectText(9 * SCALED_CUBE_SIZE, 10 * SCALED_CUBE_SIZE)
   self:createOptionsText(9 * SCALED_CUBE_SIZE, 11 * SCALED_CUBE_SIZE)
   self:createLevelSelectText(9.5 * SCALED_CUBE_SIZE, 10 * SCALED_CUBE_SIZE)
   self:createLevelNumber(9.5 * SCALED_CUBE_SIZE, 11 * SCALED_CUBE_SIZE)
   self:createUnderline(9.5 * SCALED_CUBE_SIZE, 11.2 * SCALED_CUBE_SIZE)
   self:createCursor(8 * SCALED_CUBE_SIZE, 10 * SCALED_CUBE_SIZE)
   self:createLoveLogo(13 * SCALED_CUBE_SIZE, 0.5 * SCALED_CUBE_SIZE)
   self:createAvatar(14 * SCALED_CUBE_SIZE, 10 * SCALED_CUBE_SIZE)
end

function MenuSystem:hideMenuText()
   self.cursor.text:setVisible(false)
   self.aboutText.text:setVisible(false)
   self.selectText.text:setVisible(false)
   self.optionsText.text:setVisible(false)
   self.levelSelectText.text:setVisible(false)
   self.levelNumber.text:setVisible(false)
   self.underline.text:setVisible(false)
end

function MenuSystem:showMenuText()
   self.cursor.text:setVisible(true)
   self.aboutText.text:setVisible(true)
   self.selectText.text:setVisible(true)
   self.optionsText.text:setVisible(true)
end

function MenuSystem:getSelectedLevel()
   return self.selectedLevel
end

function MenuSystem:getSelectedSublevel()
   return self.selectedSublevel
end

function MenuSystem:update()
   self:handleInput()
   if self.levelChange then
      self.levelNumber.text.text = tostring(self.selectedLevel)..' - '..tostring(self.selectedSublevel)
      self.levelChange = false
   end


   if self.underlineChange then
      if self.currentLevelFocus == 0 then
         self.underline.position.position.x = 9.5 * SCALED_CUBE_SIZE
      elseif self.currentLevelFocus == 1 then
         self.underline.position.position.x = 11.5 * SCALED_CUBE_SIZE
      end
      self.underlineChange = false
   end
end

function MenuSystem:handleInput()
   if not self:isEnabled() then
      return
   end

   if input:pressed('MENU_ACCEPT') then
      if self.currentFocus == 0 and self.currentOption == 0 then
         self:enterLevelSelect()
      elseif self.currentFocus == 1 then
         self.levelSelect = true
      end
   end

   if input:pressed('MENU_ESCAPE') then
      if self.currentFocus == 1 then
         self:exitLevelSelect()
      end
   end

   if input:pressed('MENU_UP') then
      if self.currentFocus == 0 then
         if self.currentOption > 0 then
            self.currentOption = self.currentOption - 1
            self.cursor.position.position.y = self.cursor.position.position.y - SCALED_CUBE_SIZE
         end
      elseif self.currentFocus == 1 then
         if self.currentLevelFocus == 0 then
            if self.selectedLevel < self.maxLevel then
               self.selectedLevel = self.selectedLevel + 1
               self.levelChange = true
            end
         elseif self.currentLevelFocus == 1 then
            if self.selectedSublevel < self.maxSublevel then
               self.selectedSublevel = self.selectedSublevel + 1
               self.levelChange = true
            end
         end
      end
   end

   if input:pressed('MENU_DOWN') then
      if self.currentFocus == 0 then
         if self.currentOption < 1 then
            self.currentOption = self.currentOption + 1
            self.cursor.position.position.y = self.cursor.position.position.y + SCALED_CUBE_SIZE
         end
      elseif self.currentFocus == 1 then
         if self.currentLevelFocus == 0 then
            if self.selectedLevel > 1 then
               self.selectedLevel = self.selectedLevel - 1
               self.levelChange = true
            end
         elseif self.currentLevelFocus == 1 then
            if self.selectedSublevel > 1 then
               self.selectedSublevel = self.selectedSublevel - 1
               self.levelChange = true
            end
         end
      end
   end

   if input:pressed('MENU_LEFT') then
      if self.currentLevelFocus ~= 0 then   
         self.currentLevelFocus = 0
         self.underlineChange = true
      end
   end

   if input:pressed('MENU_RIGHT') then
      if self.currentLevelFocus ~= 1 then
         self.currentLevelFocus = 1
         self.underlineChange = true
      end
   end
end

function MenuSystem:enterLevelSelect()
   self.currentFocus = 1
   self.levelSelectBackground.texture:setVisible(true)
   self.levelSelectText.text:setVisible(true)
   self.levelNumber.text:setVisible(true)
   self.underline.text:setVisible(true)

   self.cursor.text:setVisible(false)
   self.selectText.text:setVisible(false)
   self.optionsText.text:setVisible(false);
end

function MenuSystem:exitLevelSelect()
   self.currentFocus = 0
   self.levelSelectBackground.texture:setVisible(false)
   self.levelSelectText.text:setVisible(false)
   self.levelNumber.text:setVisible(false)
   self.underline.text:setVisible(false)

   self.cursor.text:setVisible(true)
   self.selectText.text:setVisible(true)
   self.optionsText.text:setVisible(true);
end

function MenuSystem:levelSelected()
   return self.levelSelect and (self.currentFocus == 1)
end

function MenuSystem:optionsSelected()
   return self.currentOption == 1
end

function MenuSystem:createLogo(x, y)
   self.logo:give('position', {x = x, y = y}, {x = 11 * SCALED_CUBE_SIZE, y = 6 * SCALED_CUBE_SIZE} )
   self.logo:give('texture', LOGO_IMG)
   self.logo:give('icon')
end

function MenuSystem:createLevelSelectBackground(x, y)
   self.levelSelectBackground:give('position', {x = x, y = y}, {x = 14 * SCALED_CUBE_SIZE, y = 3 * SCALED_CUBE_SIZE} )
   self.levelSelectBackground:give('texture', OPTIONS_BACKGROUND_IMG, false, false)
   self.levelSelectBackground.texture:setVisible(false)
   self.levelSelectBackground:give('icon')
end

function MenuSystem:createAboutText(x, y)
   self.aboutText:give('position', {x = x, y = y})
   self.aboutText:give('text', 'Recreated by Gold87 using C++ and SDL2\n\n\tPorted to LÖVE by Przemekkkth', 12)
end

function MenuSystem:createSelectText(x, y)
   self.selectText:give('position', {x = x, y = y})
   self.selectText:give('text', 'Level Select', 15)
end

function MenuSystem:createOptionsText(x, y)
   self.optionsText:give('position', {x = x, y = y})
   self.optionsText:give('text', 'Options', 15)
end   

function MenuSystem:createLevelSelectText(x, y)
   self.levelSelectText:give('position', {x = 9.5 * SCALED_CUBE_SIZE, y = 10 * SCALED_CUBE_SIZE})
   self.levelSelectText:give('text', 'Select a Level', 15, false, false)
end

function MenuSystem:createLevelNumber(x, y)
   self.levelNumber:give('position', {x = x, y = y})
   self.levelNumber:give('text', tonumber(self.selectedLevel)..' - '..tonumber(self.selectedSublevel), 15, false, false)
end

function MenuSystem:createUnderline(x, y)
   self.underline:give('position', {x = x, y = y})
   self.underline:give('text', '_', 15, false, false)
end

function MenuSystem:createCursor(x, y)
   self.cursor:give('position', {x = x, y = y})
   self.cursor:give('text', '>', 15)
end

function MenuSystem:createLoveLogo(x, y)
   self.loveLogo:give('position', {x = x, y = y}, {x = 4*SCALED_CUBE_SIZE, y = 4*SCALED_CUBE_SIZE})
   self.loveLogo:give('texture', LOVE_LOGO_IMG)
   self.loveLogo:give('icon')
end

function MenuSystem:createAvatar(x, y)
   local avatar = Concord.entity(self:getWorld())
   avatar:give('position', {x = x, y = y}, {x = 118, y = 118})
   avatar:give('texture', AVATAR_IMG)
   avatar:give('icon')
end