local body = require("app.entity.body")

local monster_tortoise = class("monster_tortoise",body)

function monster_tortoise:ctor(objectTab)
	monster_tortoise.super.ctor(self)
	self._obj = objectTab
	self._spr:setSpriteFrame("img_67.png")
	self._spr:align(display.CENTER_BOTTOM,self:getContentSize().width/2,0)

	local _pos = cc.p(objectTab.x+8,objectTab.y-8)
	self:setPosition(_pos)

	self:addStateMachine()

    self:doEvent("goWalkLeft")
end

function monster_tortoise:update()
	monster_tortoise.super.update(self)
	local _bIsCollision,_tilePt = self:ifCollistionV(-1)	--随时监测竖直方向上是否有掉下去的趋势
	-- print("state: ",self.m_fsm:getState(),"_bIsCollision: ",_bIsCollision,"self.isJumpOver: ",self.isJumpOver)
	if not _bIsCollision then
		if self.m_fsm:getState() == "walkLeft" then
			self:doEvent("goJumpLeft")
			self:moveV()--为了使其立马掉下去，不至于因为水平速速过快而跨国砖块间隙
		elseif self.m_fsm:getState() == "walkRight" then
			self:doEvent("goJumpRight")
			self:moveV()--为了使其立马掉下去，不至于因为水平速速过快而跨国砖块间隙
		end
	end

	if self.m_fsm:getState() == "standing" then
        return
    elseif self.m_fsm:getState() == "walkLeft" then
    	_bIsCollision = self:ifCollistionH()
    	if _bIsCollision then
    		self:doEvent("goWalkRight")
    	end
    	self:moveH()
    elseif self.m_fsm:getState() == "walkRight" then
    	_bIsCollision = self:ifCollistionH()
    	if _bIsCollision then
    		self:doEvent("goWalkLeft")
    	end
    	self:moveH()
    elseif self.m_fsm:getState() == "jumpLeft" then
    	if self.isJumpOver then		--跳完到达地面
	    	self:doEvent("goWalkLeft")
    	else
    		self:moveV()
    	end
    elseif self.m_fsm:getState() == "jumpRight" then
    	if self.isJumpOver then		--跳完到达地面
	    	self:doEvent("goWalkRight")
    	else
    		self:moveV()--jumpRight状态","垂直移动
    	end
    end
end

function monster_tortoise:addStateMachine()
    self.m_fsm = {}
    cc.GameObject.extend(self.m_fsm)
    :addComponent("components.behavior.StateMachine")
    :exportMethods()
	
	self.m_fsm:setupState({
        -- 初始状态
        initial = "standing",

        -- 事件和状态转换
        events = {
        	{name = "goStanding",  from = {"standing","walkLeft","walkRight","jumpLeft","jumpRight"}, to = "standing" },
        	{name = "goWalkLeft",  from = {"standing","walkRight","jumpLeft"}, to = "walkLeft" },
        	{name = "goWalkRight",  from = {"standing","walkLeft","jumpRight"}, to = "walkRight" },
        	{name = "goJumpLeft",  from = {"walkLeft"}, to = "jumpLeft" },
        	{name = "goJumpRight",  from = {"walkRight"}, to = "jumpRight" },
    	},

    	-- 状态转变后的回调 
        callbacks = {
        	onstanding = function (event) self:standing() end,
        	onwalkLeft = function (event) self:walkLeft() end,
            onwalkRight = function (event) self:walkRight() end,
            onjumpLeft = function (event) self:jumpLeft(event) end,
            onjumpRight = function (event) self:jumpRight(event) end,
        },
	})
end

function monster_tortoise:doEvent(event, ...)
	if event == "goStanding" or event == "goWalkLeft" or event == "goWalkRight" then
		self.m_vSpeed = 0
		self.isJumpOver = false
	end

	if event == "goWalkLeft" or event == "goJumpLeft" then
		self:changeDirection(H_DirectionType.left)
	end
	if event == "goWalkRight" or event == "goJumpRight" then
		self:changeDirection(H_DirectionType.right)
	end

	self.m_fsm:doEvent(event, ...)
end

function monster_tortoise:playAni(_type)
	self._spr:stopAllActions()
	if _type==aniType.walk then
		local animation = display.newAnimation("img_%02d.png",67,2,false,0.15)
		local ani = cc.Animate:create(animation)
		self._spr:runAction(cc.RepeatForever:create(ani))
	else
		self._spr:setSpriteFrame("img_67.png")
	end
end

function monster_tortoise:isHited(body,direction)
	monster_tortoise.super.isHited(self,body,direction)
	-- print("monster_tortoise=================ddddddd")
end

return monster_tortoise