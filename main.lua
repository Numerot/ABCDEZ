if arg[2] == "debug" then
    require("lldebugger").start()
end

-- main settings and objects
grid = 11
mainWorld = love.physics.newWorld (0, 0, false)
-- player
charA = love.physics.newBody(mainWorld, grid*5, grid*5, "dynamic")
-- set window size
success = love.window.setMode (250, 250, {resizable=true})


-- RANDOM VARIABLES AND OBJECTS
-- create bumpmap for collision detection
bumpMap = {}
bumpMapIterator = 0

time = love.timer.getTime()
moveTimer = 0
moveTimeStamp = love.timer.getTime()
stepSound = love.audio.newSource("step.wav", "static")

-- detect if table contains specific XY coordinates; ChatGPT's code
function containsXY(tbl, xValue, yValue)
    for _, obj in ipairs(tbl) do
    --for i=0,1000 do
        --if tbl.obj.X == xValue and tbl.obj.Y == yValue then
        --if tbl[i].X == xValue and tbl[i].Y == yValue then
        if obj.X == xValue and obj.Y == yValue then
            return true
        end
    end
    return false
end

function canMoveTo(x, y)
    for _, obj in ipairs(bumpMap) do
        if obj.X == x and obj.Y == y and obj.Char~=" " then
            return false
        end
    end
    return true
end

-- read, parse and print prefabs
function prefabPrinter(p, x, y)    
    local a = love.filesystem.newFile(p)
    a:open("r")
    local s = love.filesystem.read(p)
    -- splits the string into individual characters
    function stringSplitter(toBeSplit)    
        tbsLength = string.len(toBeSplit)
        counter = 0
        currentPrefabTable = {}
        -- stores the characters into a table; somewhere around here it craps out because it doesn't 
        -- understand spaces from ASCII art made in REXpaint
        for counter = 0, tbsLength do
            currentSymbol = string.sub(toBeSplit, counter, counter)
            currentPrefabTable[counter] = currentSymbol
            counter = counter+1
        end
        local drawX = x
        local drawY = y
        -- love.graphics.print(currentPrefabTable, x, y)
        -- print each character from the table individually
        for counter = 0, #currentPrefabTable do
            -- mark the current XY position on the bumpmap
            bumpMap.bumpMapIterator = {drawX, drawY}    
            bumpMapIterator = bumpMapIterator+1
            -- line break
            if currentPrefabTable[counter] == "\n"
                then
                    drawY = drawY+grid
                    drawX = x
                end
            love.graphics.print(currentPrefabTable[counter], drawX, drawY)
            --if not currentPrefabTable[counter] == (" ") then
                table.insert(bumpMap, {X=drawX, Y=drawY, Char=currentPrefabTable[counter]})
            --end
            drawX = drawX+grid
            counter = counter+1
        end
        counter = 0
        Char1 = string.sub(toBeSplit, 1, 1)
    end
    stringSplitter(s)
end

-- graphics
function love.draw()
--    love.graphics.circle("fill", 100, 100, 10)
--    love.graphics.print("asd", 10, 0)
--    love.graphics.print("qwerty", 10, 10)
--    love.graphics.print("A", charA:getX(), charA:getY())
--    love.graphics.print(time, 50, 50)
--    love.graphics.print("_", 200, 200)
--    love.graphics.print("_", 200, 215)
--    love.graphics.print("_", 215, 200)
--    love.graphics.print("_", 215, 215)
--    love.graphics.print("_", 230, 230)
--    love.graphics.print("_", 245, 245)
--    love.graphics.print("_", 260, 260)
--    prefabPrinter("prefab1.lua", 10, 200)
--    prefabPrinter("SEH.lua", grid*10, grid*10)

    --Calculate the camera offset
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local offsetX = windowWidth / 2 - charA:getX()
    local offsetY = windowHeight / 2 - charA:getY()

    --Apply the camera translation
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- Draw the scene
    love.graphics.print("A", charA:getX(), charA:getY())
    -- prefabPrinter("wideRoom.lua", grid * 0, grid * 0)
    --prefabPrinter("prefab1.lua", grid * 12, grid * 7)

    -- draw Kramnik
    kramnikSmall = love.graphics.newImage("kramnikSmall.jpg")
    love.graphics.draw(kramnikSmall, grid * 25, grid * 15)
    prefabPrinter("wideROom.lua", grid*0, grid*0)

    -- draw coordinates function
    function coDraw(x, y)
        love.graphics.print({x,".",y}, grid*x, grid*y, 0, 0.5, 0.5)
    end
    -- specify coordinates to draw
    for i = 0, 100 do
--        coDraw (i, i)
--        coDraw (i, 0)
--        coDraw (0, i)
    end

    -- Reset the translation
    love.graphics.pop()
end

-- movement
function love.update()
    if love.timer.getTime() > moveTimeStamp+0.3 then
        if love.keyboard.isDown("right") then
            if canMoveTo(charA:getX() + grid, charA:getY()) then
                charA:setX(charA:getX() + grid)
                love.audio.play(stepSound)
                moveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("left") then
            if canMoveTo(charA:getX() - grid, charA:getY()) then
                charA:setX(charA:getX() - grid)
                love.audio.play(stepSound)
                moveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("up") then
            if canMoveTo(charA:getX(), charA:getY() - grid) then
                charA:setY(charA:getY() - grid)
                love.audio.play(stepSound)
                moveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("down") then
            if canMoveTo(charA:getX(), charA:getY() + grid) then
                charA:setY(charA:getY() + grid)
                love.audio.play(stepSound)
                moveTimeStamp = love.timer.getTime()
        end
    end
end
end