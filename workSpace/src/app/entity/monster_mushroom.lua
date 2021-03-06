local body = require("app.entity.body")

local monster_mushroom = class("monster_mushroom",body)

function monster_mushroom:ctor(objectTab)
	monster_mushroom.super.ctor(self,objectTab)
	self._spr:setSpriteFrame("img_33.png")
	self._spr:align(display.CENTER_BOTTOM,self:getContentSize().width/2,0)

	self:addStateMachine()

    self:doEvent("goWalkLeft")
end

function monster_mushroom:update(dt)
	if not self:bIsInScreen() then
		return
	end
	monster_mushroom.super.update(self)
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

function monster_mushroom:addStateMachine()
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

function monster_mushroom:doEvent(event, ...)
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

function monster_mushroom:playAni(_type)
	self._spr:stopAllActions()
	if _type==aniType.walk then
		self._spr:setSpriteFrame("img_33.png")
		local scale_x = 1
		local sq = transition.sequence{cc.CallFunc:create(function ( ... )
			self._spr:setScaleX(scale_x)
			scale_x = scale_x*-1
		end),cc.DelayTime:create(0.15)}
		self._spr:runAction(cc.RepeatForever:create(sq))
	else
		self._spr:setSpriteFrame("img_33.png")
	end
end

function monster_mushroom:onEnter()
	monster_mushroom.super.onEnter(self)
end

function monster_mushroom:onExit()
	print("=======ooo,蘑菇onexit")
	monster_mushroom.super.onExit(self)
end

--被碰撞
--body，与谁相碰撞
--direction,self的那个方向被碰撞,1:上，2:下，3:左，4:右
function monster_mushroom:isHited(body,direction)
	monster_mushroom.super.isHited(self,body,direction)
	if body:bIsMaria() and direction ==1 then
		self:goDead(1)
	elseif body.__cname=="monster_tortoise" then
		local prama = 3
		if body:getPositionX()>self:getPositionX() then
			prama = 4
		end
		self:goDead(2,prama)
	end
end

--tag标志,1:被踩死,2:被子弹打死
function monster_mushroom:goDead(tag,prama)
	if tag == 1 then
		self:clearSelf()
		self:setScaleY(0.5)
		local fadeTime = 1
		local sq = transition.sequence{cc.FadeOut:create(fadeTime),cc.CallFunc:create(function ()
			self:removeSelf()
		end)}
		self._spr:runAction(cc.FadeOut:create(fadeTime))
		self:runAction(sq)
	elseif tag == 2 then
		local pt = self:getPtRightTop()
		pt = self:convertToWorldSpace(pt)
		pt.y = -pt.y-100
		pt.x = pt.y+100
		if prama == 3 then
			pt.x = -1 * pt.x
		end
		self:clearSelf()

		local speed = 400
		local fadeTime = -pt.y/speed
		local sq = transition.sequence{cc.MoveBy:create(fadeTime,pt),cc.CallFunc:create(function ()
			self:removeSelf()
		end)}
		self:runAction(sq)
	end
end

return monster_mushroom