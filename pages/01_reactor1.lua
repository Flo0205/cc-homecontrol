local reactorData =
{
    maxEnergy = 0,
    energy = 0,
    coreTemp = 0,
    casingTemp = 0,
    status = false,
    generating = 0,
    fuelUsage = 0,
    fuel = 0,
    forceStopped = false,
}



local function printPage()
    if reactorData.forceStopped == false then
        paintutils.drawFilledBox(2, 2, 12, 4, colors.blue)
    else
        paintutils.drawFilledBox(2, 2, 12, 4, colors.gray)
    end
    term.setCursorPos(3, 3)
    term.setTextColor(colors.black)
    print "Automatic"
    if reactorData.forceStopped == true then
        paintutils.drawFilledBox(15, 2, 25, 4, colors.red)
    else
        paintutils.drawFilledBox(15, 2, 25, 4, colors.gray)
    end
    term.setCursorPos(16, 3)
    term.setTextColor(colors.black)
    print "Force off"
    term.setBackgroundColor(colors.black)
    if reactorData.status == true then
        term.setTextColor(colors.green)
    else
        term.setTextColor(colors.red)
    end
    term.setCursorPos(1, 6)
    print("Generating: " .. string.format("%.2f", reactorData.generating / 1000) .. " kFE/t")
    term.setCursorPos(1, 7)
    print("Fuel Usage: " .. string.format("%.2f", reactorData.fuelUsage) .. " mB/t")
    term.setCursorPos(1, 8)
    print("Buffer: " .. string.format("%.2f", reactorData.energy) .. " kFE")
end



local function eventListener(event, button, x, y)
    if event == "mouse_click" then
        if x >= 15 and y >= 2 and x <= 25 and y <= 4 then
            forceStopped = true
            rednet.broadcast(true, "reactorControl")
        elseif x >= 2 and y >= 2 and x <= 12 and y <= 4 then
            forceStopped = false
            rednet.broadcast(false, "reactorControl")
        end
    end
end



local function rednetListener(senderId, message, protocol)
    if protocol == "reactorData" then
        if type(message) == "table" then
            reactorData = message
            printPage()
        end
    end  
end


return {printPage = printPage, eventListener = eventListener, rednetListener = rednetListener, pageName = "Reaktor 1"}