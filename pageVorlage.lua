local function printPage()
    -- code
end



local function eventListener(event, button, x, y)
    if event == "mouse_click" then
        --touch auf der Seite
    end
end



local function rednetListener(senderId, message, protocol)
    if protocol == "protocollNameRednet" then
        --receiveData für Seite        
    end
end



return {printPage = printPage, eventListener = eventListener, rednetListener = rednetListener, pageName = "Reaktor 1"}