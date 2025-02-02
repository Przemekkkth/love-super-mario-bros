FlagSystem = Concord.system()
FlagSystem.climbing = false
FlagSystem.inSequence = false

function FlagSystem:init(world) --onAddedToWorld(world))
    self.inSequence = false
end

function FlagSystem:update()
   if not self:isEnabled() then
      return
   end
   
   local world = self:getWorld()
   for _, entity in ipairs(world:getEntities()) do
      if entity:has('flag_pole_component') then
         local player = world:getSystem(PlayerSystem):getMario()
   
         if not AABBTotalCollision(entity.position, player.position) or FlagSystem:isClimbing() then
            --pass
         else
            local flag
            for _, e in ipairs(world:getEntities()) do
               if e:has('flag_component') then
                  flag = e
                  break
               end
            end
      
            self:climbFlag(player, flag)
         end
      end

      if entity:has('axe_component') then
         local player = world:getSystem(PlayerSystem):getMario()
   
         if not AABBTotalCollision(entity.position, player.position) then
            break
         end
         self:hitAxe(player, entity)
      end
   end
end

function FlagSystem:setClimbing(val) -- static
   FlagSystem.climbing = val 
end

function FlagSystem:isClimbing() -- static
    return FlagSystem.climbing
end

function FlagSystem:climbFlag(player, flag)
    local world = self:getWorld() 
    if self.inSequence then
        return
    end

    local playerMove = player.moving_component
    local playerPosition = player.position
    local flagMove = flag.moving_component

    PlayerSystem:enableInput(false)
    FlagSystem:setClimbing(true)

    playerPosition:setLeft( flag.position:getLeft())

    playerMove.velocity.x = 0
    playerMove.acceleration.x = 0
    playerMove.acceleration.y = 0
    playerMove.velocity.y = 4
    flagMove.velocity.y = 4

    self.scene:stopTimer()
    self.scene:stopMusic()

    local flagSound = Concord.entity(world)
    flagSound:give('sound_component', SOUND_ID.FLAG_RAISE)

    player:remove('gravity_component')
    player:give('friction_exempt_component')
    self.inSequence = true
    self.nextLevelDelay = 4.5 * MAX_FPS
    CommandScheduler:addCommand( SequenceCommand({
        --Move to the other side of the flag
        WaitUntilCommand(function() return player:has('bottom_collision_component') and flag:has('bottom_collision_component') end),
        --
        RunCommand(function()
          playerMove.velocity.y = 0
          flagMove.velocity.y = 0 
          player.texture:setHorizontalFlipped(true)
          playerPosition.position.x = playerPosition.position.x + 34
        end),
        --
        WaitCommand(0.6),
        -- Move towards the castle
        RunCommand(function() 
         FlagSystem:setClimbing(false)
         CameraInstance:setCameraFrozen(false)
         player:give('gravity_component')
         playerMove.velocity.x = 2.0
         player.texture:setHorizontalFlipped(false)
        end),
        -- Wait until the player hits a solid block
        WaitUntilCommand(function() return player:has('right_collision_component') end),
        WaitUntilCommand(function()
            if self.nextLevelDelay > 0 then
               self.nextLevelDelay = self.nextLevelDelay - 1
            end
            self.scene:scoreCountdown()
            if self.scene:scoreCountdownFinished() and self.nextLevelDelay <= 0 then
               return true
            end
            return false
        end),
        RunCommand(function()
            local nextLevel = self.scene:getLevelData().nextLevel
            player.texture:setVisible(false)
            self.inSequence = false
            CommandScheduler:addCommand(DelayedCommand(function() self.scene:switchLevel(nextLevel.x, nextLevel.y) end, 2))
        end)
    }))
end

function FlagSystem:setScene(scene)
    self.scene = scene
end

function FlagSystem:hitAxe(player, axe)
   -- TO DO
   local world = self:getWorld()
   if FlagSystem.inSequence then
      return
   end

   PlayerSystem:enableInput(false)

   local playerMove = player.moving_component
   playerMove.velocity.x = 0
   playerMove.velocity.y = 0
   playerMove.acceleration.x = 0
   playerMove.acceleration.y = 0
   self.scene:stopTimer()
   self.scene:stopMusic()

   player:remove('gravity_component')
   player:give('friction_exempt_component')
   player:give('frozen_component')

   FlagSystem.inSequence = true
   local bridgeChain
   for _, entity in ipairs(world:getEntities()) do
      if entity:has('bridge_chain') then
         bridgeChain = entity
         break
      end
   end

   world:removeEntity(bridgeChain)

   local bowser
   for _, entity in ipairs(world:getEntities()) do
      if entity:has('bowser_component') then
         bowser = entity
         break
      end
   end

   bowser:give('frozen_component')

   local bridge
   for _, entity in ipairs(world:getEntities()) do
      if entity:has('bridge_component') then
         bridge = entity
         break
      end
   end

   bridge:give('timer_component', 
   function(entity)
      local bridgeComponent = entity.bridge_component
      bridgeComponent.connectedBridgeParts[#bridgeComponent.connectedBridgeParts]:give('destroy_delayed_component', 1)
      table.remove(bridgeComponent.connectedBridgeParts, #bridgeComponent.connectedBridgeParts)

      local bridgeCollapseSound = Concord.entity(world)
      bridgeCollapseSound:give('sound_component', SOUND_ID.BLOCK_BREAK)

      if #bridgeComponent.connectedBridgeParts == 0 then
         entity:remove('timer_component')
      end
   end, 5)

   CommandScheduler:addCommand(SequenceCommand({
      WaitUntilCommand(function() return not bridge:has('timer_component') end),
      RunCommand(
         function()
            bowser:remove('frozen_component')
            bowser:give('dead_component')
            local bowserFall = Concord.entity(world)
            bowserFall:give('sound_component', SOUND_ID.BOWSER_FALL)
         end
      ),
      -- Wait until bowser is not visible in the camera, then destroy the axe and move the player
      WaitUntilCommand(function() return not CameraInstance:inCameraRange(bowser.position) end),
      RunCommand(function()
         -- Play the castle clear sound in 0.325 seconds, this is separate from the sequence to
         -- avoid sequence interruption
         CommandScheduler:addCommand(
            DelayedCommand(
               function() 
                  local castleClear = Concord.entity(world)
                  castleClear:give('sound_component', SOUND_ID.CASTLE_CLEAR)
               end, 0.325))
         
         world:removeEntity(axe)
         playerMove.velocity.x = 3
         player:give('gravity_component')
         player:remove('frozen_component')
      end),
      -- Play the castle clear sound in 0.325 seconds, this is separate from the sequence to
      -- avoid sequence interruption
      WaitUntilCommand(function() return player:has('right_collision_component') end),
      RunCommand(function()
         FlagSystem.inSequence = false
         CommandScheduler:addCommand(DelayedCommand(
            function() 
               local nextLevel = self.scene:getLevelData().nextLevel
            
               if nextLevel.x ~= 0 and nextLevel.y ~= 0 then
                  player.texture:setVisible(false)
               else
                  local winMusic = Concord.entity(world)
                  winMusic:give('music_component', MUSIC_ID.GAME_WON)
               end
               self.scene:switchLevel(nextLevel.x, nextLevel.y)
            end, 5.0))
      end)
   }))
end

