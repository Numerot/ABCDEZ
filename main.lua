if arg[2] == "debug" then
    require("lldebugger").start()
end

-- set major variables
Grid = 11
MainWorld = love.physics.newWorld (0, 0, false)
-- create player object
CharA = love.physics.newBody(MainWorld, Grid*3, Grid*2, "dynamic")
-- set window size; resizable, but UI elements may break
Success = love.window.setMode (500, 500, {resizable=true})
-- create BumpMap for collision detection
BumpMap = {}
BumpMapIterator = 0
-- random variables for later use
Time = love.timer.getTime()
MoveTimer = 0
MoveDelay = 0.35
DialogueDelay = 0.3
MoveTimeStamp = love.timer.getTime()
DialogueTimeStamp = love.timer.getTime()
StepSound = love.audio.newSource("step.wav", "static")
ScreenWidth, ScreenHeight = love.graphics.getWidth(), love.graphics.getHeight()
-- dialogue stuff
CurrentDialogue = "Nothing special to comment on in the environment."
DialogueTree = love.filesystem.newFile("DialogueTree.lua")
DialogueTree:open("r")
--dialogueList {}
--for i=0, #TbsLength do
    
--end

-- create dialogue canvas
DialogueCanvas = love.graphics.newCanvas(ScreenWidth, ScreenHeight/3)
-- create UI canvas
UICanvas = love.graphics.newCanvas(ScreenWidth/3, ScreenHeight)

    -- draw coordinates function
    function coDraw(x, y)
        love.graphics.print({x,".",y}, Grid*x, Grid*y, 0, 0.5, 0.5)
    end
    -- specify coordinates to draw
    for i = 0, 100 do
        coDraw (i, i)
        coDraw (i, 0)
        coDraw (0, i)
    end

-- detect if table contains specific XY coordinates; ChatGPT's code
function ContainsXY(tbl, xValue, yValue)
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

function CanMoveTo(x, y)
    for _, obj in ipairs(BumpMap) do
        if obj.X == x and obj.Y == y and obj.Char~=" " then
            return false
        end
    end
    return true
end

-- read, parse and print prefabs
function PrefabPrinter(p, x, y)    
    local a = love.filesystem.newFile(p)
    a:open("r")
    local s = love.filesystem.read(p)
    -- splits the string into individual CharActers
    function StringSplitter(toBeSplit)    
        TbsLength = string.len(toBeSplit)
        local counter = 0
        currentPrefabTable = {}
        -- stores the CharActers into a table; somewhere around here it craps out because it doesn't 
        -- understand spaces from ASCII art made in REXpaint
        for counter = 0, TbsLength do
            currentSymbol = string.sub(toBeSplit, counter, counter)
            currentPrefabTable[counter] = currentSymbol
            counter = counter+1
        end
        local drawX = x
        local drawY = y
        -- love.graphics.print(currentPrefabTable, x, y)
        -- print each CharActer from the table individually
        for counter = 0, #currentPrefabTable do
            -- mark the current XY position on the BumpMap
            BumpMap.BumpMapIterator = {drawX, drawY}    
            BumpMapIterator = BumpMapIterator+1
            -- line break
            if currentPrefabTable[counter] == "\n"
                then
                    drawY = drawY+Grid
                    drawX = x
                end
            love.graphics.print(currentPrefabTable[counter], drawX, drawY)
            --if not currentPrefabTable[counter] == (" ") then
                table.insert(BumpMap, {X=drawX, Y=drawY, Char=currentPrefabTable[counter]})
            --end
            drawX = drawX+Grid
            counter = counter+1
        end
        counter = 0
        Char1 = string.sub(toBeSplit, 1, 1)
    end
    StringSplitter(s)
end

-- graphics
function love.draw()
    -- calculate the camera offset
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local offsetX = windowWidth / 2 - CharA:getX()
    local offsetY = windowHeight / 2 - CharA:getY()
    -- apply the camera translation
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)

    -- draw the scene
    love.graphics.print("A", CharA:getX(), CharA:getY())

    -- draw Kramnik
    KramnikSmall = love.graphics.newImage("kramnikSmall.jpg")
    love.graphics.draw(KramnikSmall, Grid * 25, Grid * 15)
    PrefabPrinter("wideRoom.lua", Grid*0, Grid*0)

    -- reset the translation
    love.graphics.pop()

    -- draw the UI box
    love.graphics.setCanvas(UICanvas)
    love.graphics.clear(0, 0, 0, 0) -- clear previous frame
    love.graphics.setColor(0, 0, 0, 0.95)
    -- draw the black box
    love.graphics.rectangle("fill", 0, 0, ScreenWidth/3, ScreenHeight*2/3)
    love.graphics.setColor(10, 10, 10)
    PrefabPrinter("borderD.lua", 0, 0)
    PrefabPrinter("borderD.lua", 0, ScreenHeight*2/3)
    PrefabPrinter("borderDVert.lua", 0, 0)
    PrefabPrinter("borderDVert.lua", ScreenWidth*2/3-Grid, 0)
    love.graphics.print(CurrentDialogue, ScreenWidth/3, ScreenHeight*1/6)
    -- prefabPrinter could be used to print dialogue, 
    -- but needs to be somehow modified to only print the current line
    --PrefabPrinter("DialogueTree.lua", ScreenWidth/3, ScreenHeight*1/6)  
    love.graphics.setCanvas()
    -- Draw the UI Canvas on the screen; sets the positioning, not size
    love.graphics.draw(UICanvas, ScreenWidth*0.7, 0)


    -- draw the dialogue box
    love.graphics.setCanvas(DialogueCanvas)
    love.graphics.clear(0, 0, 0, 0) -- clear previous frame
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, ScreenWidth, 500)
    love.graphics.setColor(10, 10, 10)
    PrefabPrinter("borderD.lua", 0, 0)
    PrefabPrinter("borderD.lua", 0, DialogueCanvas:getHeight()-10)
    PrefabPrinter("borderDVert.lua", 0, 0)
    PrefabPrinter("borderDVert.lua", ScreenWidth-2*Grid, 0)
    love.graphics.print(CurrentDialogue, ScreenWidth/3, ScreenHeight*1/6)
    -- prefabPrinter could be used to print dialogue, 
    -- but needs to be somehow modified to only print the current line
    --PrefabPrinter("DialogueTree.lua", ScreenWidth/3, ScreenHeight*1/6)  
    love.graphics.setCanvas()
    
    -- Draw the dialogue canvas on the screen
    love.graphics.draw(DialogueCanvas, 0, ScreenHeight*2/3)
end

-- movement
function love.update()
    if love.timer.getTime() > MoveTimeStamp+MoveDelay then
        if love.keyboard.isDown("right") then
            if CanMoveTo(CharA:getX() + Grid, CharA:getY()) then
                CharA:setX(CharA:getX() + Grid)
                love.audio.play(StepSound)
                MoveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("left") then
            if CanMoveTo(CharA:getX() - Grid, CharA:getY()) then
                CharA:setX(CharA:getX() - Grid)
                love.audio.play(StepSound)
                MoveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("up") then
            if CanMoveTo(CharA:getX(), CharA:getY() - Grid) then
                CharA:setY(CharA:getY() - Grid)
                love.audio.play(StepSound)
                MoveTimeStamp = love.timer.getTime()
            end
        end
        if love.keyboard.isDown("down") then
            if CanMoveTo(CharA:getX(), CharA:getY() + Grid) then
                CharA:setY(CharA:getY() + Grid)
                love.audio.play(StepSound)
                MoveTimeStamp = love.timer.getTime()
            end
        end
        if love.timer.getTime() > DialogueTimeStamp+DialogueDelay then
            if love.keyboard.isDown("space") then
                CurrentDialogue = "You pressed space."
                DialogueTimeStamp = love.timer.getTime()
            end
        end
    end
end
