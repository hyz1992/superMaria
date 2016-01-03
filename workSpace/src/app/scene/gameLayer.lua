local mariaMap = require("app.entity.mariaMap")
local mariaAI = require("app.entity.mariaAI")


local gameLayer = class("gameLayer", cc.load("mvc").ViewBase)

function gameLayer:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)

    display.loadSpriteFrames("mariaObj.plist","mariaObj.png")
    display.loadSpriteFrames("control.plist","control.png")

    self.m_map = mariaMap.new("tmx/mary2.tmx")
                    :addTo(self,0,0)
                    -- :move(-200,0)

    self.m_maria = mariaAI.new()
        :addTo(self)
        :move(5*self.m_map.tileSize.width, 10*self.m_map.tileSize.height)

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(handler(self,self.onKeyPressed), cc.Handler.EVENT_KEYBOARD_PRESSED )
    listener:registerScriptHandler(handler(self,self.onKeyReleased), cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_maria)

    self.btn_left = ccui.Button:create("control_01.png","control_02.png","",1)
            :addTo(self)
            :move(80,80)

    self.btn_right = ccui.Button:create("control_01.png","control_02.png","",1)
            :addTo(self)
            :move(220,80)

    self.btn_right:setScaleX(-1)

    self.btn_jump  = ccui.Button:create("control_05.png","control_06.png","",1)
            :addTo(self)
            :move(display.width-70,120)

    self.timeScaleBtn= ccui.Button:create("control_03.png","control_04.png","",1)
            :addTo(self)
            :move(display.width-200,80)
    

    self.btn_left:addTouchEventListener(handler(self,self.onButtonTouch))
    self.btn_right:addTouchEventListener(handler(self,self.onButtonTouch))
    self.btn_jump:addTouchEventListener(handler(self,self.onButtonTouch))
    self.timeScaleBtn:addTouchEventListener(handler(self,self.onButtonTouch))

end

local _bol = true
function gameLayer:_func()
    if _bol then
        cc.Director:getInstance():getScheduler():setTimeScale(0.125)
    else
       cc.Director:getInstance():getScheduler():setTimeScale(1)
    end
    _bol = not _bol
end



function gameLayer:onButtonTouch(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if sender==self.btn_left then
            self.m_maria:onKeyPressed(cc.KeyCode.KEY_LEFT_ARROW,nil)
        elseif sender==self.btn_right then
            self.m_maria:onKeyPressed(cc.KeyCode.KEY_RIGHT_ARROW,nil)
        elseif sender==self.btn_jump then
            self.m_maria:onKeyPressed(cc.KeyCode.KEY_UP_ARROW,nil)
        end
    elseif eventType == ccui.TouchEventType.ended then
        if sender==self.btn_left then
            self.m_maria:onKeyReleased(cc.KeyCode.KEY_LEFT_ARROW,nil)
        elseif sender==self.btn_right then
        print("-----------松开")
            self.m_maria:onKeyReleased(cc.KeyCode.KEY_RIGHT_ARROW,nil)
        elseif sender==self.btn_jump then
            self.m_maria:onKeyReleased(cc.KeyCode.KEY_UP_ARROW,nil)
        end

        if sender==self.timeScaleBtn then
        print("-----------=========-=-=-=-=-=ioijihii")
            self:_func()
        end
    elseif eventType == ccui.TouchEventType.moved then
    elseif eventType == ccui.TouchEventType.canceled then
    end
end

function gameLayer:onKeyPressed(keyCode,event)
    if keyCode==cc.KeyCode.KEY_BACK or keyCode==cc.KeyCode.KEY_A then
        device.showAlert("提示", "您确定退出游戏吗?", {"是", "否"}, function (event)  
            printTable(event)
            if event.buttonIndex == 1 then  
                cc.Director:getInstance():endToLua()
            else  
                device.cancelAlert()   
            end  
        end)
    end
    local _maria = event:getCurrentTarget()
    _maria:onKeyPressed(keyCode,event)
end

function gameLayer:onKeyReleased(keyCode,event)
    local _maria = event:getCurrentTarget()
    _maria:onKeyReleased(keyCode,event)
end

function gameLayer:onEnter()
    self:onUpdate(handler(self,self.update))
    local _tab_1 = self.m_map.m_objectGroup:getObjects()
    --print(type(_tab_1))
    for k,v in pairs(_tab_1) do
        local node = parseTiledObject(v)
        if node then
            node:addTo(self.m_map)
        end
        -- for kk,vv in pairs(v) do
        --     print("key: ",kk,"value: ",vv)
        -- end
    end
end

function gameLayer:onExit()
    display.removeSpriteFrame("mariaObj.plist")
    display.removeSpriteFrame("control.plist")
end

function gameLayer:update(dt)
    for k,v in pairs(allBodyList) do
        v:update(dt)
    end
end

return gameLayer
