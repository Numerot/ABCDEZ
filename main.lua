if arg[2] == "debug" then
    require("lldebugger").start()
end

-- random variables and objects
time = love.timer.getTime()
moveTimer = 0
love.graphics.scale(10, 10)
charSpeed = 15
mainWorld = love.physics.newWorld (0, 0, false)
charA = love.physics.newBody(mainWorld, 200, 200, "dynamic")
moveTimeStamp = love.timer.getTime()

-- read, parse and print prefabs
prefabPrinter = function (p, x, y)    
    local a = love.filesystem.newFile(p)
    a:open("r")
    local s = love.filesystem.read(p)
    -- splits the string into individual characters
    stringSplitter = function (toBeSplit)    
        tbsLength = string.len(toBeSplit)
        counter = 0
        currentPrefabTable = {}
        -- stores each value in turn into a table
        for counter = 0, tbsLength do
            currentSymbol = string.sub(toBeSplit, counter, counter)
            if currentSymbol == " " then
                currentSymbol = "-"
            end
            currentPrefabTable[counter] = currentSymbol
            counter = counter+1
        end
        local drawx = 15
        local drawy = 15
        love.graphics.print(currentPrefabTable, x, y)
        counter = 0
        Char1 = string.sub(toBeSplit, 1, 1)
    end
    stringSplitter(s)
end

local function gridConverter()
    love.graphics.print("asd", 100, 100)
end

-- graphics
function love.draw()
    love.graphics.circle("fill", 100, 100, 10)
    love.graphics.print("asd", 10, 0)
    love.graphics.print("qwerty", 10, 10)
    love.graphics.print("A", charA:getX(), charA:getY())
    love.graphics.print(time, 50, 50)
    love.graphics.print("_", 200, 200)
    love.graphics.print("_", 200, 215)
    love.graphics.print("_", 215, 200)
    love.graphics.print("_", 215, 215)
    love.graphics.print("_", 230, 230)
    love.graphics.print("_", 245, 245)
    love.graphics.print("_", 260, 260)
    prefabPrinter("prefab1.lua", 10, 200)
    prefabPrinter("SEH.lua", 500, 10)
end

-- movement
function love.update()
    if love.timer.getTime() > moveTimeStamp+0.3 then
        if love.keyboard.isDown("right") then
            charA:setX(charA:getX() + charSpeed)
            moveTimeStamp = love.timer.getTime()
        end
        if love.keyboard.isDown("left") then
            charA:setX(charA:getX() - charSpeed)
            moveTimeStamp = love.timer.getTime()
        end
        if love.keyboard.isDown("up") then
            charA:setY(charA:getY() - charSpeed)
            moveTimeStamp = love.timer.getTime()
        end
        if love.keyboard.isDown("down") then
            charA:setY(charA:getY() + charSpeed)
            moveTimeStamp = love.timer.getTime()
        end
    end
end