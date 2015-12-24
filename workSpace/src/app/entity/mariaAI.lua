local body = require("app.entity.body")

local mariaAI = class("mariaAI",body)

local MariaType = {}
MariaType.small = 1
MariaType.big = 2
MariaType.fire = 3

local aniType = {}
aniType.standing = 1
aniType.walk = 2
aniType.jump = 3
aniType.die = 4
aniType.fire = 5
aniType.down = 6

local OldCommond = {}
OldCommond.standing = 0
OldCommond.walkLeft = 1
OldCommond.walkRight = 2

local isJumpBtnDown = false  --跳跃按钮是否被按下

local gggggg = false


function mariaAI:ctor(...)
	mariaAI.super.ctor(self,...)
	display.loadSpriteFrames("mario.plist","mario.png")

	print("================================self.m_vSpeed: ",self.m_vSpeed)
	self.m_oldCommond = OldCommond.standing     --用于判断跳跃过程中的水平前进方向
	self.isJumpOver = false						--是否跳跃完毕
	self.m_mariaType = MariaType.fire			--当前玛丽的类型

    self:addStateMachine()
    self:onUpdate(handler(self,self.update))
end

function mariaAI:onExit()
	mariaAI.super.onExit(self)
	display.removeSpriteFrame("mario.plist")
end

function mariaAI:playAni(_type)
	--_type = aniType.standing
	--print(_type)
	self._spr:stopAllActions()
	if self.m_mariaType == MariaType.small then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_1_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self._spr:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self._spr:setSpriteFrame("mario_1_2.png")
		elseif aniType.standing == _type then
			self._spr:setSpriteFrame("mario_1_5.png")
		elseif aniType.die == _type then
			self._spr:setSpriteFrame("mario_1_6.png")
		end
	elseif self.m_mariaType == MariaType.big then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_2_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self._spr:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self._spr:setSpriteFrame("mario_2_2.png")
		elseif aniType.standing == _type then
			self._spr:setSpriteFrame("mario_2_5.png")
		elseif aniType.down == _type then
			self._spr:setSpriteFrame("mario_2_6.png")
		end
	elseif self.m_mariaType == MariaType.fire then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_3_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self._spr:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self._spr:setSpriteFrame("mario_3_2.png")
		elseif aniType.standing == _type then
			self._spr:setSpriteFrame("mario_3_5.png")
		elseif aniType.down == _type then
			self._spr:setSpriteFrame("mario_3_6.png")
		elseif aniType.fire == _type then
			self._spr:setSpriteFrame("mario_3_7.png")
		end
	end
end

function mariaAI:update()
	local _type,_tilePt = self:ifCollistionV(-1)	--随时监测竖直方向上是否有掉下去的趋势
	if _type==TileType.eTile_Ground or _type==TileType.eTile_Pillar or _type==TileType.eTile_Mountain or _type==TileType.eTile_Cloud or _type==TileType.eTile_BackGround then
		if self.m_fsm:getState() == "standing" then
			self:doEvent("goJumpUp",false)
		elseif self.m_fsm:getState() == "walkLeft" then
			self:doEvent("goJumpLeft",false)
		elseif self.m_fsm:getState() == "walkRight" then
			self:doEvent("goJumpRight",false)
		end
	end

	if self.m_fsm:getState() == "standing" then
        return
    elseif self.m_fsm:getState() == "walkLeft" then
    	self:moveH()
    elseif self.m_fsm:getState() == "walkRight" then
    	self:moveH()
    elseif self.m_fsm:getState() == "jumpUp" then
    	if self.isJumpOver then		--跳完到达地面
    		self:doEvent("goStanding")
    		if isJumpBtnDown then		--返回地面后，如果跳跃按钮还没松开，则继续跳
    			self:doEvent("goJumpUp")
    		end
    	else
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpLeft" then
    	if self.m_oldCommond == OldCommond.walkLeft then  
	    	self:moveH()
	    else
	    	self:doEvent("goJumpUp",false)  --跳到空中，中途松开向左按钮
	    	return
	    end
    	if self.isJumpOver then		--跳完到达地面
	    	self:doEvent("goWalkLeft")
	    	if isJumpBtnDown then		--返回地面后，如果跳跃按钮还没松开，则继续跳
    			self:doEvent("goJumpLeft")  
    		end
    	else
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpRight" then
    	if self.m_oldCommond == OldCommond.walkRight then
	    	self:moveH()--jumpRight状态","水平移动
	    else
	    	self:doEvent("goJumpUp",false)	--跳到空中，中途松开向右按钮
	    	return
	    end
    	if self.isJumpOver then		--跳完到达地面
	    	self:doEvent("goWalkRight")
	    	if isJumpBtnDown then
    			self:doEvent("goJumpRight")  --返回地面后，如果跳跃按钮还没松开，则继续跳
    		end
    	else
    		self:moveV()--jumpRight状态","垂直移动
    	end
    end
end

function mariaAI:addStateMachine()
    self.m_fsm = {}
    cc.GameObject.extend(self.m_fsm)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()

    self.m_fsm:setupState({
        -- 初始状态
        initial = "standing",
        
        -- 事件和状态转换
        events = {
            {name = "goStanding",  from = {"standing","walkLeft","walkRight","jumpUp","jumpLeft","jumpRight"}, to = "standing" },
            {name = "goWalkLeft",  from = {"standing","walkRight","jumpLeft"}, to = "walkLeft" },
            {name = "goWalkRight",  from = {"standing","walkLeft","jumpRight"}, to = "walkRight" },
            {name = "goJumpUp",  from = {"standing","jumpLeft","jumpRight"}, to = "jumpUp" },
            {name = "goJumpLeft",  from = {"walkLeft","jumpUp"}, to = "jumpLeft" },
            {name = "goJumpRight",  from = {"walkRight","jumpUp"}, to = "jumpRight" },
            {name = "goWalkDown",  from = {"standing"}, to = "walkDown" },
            
        }, 

        -- 状态转变后的回调 
        callbacks = {
            onstanding = function (event) self:standing() end,
            onwalkLeft = function (event) self:walkLeft() end,
            onwalkRight = function (event) self:walkRight() end,
            onjumpUp = function (event) self:jumpUp(event) end,
            onjumpLeft = function (event) self:jumpLeft(event) end,
            onjumpRight = function (event) self:jumpRight(event) end,
            goWalkDown = function (event) self:walkDown() end,

        },
    })
end

function mariaAI:doEvent(event, ...)
	if event == "goStanding" or event == "goWalkLeft" or event == "goWalkRight" then
		self.m_vSpeed = 0
		self.m_oldCommond = OldCommond.standing
		self.isJumpOver = false
	end
	--print("--------",event)
	if event == "goWalkLeft" or event == "goJumpLeft" then
		self:changeDirection(H_DirectionType.left)
		self.m_oldCommond = OldCommond.walkLeft
	end
	if event == "goWalkRight" or event == "goJumpRight" then
		self:changeDirection(H_DirectionType.right)
		self.m_oldCommond = OldCommond.walkRight
	end
    self.m_fsm:doEvent(event, ...)
end

function mariaAI:standing()
	self:playAni(aniType.standing)
end

function mariaAI:walkLeft()
	self:playAni(aniType.walk)
end

function mariaAI:walkRight()
	self:playAni(aniType.walk)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpUp(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
	self:playAni(aniType.jump)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpLeft(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
	self:playAni(aniType.jump)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpRight(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
	self:playAni(aniType.jump)
end

function mariaAI:walkDown()
	self:playAni(aniType.down)
end

function mariaAI:onKeyPressed(keyCode,event)
    if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
    	if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goWalkLeft")
	    elseif self.m_fsm:getState()=="jumpUp" then
	    	self:doEvent("goJumpLeft",false)
	    end
    elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW  then
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goWalkRight")
	    elseif self.m_fsm:getState()=="jumpUp" then
        	self:doEvent("goJumpRight",false)
	    end
    elseif keyCode == cc.KeyCode.KEY_UP_ARROW  then
    	if self.m_fsm:getState() == "jumpUp" or self.m_fsm:getState() == "jumpLeft" or self.m_fsm:getState() == "jumpRight" then
    		return
    	end
    	isJumpBtnDown = true
        if self.m_fsm:getState() == "standing" then
        	self:doEvent("goJumpUp")
        else
        	if self.m_direction == H_DirectionType.left then
		        self:doEvent("goJumpLeft")
		    elseif self.m_direction == H_DirectionType.right then
		    	self:doEvent("goJumpRight")
		    end
        end
    elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW  then
        print("cccccccccccccccccccccc")
    end
end

function mariaAI:onKeyReleased(keyCode,event)
    if keyCode == cc.KeyCode.KEY_LEFT_ARROW then
    	self.m_oldCommond = OldCommond.standing
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goStanding")
	    end
    elseif keyCode == cc.KeyCode.KEY_RIGHT_ARROW  then
    	self.m_oldCommond = OldCommond.standing
        if self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="walkLeft" or self.m_fsm:getState()=="standing" or self.m_fsm:getState()=="down" then
	        self:doEvent("goStanding")
	    end
    elseif keyCode == cc.KeyCode.KEY_UP_ARROW  then
        isJumpBtnDown = false
    elseif keyCode == cc.KeyCode.KEY_DOWN_ARROW  then
        print("cccccccccccccccccccccc")
        self:doEvent("goStanding")
    end
end

return mariaAI