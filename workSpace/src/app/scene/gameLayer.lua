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

    -- local xx = cc.numSprite:create()
    -- self:addChild(xx)
    -- xx:setPosition(100,100)

    self.m_map = mariaMap.new("tmx/mary1.tmx")
                    :addTo(self,0,0)

    self.m_maria = mariaAI.new()
        :addTo(self)
        :move(96, 5*self.m_map.tileSize.height)

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(handler(self,self.onKeyPressed), cc.Handler.EVENT_KEYBOARD_PRESSED )
    listener:registerScriptHandler(handler(self,self.onKeyReleased), cc.Handler.EVENT_KEYBOARD_RELEASED )

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_maria)

    self.btn_left = ccui.Button:create("left_1.png","left_2.png")
            :addTo(self)
            :move(70,80)
            --:scale(0.4)
            :opacity(150)

    self.btn_right = ccui.Button:create("right_1.png","right_2.png")
            :addTo(self)
            :move(170,80)
            --:scale(0.4)
            :opacity(150)

    self.btn_jump = ccui.Button:create("up_1.png","up_2.png")
            :addTo(self)
            :move(display.width-100,80)
            --:scale(0.4)
            :opacity(150)

    self.timeScaleBtn = ccui.Button:create("up_1.png","up_2.png")
            :addTo(self)
            :move(display.width-100,display.height-80)
            --:scale(0.4)
            :opacity(150)

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
        cc.MessageBox("caonima","qunima")
    end
    local _maria = event:getCurrentTarget()
    _maria:onKeyPressed(keyCode,event)
end

function gameLayer:onKeyReleased(keyCode,event)
    local _maria = event:getCurrentTarget()
    _maria:onKeyReleased(keyCode,event)
end

return gameLayer
