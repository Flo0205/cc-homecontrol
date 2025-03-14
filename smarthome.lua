shell.run("updater")

rednet.open("back")

local page = 1

local pages = {}
local files = fs.list("/pages/")
for i = 1, #files do
    local fileName = files[i]:gsub("%.lua$", "") -- Remove .lua extension
    local filePath = "/pages/" .. fileName
    local module = require(filePath)  -- Load the file (returns a table)
    pages[i] = module  -- Store the module in a table
end


local function printFrame(pageName)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 1)
    print("<-")

    term.setCursorPos(25, 1)
    print("->")

    term.setCursorPos(5, 1)
    print(pageName)

    term.setCursorPos(13, 19)
    print(page)
end

local function updateScreen()
    term.clear()
    printFrame(pages[page].pageName)
    pages[page].printPage()
end


local function receiveData()
    while true do
        local senderID, message, protocol = rednet.receive()
        pages[page].rednetListener(senderID, message, protocol)
    end
end


local function onTouch()
    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if x >= 1 and y >= 1 and x <= 2 and y <= 1 then
            page = page - 1
            if page < 1 then
                page = 1
            end
            updateScreen()
        elseif x >= 25 and y >= 1 and x <= 26 and y <= 1 then
            page = page + 1
            if page > #pages then
                page = #pages
            end
            updateScreen()
        else
            pages[page].eventListener(event, button, x, y)
        end
    end
end


updateScreen()
parallel.waitForAny(receiveData, onTouch)




-- ------- ToDo -------
-- Graphen der Auslastung Reaktor und Reaktor2
-- Kommentieren
-- Pfeiltaste