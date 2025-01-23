AnimationSystem = Concord.system()

function AnimationSystem:init(world) --onAddedToWorld(world))
end

function AnimationSystem:update()
    if not self:isEnabled() then
        return
    end

    local world = self:getWorld()
    for _, entity in ipairs(world:getEntities()) do
        if entity:has('ending_blink_component') and entity:has('ending_blink_component') then
            local blink = entity.ending_blink_component
            blink.current = blink.current + 1
            blink.time = blink.time - 1
    
            if (blink.current / blink.blinkSpeed) % 2 == 1 then
                entity.texture:setVisible(false)
            else
                entity.texture:setVisible(true)
            end
    
            if blink.time == 0 then
                entity:remove('ending_blink_component')
                entity.texture:setVisible(true)
            end
        end

        if entity:has('animation_component') and entity:has('texture') and entity:has('spritesheet') and entity:has('position') then
            if ((not CameraInstance:inCameraRange(entity.position)) and (not entity:has('icon'))) or entity:has('pause_animation_component') then
            else
                local animation = entity.animation_component
                local spritesheet = entity.spritesheet
        
                animation.frameTimer = animation.frameTimer - 1
                if animation.frameTimer <= 0 and animation.playing then
                    animation.frameTimer = animation.frameDelay
                    animation.currentFrame = animation.currentFrame + 1
        
                    if animation.currentFrame > animation.frameCount then
                        if animation.repeated then
                            animation.currentFrame = 1
                        else
                            entity:remove('animation_component')
                            break
                        end
                    end
                end
        
                local animationFrameID = animation.frameIDs[animation.currentFrame]
                local frameCoordinates = animation.coordinateSupplier[animationFrameID]
                if frameCoordinates then
                    spritesheet:setSpritesheetCoordinates(frameCoordinates)
                end
            end
        end


        if entity:has('pause_animation_component') and entity:has('animation_component') and entity:has('texture') and entity:has('spritesheet') and entity:has('position') then
            if (not CameraInstance:inCameraRange(entity.position) and not entity:has('icon') ) then
                
            else
                local animation = entity.animation_component
                local spritesheet = entity.spritesheet
                local pause = entity.pause_animation_component

                --If it is playing then it increases the frame, and it also checks if it should pause
                if animation.playing then
                    animation.frameTimer = animation.frameTimer - 1

                    if animation.frameTimer <= 0 then
                        animation.frameTimer = animation.frameDelay
                        animation.currentFrame = animation.currentFrame + 1

                        if animation.currentFrame >= animation.frameCount then
                            if animation.repeated then
                                animation.currentFrame = 1
                            else
                                local animationFrameID = animation.frameIDS[animation.currentFrame]
                                local frameCoordinates = animation.coordinateSupplier[animationFrameID]

                                -- Sets the texture sprite sheets coordinates to the animation frame
                                -- coordinates
                                spritesheet:setSpritesheetCoordinates(frameCoordinates)
                                entity:remove('animation_component')
                                break
                            end
                        end

                        if animation.currentFrame == pause.frame then
                            pause:pause(pause.length)
                            animation.playing = false
                        end
                    end
                else
                    pause.timer = pause.timer - 1
                    if pause.timer == 0 then
                        animation.playing = true
                    end
                end

                local animationFrameID = animation.frameIDs[animation.currentFrame]
                local frameCoordinates = animation.coordinateSupplier[animationFrameID]
                spritesheet:setSpritesheetCoordinates(frameCoordinates)
            end
        end
        
    end
end