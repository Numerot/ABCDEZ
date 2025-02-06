if arg[2] == "debug" then
    require("lldebugger").start()
end

-- set major variables
Grid = 11
MainWorld = love.physics.newWorld (0, 0, false)
-- create player object
CharA = love.physics.newBody(MainWorld, Grid*17, Grid*17, "dynamic")
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
-- UI stuff
UIList = {}
table.insert(UIList, "INSPECT")
table.insert(UIList, "USE")
table.insert(UIList, "TALK")
table.insert(UIList, "TAKE")
table.insert(UIList, "BREAK")
table.insert(UIList, "LISTEN")

-- create room playlist
RoomList = {}
table.insert(RoomList, "Aroom.lua")
table.insert(RoomList, "Hallway1.lua")
table.insert(RoomList, "HallwayZ.lua")

CurrentRoom = 1

function ChangeRoom (x, y, ax, ay)
    BumpMap = {}
    PrefabPrinter(CurrentRoom, Grid*x, Grid*y)
    CharA:setX(Grid*ax)
    CharA:setX(Grid*ay)
end

Hallway1 = love.filesystem.newFile("Hallway1.lua")
Hallway1:open("r")

HallwayZ = love.filesystem.newFile("HallwayZ")
HallwayZ:open("r")

--for i=0, #RoomList do
--    DialogueTree = love.filesystem.newFile("DialogueTree.lua")
--    DialogueTree:open("r")
--end

CurrentRoom = RoomList[1]
RoomListCounter = 1

-- dialogue stuff
CurrentDialogue = "Nothing special to comment on in the environment."
DialogueTree = love.filesystem.newFile("DialogueTree.lua")
DialogueTree:open("r")
DialogueTree = love.filesystem.read("DialogueTree.lua")
DialogueIndex = 1

function LineSplitter(s)
    local lines = {}
    local i = 1
    s:gsub("([^\r\n]+)", function(line)
        table.insert(lines, line)
    end)
    return lines
end

DialogueList = LineSplitter(DialogueTree)
CurrentDialogueList = DialogueList

--for w in DialogueTree:gmatch("([^;]*)") do table.insert(DialogueList, w) end
--for i=0, #TbsLength do

-- create map canvas
MapCanvas = love.graphics.newCanvas(ScreenWidth*2/3, ScreenHeight*2/3)

-- create dialogue canvas
DialogueCanvas = love.graphics.newCanvas(ScreenWidth, ScreenHeight/3)
-- create UI canvas
UICanvas = love.graphics.newCanvas(ScreenWidth/3, ScreenHeight)

    -- draw coordinates function
    function CoDraw(x, y)
        love.graphics.print({x,".",y}, Grid*x, Grid*y, 0, 0.5, 0.5)
    end
    -- specify coordinates to draw
    for i = 0, 100 do
        CoDraw (i, i)
        CoDraw (i, 0)
        CoDraw (0, i)
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

function MoveToNextRoom (x, y)
    for _, obj in ipairs(BumpMap) do
        if obj.X == x and obj.Y == y and obj.Char == ";" then
            return true
        end
    end
    return false
end

-- read, parse and print prefabs
function PrefabPrinter(p, x, y)    
    -- open the file and and store it as a string in the s variable
    local a = love.filesystem.newFile(p)
    a:open("r")
    local s = love.filesystem.read(p)
    -- splits the string into individual CharActers
    function StringSplitter(toBeSplit)    
        TbsLength = string.len(toBeSplit)
        local counter = 0
        local currentPrefabTable = {}
        -- stores the characters into a table; somewhere around here it craps out because it doesn't 
        -- understand spaces from ASCII art made in REXpaint
        for counter = 0, TbsLength do
            CurrentSymbol = string.sub(toBeSplit, counter, counter)
            currentPrefabTable[counter] = CurrentSymbol
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
    love.graphics.setCanvas(MapCanvas)
    love.graphics.clear(0, 0, 0, 0) -- clear previous frame
--    love.graphics.setColor(0, 0, 0, 0.95)

    -- calculate the camera offset
--    local windowWidth, windowHeight = love.graphics.getDimensions()
--    local offsetX = windowWidth / 2 - CharA:getX()
--    local offsetY = windowHeight / 2 - CharA:getY()
    -- apply the camera translation
--    love.graphics.push()
--    love.graphics.translate(offsetX, offsetY)

    -- draw the scene
    love.graphics.print("A", CharA:getX(), CharA:getY())

    -- draw Kramnik
    --KramnikSmall = love.graphics.newImage("kramnikSmall.jpg")
    --love.graphics.draw(KramnikSmall, Grid * 25, Grid * 15)

    --draw current room
    PrefabPrinter(CurrentRoom, Grid*7, Grid*7)

    love.graphics.setCanvas() --for some reason included in the other canvases

    love.graphics.draw(MapCanvas, 0, 0)

    -- reset the translation
--    love.graphics.pop()

    

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
    for i = 1, #UIList do
        love.graphics.print(UIList[i], Grid*3, Grid*(2+i))
    end

    love.graphics.setCanvas()
    -- draw the UI Canvas on the screen; sets the positioning, not size
    love.graphics.draw(UICanvas, ScreenWidth*0.7, 0)


    -- draw the dialogue canvas
    love.graphics.setCanvas(DialogueCanvas)
    love.graphics.clear(0, 0, 0, 0) -- clear previous frame
    love.graphics.setColor(0, 0, 0, 0.95)
    love.graphics.rectangle("fill", 0, 0, ScreenWidth, 500)
    love.graphics.setColor(10, 10, 10)
    PrefabPrinter("borderD.lua", 0, 0)
    PrefabPrinter("borderD.lua", 0, DialogueCanvas:getHeight()-10)
    PrefabPrinter("borderDVert.lua", 0, 0)
    PrefabPrinter("borderDVert.lua", ScreenWidth-2*Grid, 0)
    love.graphics.print(CurrentDialogue, Grid*2, ScreenHeight*1/6)
    -- prefabPrinter could be used to print dialogue, 
    -- but needs to be somehow modified to only print the current line
    --PrefabPrinter("DialogueTree.lua", ScreenWidth/3, ScreenHeight*1/6)  
    love.graphics.setCanvas()
    
    -- draw the dialogue canvas on the screen
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
            if MoveToNextRoom(CharA:getX(), CharA:getY() - Grid) == true then
                RoomListCounter = RoomListCounter+1
                CharA:setX(Grid*12)
                CharA:setY(Grid*20)
                CurrentRoom = RoomList[RoomListCounter]
                ChangeRoom(7, 7, 15, 15)
            end
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
                if DialogueIndex == #CurrentDialogueList then
                    DialogueIndex = 0
                end
                DialogueIndex = DialogueIndex+1
                CurrentDialogue = CurrentDialogueList[DialogueIndex]
                DialogueTimeStamp = love.timer.getTime()
            end
        end
        -- test RoomList; currently uses DialogueTimeStamp because I'm lazy
        if love.timer.getTime() > DialogueTimeStamp+DialogueDelay then
            if love.keyboard.isDown("n") then do
                if RoomListCounter == #RoomList+1 then
                    CurrentRoom = RoomList[1]
                    RoomListCounter = 1
                end
                CurrentRoom = RoomList[RoomListCounter]
                RoomListCounter = RoomListCounter+1
                ChangeRoom(7, 7, 15, 15)
            end
            DialogueTimeStamp = love.timer.getTime()
        end
        end
    end
end