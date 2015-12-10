local mariaAI = class("mariaAI",function ( ... )
	local node = display.newNode()
	node:setAnchorPoint(0,0)
	return node
end)

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

local MariaDirectionType = {}
MariaDirectionType.left = -1
MariaDirectionType.right = 1

local OldCommond = {}
OldCommond.standing = 0
OldCommond.walkLeft = 1
OldCommond.walkRight = 2

local isJumpBtnDown = false  --跳跃按钮是否被按下

local MAX_V_SPEED = 12            --最大垂直速度
local ACC_V = 0.5					--垂直加速度

local START_H_SPEED = 0.5			--水平方向初始速度
local MAX_H_SPEED = 3				--水平方向最大速度
local ACC_H = 0.1					--水平方向加速度

function mariaAI:ctor()
	display.loadSpriteFrames("mario.plist","mario.png")
	self.m_mariArmature = display.newSprite()
					:align(display.CENTER_BOTTOM,0,0)
	self:addChild(self.m_mariArmature,0,0)

	self:changeDirection(MariaDirectionType.right)

	self.m_speed = START_H_SPEED				--水平方向速度
	self.m_vSpeed = 0							--垂直方向速度
	self.m_oldCommond = OldCommond.standing     --用于判断跳跃过程中的水平前进方向
	self.isJumpOver = false						--是否跳跃完毕
	self.m_mariaType = MariaType.fire			--当前玛丽的类型

	self:playAni()

    self:addStateMachine()
    self:onUpdate(handler(self,self.update))
end

function mariaAI:onExit()
	display.removeSpriteFrame("mario.plist")
end

function mariaAI:playAni(_type)
	--_type = aniType.standing
	--print(_type)
	self.m_mariArmature:stopAllActions()
	if self.m_mariaType == MariaType.small then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_1_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_5.png")
		elseif aniType.die == _type then
			self.m_mariArmature:setSpriteFrame("mario_1_6.png")
		end
	elseif self.m_mariaType == MariaType.big then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_2_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_5.png")
		elseif aniType.down == _type then
			self.m_mariArmature:setSpriteFrame("mario_2_6.png")
		end
	elseif self.m_mariaType == MariaType.fire then
		if aniType.walk == _type then
			local animation = display.newAnimation("mario_3_%d.png",0,2,false,0.2)
			local ani = cc.Animate:create(animation)
			self.m_mariArmature:runAction(cc.RepeatForever:create(ani))
		elseif aniType.jump == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_2.png")
		elseif aniType.standing == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_5.png")
		elseif aniType.down == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_6.png")
		elseif aniType.fire == _type then
			self.m_mariArmature:setSpriteFrame("mario_3_7.png")
		end
	end
end

function mariaAI:update()
	local _type,_tilePt = self:ifCollistionV(-1)	--随时监测竖直方向上是否有掉下去的趋势
	if _type==TileType.eTile_Ground or _type==TileType.eTile_Pillar or _type==TileType.eTile_Mountain or _type==TileType.eTile_Cloud or _type==TileType.eTile_BackGround then
		if self.m_fsm:getState() == "standing" then
			print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_type: ",_type)
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

function mariaAI:moveV()
	local y = self:getPtRightDown().y
	local _type,_tilePt = self:ifCollistionV()
	if _type==TileType.eTile_Barrier or _type==TileType.eTile_Object_image or _type==TileType.eTile_Monster_image then
		if self.m_vSpeed >=0 then  --向上遇到障碍，向下反弹
			self.m_vSpeed = 0 - self.m_vSpeed
			print("碰壁-----------------")
		else  					   --向下遇到障碍，垂直速度降为0
			self.m_vSpeed = 0
			self.isJumpOver = true
			local _map = self:getParent().m_map
			local _tab = {_map:tilecoordToPosition(_tilePt)}
			local mapPtY = _map:getPositionY()
			local _realPtY = _tab[2].y + mapPtY
			self:setPositionY(_realPtY)			--对y坐标进行微调，使脚下始终刚好在一个块上面
		end
		return
	end
	self.isJumpOver = false	--表示正在跳跃状态中
	self.m_vSpeed = self.m_vSpeed - ACC_V
	if self.m_vSpeed<-MAX_V_SPEED then
		self.m_vSpeed = -MAX_V_SPEED
	end

	local ptY = self:getPositionY()
	local _map = self:getParent().m_map
	local mapHeight = _map.tileSize.height * _map.mapSize.height
	local mapPtY = _map:getPositionY()
	
	if self.m_vSpeed>0 then
		if ptY < display.height / 10 * 7 or mapPtY <=-(mapHeight - display.height) then		--在玛丽y坐标小于0.7倍屏幕高度或者地图已经到了最高，则向上移动玛丽
			ptY = ptY + self.m_vSpeed
			self:setPositionY(ptY)
		else                                            --否则向下移动地图
			mapPtY = mapPtY-self.m_vSpeed  	
			if mapPtY<-(mapHeight - display.height) then	--对地图坐标进行微调
				print("重置地图Y坐标为mapHeight - display.height，"..(mapHeight - display.height))
				mapPtY = -(mapHeight - display.height)
			end
			_map:setPositionY(mapPtY)
		end
		
	elseif self.m_vSpeed<0 then
		if ptY > display.height / 10 * 3 or mapPtY >=0 then		--玛丽y坐标大于0.3倍屏幕高度或者地图已经到了最低，则向下移动玛丽
			ptY = ptY + self.m_vSpeed
			self:setPositionY(ptY)
		else                                            --否则向上移动地图
			mapPtY = mapPtY-self.m_vSpeed
			if mapPtY>0 then	--对地图坐标进行微调
				print("重置地图Y坐标为0，"..mapPtY)
				mapPtY = 0
			end
			_map:setPositionY(mapPtY)
		end
	end

end
--水平方向移动碰到障碍物时，对玛丽x坐标进行微调，保证玛丽不与障碍物交叉
function mariaAI:adjustOffsetX()
	local ptX = self:getPositionX()
	local _map = self:getParent().m_map
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()

	local rect = self.m_mariArmature:getBoundingBox()
	local realPtX,tileNum
	if self.m_direction == MariaDirectionType.right then	--向右移动时
		realPtX = ptX -mapPtX + rect.width/2	--先得到玛丽的右边界在地图上的x坐标
		tileNum = math.floor(realPtX/_map.tileSize.width)	--得到向左边数的地图块数
		local mod = realPtX % _map.tileSize.width	--得到多出来的像素数
		if mod~=0 and mod <= MAX_H_SPEED then		--当mod小于水平速度，则忽略mod
			realPtX = tileNum * _map.tileSize.width	--舍去
			ptX = realPtX + mapPtX - rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - MAX_H_SPEED then --当mod大于（块宽度-水平速度），则不能忽略mod
			realPtX = tileNum * _map.tileSize.width + _map.tileSize.width	--进一
			ptX = realPtX + mapPtX - rect.width/2
		end--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
		self:setPositionX(ptX)
	elseif self.m_direction == MariaDirectionType.left then	--向左移动时
		realPtX = ptX -mapPtX - rect.width/2	--先得到玛丽的左边界在地图上的x坐标
		tileNum = math.ceil(realPtX/_map.tileSize.width)	--得到向左边数的地图块数
		local mod = realPtX % _map.tileSize.width			--得到多出来的像素数
		if mod~=0 and mod <= MAX_H_SPEED then		
			realPtX = tileNum * _map.tileSize.width - _map.tileSize.width	--舍去
			ptX = realPtX + mapPtX + rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - MAX_H_SPEED then		--进一
			realPtX = tileNum * _map.tileSize.width 
			ptX = realPtX + mapPtX + rect.width/2
		end
		self:setPositionX(ptX)
	end
end

function mariaAI:moveH()
	local ptX = self:getPositionX()
	local _map = self:getParent().m_map
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()

	local function _moveH()
		if self.m_speed<MAX_H_SPEED then
			self.m_speed = self.m_speed + ACC_H
		end
		
		if self.m_direction == MariaDirectionType.right then
			if ptX < display.width / 10 * 7 or mapPtX <=-(mapLength - display.width) then--在玛丽x坐标小于0.7倍屏幕高度或者地图已经到了最右边，则向右移动玛丽
				ptX = ptX + self.m_speed
				self:setPositionX(ptX)
			else
				mapPtX = mapPtX-self.m_speed
				_map:setPositionX(mapPtX)
			end
			
		elseif self.m_direction == MariaDirectionType.left then--在玛丽x坐标大于0.3倍屏幕高度或者地图已经到了最左边，则向左移动玛丽
			if ptX > display.width / 10 * 3 or mapPtX >=0 then
				ptX = ptX - self.m_speed
				self:setPositionX(ptX)
			else
				mapPtX = mapPtX+self.m_speed
				_map:setPositionX(mapPtX)
			end
		end
	end

	local oldPtx = ptX
	local oldMapPtX = mapPtX
	_moveH()					--先向后演算一步
	ptX = oldPtx 			--恢复演算前的坐标
	mapPtX = oldMapPtX
	local _type = self:ifCollistionH()	--演算后的地图类型
	self:setPositionX(ptX)
	_map:setPositionX(mapPtX)
	--如果碰到障碍物，要微调
	if _type==TileType.eTile_Barrier or _type==TileType.eTile_Object_image or _type==TileType.eTile_Monster_image or _type==TileType.eTile_Bounder then
		--撞到障碍物时，对横坐标进行微调
		-- print(self.m_fsm:getState())
		if self.m_fsm:getState()== "walkLeft" or self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="jumpLeft" or self.m_fsm:getState()=="jumpRight" then
			self:adjustOffsetX()
		end
		return
	end
	_moveH()
end

--竖直方向上的碰撞检测,offSet是地图块的偏移量{x,y}
--bValue为可选参数，bValue=1，表示向上检测，bValue=-1表示向下检测，bValue=0或bValue=nil表示根据竖直方向速度检测
function mariaAI:ifCollistionV(bValue)
	local _offY = 0
	local _map = self:getParent().m_map
	local pt_1,pt_2
	bValue = bValue or 0
	local _bol		--方向是否是向上
	if bValue==0 then
		_bol = (self.m_vSpeed >=0)
	elseif bValue==1 then
		_bol = true
	elseif bValue==-1 then
		_bol = false
	else
		_bol = (self.m_vSpeed >=0)
	end
	if _bol then 		   --向上
		pt_1 = self:getPtLeftTop()			--需要检测的有左上和右上边界
		pt_2 = self:getPtRightTop()
		pt_1.y = pt_1.y+_offY
		pt_2.y = pt_2.y+_offY
		if pt_1.y>=display.height then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	else 								--向下
		pt_1 = self:getPtLeftDown()			--需要检测的有左下和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.y = pt_1.y-_offY
		pt_2.y = pt_2.y-_offY
		if pt_1.y<=0 then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	end

	local mapX,mapY = _map:getPosition()
	pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
	pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	local _y 
	if _bol then 
		_y = 1		--如果方向为向上，则在两块之间时得到上面的块
	else 			--如果方向为向下，则在两块之间时得到下面的块
		_y = -1
	end

	pt_1 = _map:positionToTileCoord(pt_1,{x=1,y = _y})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x=-1,y = _y})

	local type_1 = _map:tileTypeforPos(pt_1)		--得到块类型
	local type_2 = _map:tileTypeforPos(pt_2)

	if type_1==TileType.eTile_Barrier or type_1==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image or type_1==TileType.eTile_Land then		--如果阻止前进的东西，则先返回
		return type_1,pt_1
	end
	if type_2==TileType.eTile_Barrier or type_2==TileType.eTile_Object_image or type_2==TileType.eTile_Monster_image or type_2==TileType.eTile_Land then
		return type_2,pt_2
	end

	if type_1~=TileType.eTile_None then
		return type_1,pt_1
	else
		return type_2,pt_2
	end
end

--水平方向上的碰撞检测
function mariaAI:ifCollistionH()
	local _offX = 0
	local _map = self:getParent().m_map
	local pt_1,pt_2
	local _bol = (self.m_direction == MariaDirectionType.right)
	if _bol then
		pt_1 = self:getPtRightTop()			--需要检测的有右上和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.x = pt_1.x+_offX
		pt_2.x = pt_2.x+_offX

		if pt_1.x>=display.width then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	else
		pt_1 = self:getPtLeftTop()			--需要检测的有左上和左下边界
		pt_2 = self:getPtLeftDown()
		pt_1.x = pt_1.x-_offX
		pt_2.x = pt_2.x-_offX
		if pt_1.x<=0 then				--首先判断是否到了边界
			return TileType.eTile_Bounder
		end
	end

	local mapX,mapY = _map:getPosition()
	pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
	pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	local _x 
	if _bol then 
		_x = 1		--如果方向为向右，则在两块之间时得到右面的块
	else
		_x = -1		--如果方向为向左，则在两块之间时得到左面的块
	end

	pt_1 = _map:positionToTileCoord(pt_1,{x = _x,y=-1})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x = _x,y=1})
	local type_1 = _map:tileTypeforPos(pt_1)		--得到块类型
	local type_2 = _map:tileTypeforPos(pt_2)

	if type_1==TileType.eTile_Barrier or type_1==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image then		--如果阻止前进的东西，则先返回
		return type_1
	end
	if type_2==TileType.eTile_Barrier or type_2==TileType.eTile_Object_image or type_1==TileType.eTile_Monster_image then
		return type_2
	end

	if type_1~=TileType.eTile_None then
		return type_1
	else
		return type_2
	end
end

function mariaAI:getPtLeftTop()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	position.y = position.y + rect.height
	return position
end

function mariaAI:getPtLeftDown()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	return position
end

function mariaAI:getPtRightTop()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width/2
	position.y = position.y + rect.height
	return position
end

function mariaAI:getPtRightDown()
	local rect = self.m_mariArmature:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width /2
	return position
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
		self:changeDirection(MariaDirectionType.left)
		self.m_oldCommond = OldCommond.walkLeft
	end
	if event == "goWalkRight" or event == "goJumpRight" then
		self:changeDirection(MariaDirectionType.right)
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
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpLeft(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end
--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
function mariaAI:jumpRight(event)
	if event.args[1]==nil or event.args[1] then
		self.m_vSpeed = MAX_V_SPEED
	end
	self:playAni(aniType.jump)
end

function mariaAI:walkDown()
	self:playAni(aniType.down)
end

function mariaAI:changeDirection(_direction)
	self.m_direction = _direction
	self.m_mariArmature:setScale(self.m_direction,1)
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
        	if self.m_direction == MariaDirectionType.left then
		        self:doEvent("goJumpLeft")
		    elseif self.m_direction == MariaDirectionType.right then
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