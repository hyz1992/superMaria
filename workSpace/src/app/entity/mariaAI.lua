local body = require("app.entity.body")

local mariaAI = class("mariaAI",body)

local MariaType = {}
MariaType.small = 1
MariaType.big = 2
MariaType.fire = 3

local OldCommond = {}
OldCommond.standing = 0
OldCommond.walkLeft = 1
OldCommond.walkRight = 2

local isJumpBtnDown = false  --跳跃按钮是否被按下

local gggggg = false


function mariaAI:ctor(...)
	mariaAI.super.ctor(self,...)
	display.loadSpriteFrames("mario.plist","mario.png")

	self.m_oldCommond = OldCommond.standing     --用于判断跳跃过程中的水平前进方向
	
	self.m_mariaType = MariaType.fire			--当前玛丽的类型

    self:addStateMachine()
    
end

function mariaAI:onExit()
	mariaAI.super.onExit(self)
	display.removeSpriteFrame("mario.plist")
end

function mariaAI:playAni(_type)
	if _type~=nil then
		self.m_curMariaType = _type
	else
		_type = self.m_curMariaType
	end
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
			local animation = display.newAnimation("mario_3_%d.png",0,2,false,0.15)
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
	mariaAI.super.update(self)
	local _bIsCollision,_tilePt = self:ifCollistionV(-1)	--随时监测竖直方向上是否有掉下去的趋势
	local pt_2 = self:getPtRightDown()
	local _map = self:getMap()
	local mapX,mapY = _map:getPosition()
	pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	-- print("-------------开始")
	-- print(self.m_fsm:getState(),"x:"..pt_2.x.." y:"..pt_2.y.."   _bIsCollision: ",_bIsCollision)
	if not _bIsCollision then
		-- print("有掉下去的趋势")
		if self.m_fsm:getState() == "standing" then
			self:doEvent("goJumpUp",false)
		elseif self.m_fsm:getState() == "walkLeft" then
			self:doEvent("goJumpLeft",false)
			self:moveV()--为了使其立马掉下去，不至于因为水平速速过快而跨国砖块间隙
		elseif self.m_fsm:getState() == "walkRight" then
			self:doEvent("goJumpRight",false)
			self:moveV()--为了使其立马掉下去，不至于因为水平速速过快而跨国砖块间隙
		end
	end

	if self.m_fsm:getState() == "standing" then
        return
    elseif self.m_fsm:getState() == "walkLeft" then
    	self:moveH()
    elseif self.m_fsm:getState() == "walkRight" then
    	-- print("走路右移")
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
    		-- print("左跳，左移")
	    	self:moveH()
	    else
	    	-- print("左跳转为直跳")
	    	self:doEvent("goJumpUp",false)  --跳到空中，中途松开向左按钮
	    	return
	    end
    	if self.isJumpOver then		--跳完到达地面
    		-- print("左跳到达地面")
	    	self:doEvent("goWalkLeft")
	    	if isJumpBtnDown then		--返回地面后，如果跳跃按钮还没松开，则继续跳
    			self:doEvent("goJumpLeft")  
    		end
    	else
    		-- print("左跳，上下移")
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpRight" then
    	if self.m_oldCommond == OldCommond.walkRight then
    		-- print("右跳，右移")
	    	self:moveH()--jumpRight状态","水平移动
	    else
	    	-- print("右跳转为直跳")
	    	self:doEvent("goJumpUp",false)	--跳到空中，中途松开向右按钮
	    	return
	    end
    	if self.isJumpOver then		--跳完到达地面
    		-- print("右跳到达地面")
	    	self:doEvent("goWalkRight")
	    	if isJumpBtnDown then
    			self:doEvent("goJumpRight")  --返回地面后，如果跳跃按钮还没松开，则继续跳
    		end
    	else
    		-- print("右跳，上下移")
    		self:moveV()--jumpRight状态","垂直移动
    		
    	end
    end
    -- print("----------------结束")
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
            {name = "goStanding",  from = {"walkLeft","walkRight","jumpUp","jumpLeft","jumpRight","standing"}, to = "standing" },
            {name = "goWalkLeft",  from = {"standing","walkRight","jumpLeft"}, to = "walkLeft" },
            {name = "goWalkRight",  from = {"standing","walkLeft","jumpRight"}, to = "walkRight" },
            {name = "goJumpUp",  from = {"standing","jumpLeft","jumpRight","jumpUp"}, to = "jumpUp" },
            {name = "goJumpLeft",  from = {"walkLeft","jumpUp","jumpLeft"}, to = "jumpLeft" },
            {name = "goJumpRight",  from = {"walkRight","jumpUp","jumpRight"}, to = "jumpRight" },
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
	mariaAI.super.standing(self)
end

function mariaAI:walkLeft()
	mariaAI.super.walkLeft(self)
end

function mariaAI:walkRight()
	mariaAI.super.walkRight(self)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpUp(event)
	mariaAI.super.jumpUp(self)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpLeft(event)
	mariaAI.super.jumpLeft(self)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpRight(event)
	mariaAI.super.jumpRight(self)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = self:getPramas("max_v_speed")
	end
end

function mariaAI:walkDown()
	mariaAI.super.walkDown(self)
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

--被碰撞
--body，与谁相碰撞
--direction,self的那个方向被碰撞,1:上，2:下，3:左，4:右
function mariaAI:isHited(body,direction)
	mariaAI.super.isHited(self,body,direction)
	-- printTraceback()
	local name = body.__cname
	if name== "monster_mushroom" then
		if direction==2 then
			self.m_vSpeed = -self.m_vSpeed/2
			if self.m_fsm:getState()=="jumpUp" then
				self:doEvent("goJumpUp",false)
			elseif self.m_fsm:getState()=="jumpLeft" then
				self:doEvent("goJumpLeft",false)
			elseif self.m_fsm:getState()=="jumpRight" then
				self:doEvent("goJumpRight",false)
			end
		elseif direction==1 or direction==3 or direction==4 then
			self:goDead(1)
		end
	elseif name== "monster_tortoise" then
		if direction==2 then
			self.m_vSpeed = -self.m_vSpeed/2
			if self.m_fsm:getState()=="jumpUp" then
				self:doEvent("goJumpUp",false)
			elseif self.m_fsm:getState()=="jumpLeft" then
				self:doEvent("goJumpLeft",false)
			elseif self.m_fsm:getState()=="jumpRight" then
				self:doEvent("goJumpRight",false)
			end
		elseif direction==1 or direction==3 or direction==4 then
			self:goDead(1)
		end
	end
end

--tag标志位，	
--1:被怪物碰到，掉一滴血
--2:掉进陷阱，一命呜呼				
function mariaAI:goDead(tag)
	if tag==1 then
		self.m_mariaType = MariaType.big
		self:playAni()
	end
end

--是否为可以攻击其他物种的状态
function mariaAI:ifCanAttack()
	return true
end

return mariaAI