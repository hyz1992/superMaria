local body = require("app.entity.body")

local monster_tortoise = class("monster_tortoise",body)

function monster_tortoise:ctor(objectTab)
	monster_tortoise.super.ctor(self,objectTab)
	self._spr:setSpriteFrame("img_67.png")
	self._spr:align(display.CENTER_BOTTOM,self:getContentSize().width/2,0)

	self:addStateMachine()

    self:doEvent("goWalkLeft")
end

function monster_tortoise:update()
	if not self:bIsInScreen() then
		return
	end
	monster_tortoise.super.update(self)
	local _bIsCollision,_tilePt = self:ifCollistionV(-1)	--随时监测竖直方向上是否有掉下去的趋势
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
    	local _ptX = self:getPositionX()
    	self:moveH()
    	_bIsCollision = self:ifCollistionH()
    	self:setPositionX(_ptX)
    	if _bIsCollision then
    		self:doEvent("goWalkRight")
    	end
    	self:moveH()
    elseif self.m_fsm:getState() == "walkRight" then
    	local _ptX = self:getPositionX()
    	self:moveH()
    	_bIsCollision = self:ifCollistionH()
    	self:setPositionX(_ptX)
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
        	{name = "goWalkLeft",  from = {"standing","walkRight","jumpLeft","walkLeft"}, to = "walkLeft" },
        	{name = "goWalkRight",  from = {"standing","walkLeft","jumpRight","walkRight"}, to = "walkRight" },
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
	if self.isVertigo then
		self._spr:setSpriteFrame("img_38.png")
	elseif _type==aniType.walk then
		local animation = display.newAnimation("img_%02d.png",67,2,false,0.15)
		local ani = cc.Animate:create(animation)
		self._spr:runAction(cc.RepeatForever:create(ani))
	else
		self._spr:setSpriteFrame("img_67.png")
	end
end

--direction,self的那个方向被碰撞,1:上，2:下，3:左，4:右
function monster_tortoise:isHited(body,direction)
	monster_tortoise.super.isHited(self,body,direction)
	if body:bIsMaria() then
		if direction ==1 then
			if self.isVertigo then
				local prama=3
				if body.m_speed > 0 then
					prama = 4
				end
				self:goDead(2)
			else
				self:goDead(1)
			end
		elseif direction==3 or direction==4 then
			if self.isVertigo then
				self:goDead(3,direction)
			end
		end
	else
		if self.m_fsm:getState()== "walkLeft" then
			self:doEvent("goWalkRight")
		elseif self.m_fsm:getState()== "walkRight" then
			self:doEvent("goWalkLeft")
		end	
	end
end

function monster_tortoise:changeSpeed(tag)
	local new_max_speed
	local new_acc_h
	if tag==1 then
		new_max_speed = 4.5
		new_acc_h = 4.5
	elseif tag==2 then
		new_max_speed = 1.1
		new_acc_h = 0.1
	end
	self:setPramas("max_h_speed",new_max_speed)
	self:setPramas("acc_h",new_acc_h)
end

--tag标志。1:被踩了第一脚，变成龟壳；2:被踩第二脚；3:被子弹打死
function monster_tortoise:goDead(tag,prama)
	if tag==1 then
		self.isVertigo = true
		self:doEvent("goStanding")
	elseif tag==2 then
		if not self.slide then	--	没有在滑行，才能开始滑行
			self:changeSpeed(1)
			if prama==3 then
				self:doEvent("goWalkRight")
			else
				self:doEvent("goWalkLeft")
			end
			self:adjustOffsetX()
			self.slide = true
		else
			self:doEvent("goStanding")
			self.slide = false
		end
	elseif tag==3 then
		self.slide = true
		self:doEvent("goStanding")
		if prama==3 then
			self:doEvent("goWalkRight")
		else
			self:doEvent("goWalkLeft")
		end
		self:adjustOffsetX()
	elseif tag==4 then
		self:clearSelf()
	end
end

--是否为可以攻击其他物种的状态
function monster_tortoise:ifCanAttack()
	if self.slide then
		return true
	else
		return false
	end
end

return monster_tortoise