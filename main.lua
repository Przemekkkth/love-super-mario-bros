Concord = require 'libraries.concord'
Object  = require 'libraries.classic'
Input   = require 'libraries.boipushy.Input'
JSON    = require 'libraries.json'
MAX_FPS = 60

function love.load()
    require 'globals'
    require 'assets'
    require 'AABBCollision'
    
    love.filesystem.setIdentity("love_super_mario_bros")
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
    local icon = love.image.newImageData('assets/icon.png')
    love.window.setIcon(icon)
    love.window.setTitle('LÖVE Super Mario Bros by Przemekkkth')

    local object_files = {}
    recursiveEnumerate('objects', object_files)
    requireFiles(object_files)

    local component_files = {}
    recursiveEnumerate('components', component_files)
    requireFiles(component_files)

    local system_files = {}
    recursiveEnumerate('systems', system_files)
    requireFiles(system_files)

    local scene_files = {}
    recursiveEnumerate('scenes', scene_files)
    requireFiles(scene_files)

    input = Input()
    initInput()

    CameraInstance = Camera()
    CommandScheduler = CommandScheduler()
    MapInstance = Map()
    MapInstance:loadBlockIDS()
    MapInstance:loadEnemyIDS()
    MapInstance:loadPlayerIDS()
    MapInstance:loadIrregularBlockReferences()
    setMusicVolume(0.1)
    setSoundVolume(0.1)

    gotoScene('MenuScene')
end

function love.update(dt)
    CurrentScene:update(dt)
    CommandScheduler:run()
    if input:released('MAKE_SCREENSHOT') then
        --Uncomment if you want to make screenshot
        --love.graphics.captureScreenshot(os.time() .. ".png")
    end
end

function love.draw()
    CurrentScene:draw()
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local fileInfo = love.filesystem.getInfo(file)
        if fileInfo.type == "file" then
            table.insert(file_list, file)
        elseif fileInfo.type == "directory" then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function initInput()
    input:bind('d',     'RIGHT')
    input:bind('right', 'RIGHT')
    input:bind('left',  'LEFT')
    input:bind('a',     'LEFT')
    input:bind('s',     'DUCK')
    input:bind('down',  'DUCK')
    input:bind('lshift','Sprint')
    input:bind('q',     'FIREBALL')
    input:bind('space', 'JUMP')
    

    input:bind('right', 'MENU_RIGHT')
    input:bind('left',  'MENU_LEFT')
    input:bind('up',    'MENU_UP')
    input:bind('down',  'MENU_DOWN')
    input:bind('return','MENU_ACCEPT')
    input:bind('escape','MENU_ESCAPE')
    input:bind('escape','PAUSE')

    input:bind('m', 'MAKE_SCREENSHOT')
end

function love.run()

	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0
    local accumulator = 0
    local fixed_dt = 1 / MAX_FPS

	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
		end

		-- Call update and draw
		--if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

		if love.graphics and love.graphics.isActive() then
			love.graphics.clear(love.graphics.getBackgroundColor())
			love.graphics.origin()
			if love.draw then love.draw() end
			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end

end

function gotoScene(name, ...)
    CurrentScene = _G[name](...)
end

function processEntitiesWithComponents(world, requiredComponents, processFunction)
    for _, entity in ipairs(world:getEntities()) do
        local hasAllComponents = true

        for _, component in ipairs(requiredComponents) do
            if not entity:has(component) then
                hasAllComponents = false
                break
            end
        end

        if hasAllComponents then
            processFunction(entity)
        end
    end
end

function generateRandomNumber(min, max)
    return min + math.random() * (max - min)
end

function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
            f(t)
	    seen[t] = true
	    for k,v in pairs(t) do
	        if type(v) == "table" then
		    count_table(v)
	        elseif type(v) == "userdata" then
		    f(v)
	        end
	end
    end
    count_table(_G)
end

function type_count()
    local counts = {}
    local enumerate = function (o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

global_type_table = nil
function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
            for k,v in pairs(_G) do
	        global_type_table[v] = k
	    end
	global_type_table[0] = "table"
    end
    return global_type_table[getmetatable(o) or 0] or "Unknown"
end