if arg[2] == "debug" then
    require("lldebugger").start()
end

-- main settings and objects
grid = 11
mainWorld = love.physics.newWorld (0, 0, false)
-- player
charA = love.physics.newBody(mainWorld, grid*3, grid*2, "dynamic")
-- set window size
success = love.window.setMode (500, 500, {resizable=true})

-- RANDOM VARIABLES AND OBJECTS
-- create bumpmap for collision detection
bumpMap = {}
bumpMapIterator = 0

time = love.timer.getTime()
moveTimer = 0
moveTimeStamp = love.timer.getTime()
dialogueTimeStamp = love.timer.getTime()
stepSound = love.audio.newSource("step.wav", "static")
screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
currentDialogue = "Nothing special to comment on in the environment."

dialogueTree = love.filesystem.newFile("dialogueTree.lua")
dialogueTree:open("r")
--dialogueList {}
--for i=0, #tbsLength do
    
--end

local uiCanvas = love.graphics.newCanvas(screenWidth, screenHeight/3)

    -- draw coordinates function
    function coDraw(x, y)
        love.graphics.print({x,".",y}, grid*x, grid*y, 0, 0.5, 0.5)
    end
    -- specify coordinates to draw
    for i = 0, 100 do
        coDraw (i, i)
        coDraw (i, 0)
        coDraw (0, i)
    end

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
    -- calculate the camera offset
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local offsetX = windowWidth / 2 - charA:getX()
    local offsetY = windowHeight / 2 - charA:getY()
    -- apply the camera translation
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- draw the scene
    love.graphics.print("A", charA:getX(), charA:getY())

    -- draw Kramnik
    kramnikSmall = love.graphics.newImage("kramnikSmall.jpg")
    love.graphics.draw(kramnikSmall, grid * 25, grid * 15)
    prefabPrinter("wideRoom.lua", grid*0, grid*0)

    -- reset the translation
    love.graphics.pop()

    love.graphics.setCanvas(uiCanvas)
    love.graphics.clear(0, 0, 0, 0) -- clear previous frame
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, 1000, 1000)
    love.graphics.setColor(10, 10, 10)
    prefabPrinter("borderD.lua", 0, screenHeight*2/3)
    prefabPrinter("borderD.lua", 0, screenHeight-30)
    prefabPrinter("borderDVert.lua", screenWidth+30, 0)
    prefabPrinter("borderDVert.lua", screenWidth-10, 0)
    love.graphics.print(currentDialogue, screenWidth/3, 50)
    love.graphics.setCanvas()
    
    -- Draw the UI Canvas on the screen
    love.graphics.draw(uiCanvas, 0, screenHeight*2/3)
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
        if love.timer.getTime() > dialogueTimeStamp+0.3 then
            if love.keyboard.isDown("space") then
                currentDialogue = "You pressed space."
                dialogueTimeStamp = love.timer.getTime()
            end
        end
    end
end
