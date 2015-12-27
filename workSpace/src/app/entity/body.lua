local body = class("body",function ( ... )
	local node = display.newNode()
	node:setAnchorPoint(0,0)
	return node
end)

H_DirectionType = {}
H_DirectionType.left = -1
H_DirectionType.right = 1

local MAX_H_SPEED_MARIA = 5				--水平方向最大速度
local ACC_H_MARIA = 0.1					--水平方向加速度
local MAX_V_SPEED_MARIA = 12            --最大垂直速度
local ACC_V_MARIA = 0.5					--垂直加速度
local START_H_SPEED_MARIA = 0.5			--水平方向初始速度

local MAX_H_SPEED_MONSTAR_1 = 1.0				--水平方向最大速度
local ACC_H_MONSTAR_1 = 0.1					--水平方向加速度
local MAX_V_SPEED_MONSTAR_1 = 7            --最大垂直速度
local ACC_V_MONSTAR_1 = 0.5					--垂直加速度
local START_H_SPEED_MONSTAR_1 = 1			--水平方向初始速度


function body:setSpeed()
	local name = self.__cname
	if name=="mariaAI" then
		self.MAX_H_SPEED = MAX_H_SPEED_MARIA
		self.ACC_H = ACC_H_MARIA
		self.MAX_V_SPEED = MAX_V_SPEED_MARIA
		self.ACC_V = ACC_V_MARIA
		self.START_H_SPEED = START_H_SPEED_MARIA
	else
		self.MAX_H_SPEED = MAX_H_SPEED_MONSTAR_1
		self.ACC_H = ACC_H_MONSTAR_1
		self.MAX_V_SPEED = MAX_V_SPEED_MONSTAR_1
		self.ACC_V = ACC_V_MONSTAR_1
		self.START_H_SPEED = START_H_SPEED_MONSTAR_1
		return false
	end
end

function body:getPramas(pramaType)
	local name = self.__cname
	if name=="mariaAI" then
		if pramaType=="max_v_speed" then
			return self.MAX_V_SPEED
		elseif pramaType=="max_h_speed" then
			return self.MAX_H_SPEED
		end
	end
end

function body:getMap()
	local name = self.__cname
	local _map = nil
	if self:bIsMaria() then
		_map = self:getParent().m_map
	else
		_map = self:getParent()
	end

	return _map
end

function body:bIsMaria()
	local name = self.__cname
	if name=="mariaAI" then
		return true
	else
		return false
	end
end

function body:isColliSionTile(tilePt)
	local _map = self:getMap()
	local _type = _map:tileTypeforPos(tilePt)		--得到块类型
	
	if _type==TileType.eTile_Barrier or _type==TileType.eTile_Object_image or gggggg or _type==TileType.eTile_Bounder then		--如果阻止前进的东西，则先返回
		return true
	end

	return false
end

function body:ctor( ... )
	self._spr = display.newSprite()
					:align(display.CENTER_BOTTOM,0,0)
	self:addChild(self._spr,0,0)
	self:setSpeed()
	self.m_speed = self.START_H_SPEED				--水平方向速度
	self.m_vSpeed = 0							--垂直方向速度
	self.isJumpOver = false						--是否跳跃完毕
	self:changeDirection(H_DirectionType.right)
	
end

function body:changeDirection(_direction)
	self.m_direction = _direction
	self._spr:setScale(self.m_direction,1)
end

function body:onExit()
	
end

--水平方向移动碰到障碍物时，对玛丽x坐标进行微调，保证玛丽不与障碍物交叉
function body:adjustOffsetX()
	local ptX = self:getPositionX()
	local _map = self:getMap()
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()
	if not self:bIsMaria() then
		mapPtX = 0
	end
	local rect = self._spr:getBoundingBox()
	local realPtX,tileNum
	if self.m_direction == H_DirectionType.right then	--向右移动时
		realPtX = ptX -mapPtX + rect.width/2	--先得到玛丽的右边界在地图上的x坐标
		tileNum = math.floor(realPtX/_map.tileSize.width)	--得到向左边数的地图块数
		local mod = realPtX % _map.tileSize.width	--得到多出来的像素数
		if mod~=0 and mod <= self.MAX_H_SPEED then		--当mod小于水平速度，则忽略mod
			realPtX = tileNum * _map.tileSize.width	--舍去
			ptX = realPtX + mapPtX - rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - self.MAX_H_SPEED then --当mod大于（块宽度-水平速度），则不能忽略mod
			realPtX = tileNum * _map.tileSize.width + _map.tileSize.width	--进一
			ptX = realPtX + mapPtX - rect.width/2
		end--如果第一个参数为false,则表示垂直方向速度不重置为最大树脂速度，即竖直方向做抛物线运动
		-- if not self:bIsMaria() then
		-- 	print("444,设置x,",ptX)
		-- end
		self:setPositionX(ptX)
	elseif self.m_direction == H_DirectionType.left then	--向左移动时
		realPtX = ptX -mapPtX - rect.width/2	--先得到玛丽的左边界在地图上的x坐标
		tileNum = math.ceil(realPtX/_map.tileSize.width)	--得到向左边数的地图块数
		local mod = realPtX % _map.tileSize.width			--得到多出来的像素数
		if mod~=0 and mod <= self.MAX_H_SPEED then		
			realPtX = tileNum * _map.tileSize.width - _map.tileSize.width	--舍去
			ptX = realPtX + mapPtX + rect.width/2
		elseif mod~=0 and mod >= _map.tileSize.width - self.MAX_H_SPEED then		--进一
			realPtX = tileNum * _map.tileSize.width 
			ptX = realPtX + mapPtX + rect.width/2
		end
		self:setPositionX(ptX)
	end
end

function body:moveH()
	-- if self:bIsMaria() then print("speedH",self.m_speed) end
	local ptX = self:getPositionX()
	local _map = self:getMap()
	local mapLength = _map.tileSize.width * _map.mapSize.width
	local mapPtX = _map:getPositionX()
	if not self:bIsMaria() then
		mapPtX = 0
	end

	local function _moveH()
		if self.m_speed<self.MAX_H_SPEED then
			self.m_speed = self.m_speed + self.ACC_H
		end
		
		if self.m_direction == H_DirectionType.right then
			if self:bIsMaria() then
				if ptX < display.width / 10 * 7 or mapPtX <=-(mapLength - display.width) then--在玛丽x坐标小于0.7倍屏幕高度或者地图已经到了最右边，则向右移动玛丽
					ptX = ptX + self.m_speed
					self:setPositionX(ptX)
				else
					mapPtX = mapPtX-self.m_speed
					_map:setPositionX(mapPtX)
				end
			else
				ptX = ptX + self.m_speed
				self:setPositionX(ptX)
			end
			
		elseif self.m_direction == H_DirectionType.left then--在玛丽x坐标大于0.3倍屏幕高度或者地图已经到了最左边，则向左移动玛丽
			if self:bIsMaria() then	
				if ptX > display.width / 10 * 3 or mapPtX >=0 then
					ptX = ptX - self.m_speed
					self:setPositionX(ptX)
				else
					mapPtX = mapPtX+self.m_speed
					_map:setPositionX(mapPtX)
				end
			else
				ptX = ptX - self.m_speed
				self:setPositionX(ptX)
			end
		end
	end

	local oldPtx = ptX
	local oldMapPtX = mapPtX
	local oldHspeed = self.m_speed
	_moveH()					--先向后演算一步
	
	local _bIsCollision = self:ifCollistionH()	--演算后的地图类型
	ptX = oldPtx 			--恢复演算前的坐标
	mapPtX = oldMapPtX
	self.m_speed = oldHspeed
	self:setPositionX(ptX)
	if self:bIsMaria() then
		_map:setPositionX(mapPtX)
	end
	if sdfgh then
		print("_bIsCollision: ",_bIsCollision,self:getPtRightDown().x-mapPtX,self:getPtRightDown().y-_map:getPositionY())
	end
	--如果碰到障碍物，要微调
	if _bIsCollision then
		--撞到障碍物时，对横坐标进行微调
		if self.m_fsm:getState()== "walkLeft" or self.m_fsm:getState()=="walkRight" or self.m_fsm:getState()=="jumpLeft" or self.m_fsm:getState()=="jumpRight" then
			if not self:bIsMaria() then self:adjustOffsetX() end
		end
		return
	end
	_moveH()
end

function body:moveV()
	local ptY = self:getPositionY()
	local _map = self:getMap()
	local mapHeight = _map.tileSize.height * _map.mapSize.height
	local mapPtY = _map:getPositionY()
	if not self:bIsMaria() then
		mapPtY = 0
	end
	
	local function _moveV()
		self.m_vSpeed = self.m_vSpeed - self.ACC_V
		if self.m_vSpeed<-self.MAX_V_SPEED then
			self.m_vSpeed = -self.MAX_V_SPEED
		end
		if self.m_vSpeed>0 then
			if self:bIsMaria() then	
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
			else
				ptY = ptY + self.m_vSpeed
				self:setPositionY(ptY)
			end
			
		elseif self.m_vSpeed<0 then
			if self:bIsMaria() then	
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
			else
				ptY = ptY + self.m_vSpeed
				self:setPositionY(ptY)
			end
		end
	end

	local oldPtY = ptY
	local oldMapPtY = mapPtY
	local oldVspeed = self.m_vSpeed
	_moveV()					--先向后演算一步
	
	local _bIsCollision,_tilePt = self:ifCollistionV()
	ptY = oldPtY 			--恢复演算前的坐标
	mapPtY = oldMapPtY
	self.m_vSpeed = oldVspeed
	self:setPositionY(ptY)
	if self:bIsMaria() then
		_map:setPositionY(mapPtY)
	end
	if jklh then
		print("竖直_bIsCollision: ",_bIsCollision,self:getPtRightDown().x-_map:getPositionX(),self:getPtRightDown().y-mapPtY,self.m_vSpeed)
	end
	-- if not self:bIsMaria() then print("_bIsCollision: ",_bIsCollision) end
	if _bIsCollision then
		if self.m_vSpeed >=0 then  --向上遇到障碍，向下反弹
			self.m_vSpeed = 0 - self.m_vSpeed
			-- print("垂直反弹，",self.m_vSpeed)
		else  					   --向下遇到障碍，垂直速度降为0
			-- print("向下障碍，",self.m_vSpeed)
			self.m_vSpeed = 0
			self.isJumpOver = true
			local _map = self:getMap()
			local _tab = {_map:tilecoordToPosition(_tilePt)}
			local _realPtY = _tab[2].y + mapPtY
			self:setPositionY(_realPtY)			--对y坐标进行微调，使脚下始终刚好在一个块上面
			-- if not self:bIsMaria() then 
			-- 	print("_tilePt.x: ",_tilePt.x,"_tilePt.y: ",_tilePt,"_realPtY: ",_realPtY) 
			-- 	printTable(_tab)
			-- end
		end
		return
	end
	_moveV()
	self.isJumpOver = false	--表示正在跳跃状态中
end

--竖直方向上的碰撞检测,offSet是地图块的偏移量{x,y}
--bValue为可选参数，bValue=1，表示向上检测，bValue=-1表示向下检测，bValue=0或bValue=nil表示根据竖直方向速度检测
function body:ifCollistionV(bValue)
	local _offY = 0
	local _map = self:getMap()
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
		--上边界暂不处理
		-- if pt_1.y>=display.height then				--首先判断是否到了边界
		-- 	if not self:bIsMaria() then print("shang bian jie ") end
		-- 	return true,cc.p(pt_1.x,_map.mapSize.height)
		-- end
	else 								--向下
		pt_1 = self:getPtLeftDown()			--需要检测的有左下和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.y = pt_1.y-_offY
		pt_2.y = pt_2.y-_offY
		if pt_1.y<=0 then				--首先判断是否到了边界
			return true,cc.p(pt_1.x,0)
		end
	end
	if self:bIsMaria() then
		local mapX,mapY = _map:getPosition()
		pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
		pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	end
	local _y 
	if _bol then 
		_y = 1		--如果方向为向上，则在两块之间时得到上面的块
	else 			--如果方向为向下，则在两块之间时得到下面的块
		_y = -1
	end
	pt_3 = cc.p((pt_1.x+pt_2.x)/2,(pt_1.y+pt_2.y)/2)

	pt_1 = _map:positionToTileCoord(pt_1,{x=1,y = _y})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x=-1,y = _y})
	pt_3 = _map:positionToTileCoord(pt_3,{x = _x})
	-- print("pt_1:",pt_1,"pt_2:",pt_2,"pt_3:",pt_3)
	if self:isColliSionTile(pt_1) then
		-- if not self:bIsMaria() then print("pt_1.y: ",pt_1.y) end
		return true,pt_1
	end
	if self:isColliSionTile(pt_2) then
		-- if not self:bIsMaria() then print("pt_2.y: ",pt_2.y) end
		return true,pt_2
	end
	if self:isColliSionTile(pt_3) then
		-- if not self:bIsMaria() then print("pt_3.y: ",pt_3.y) end
		return true,pt_3
	end
	return false
end

--水平方向上的碰撞检测
function body:ifCollistionH()
	local _offX = 0
	local _map = self:getMap()
	local pt_1,pt_2
	local _bol = (self.m_direction == H_DirectionType.right)
	if _bol then
		pt_1 = self:getPtRightTop()			--需要检测的有右上和右下边界
		pt_2 = self:getPtRightDown()
		pt_1.x = pt_1.x+_offX
		pt_2.x = pt_2.x+_offX

		if pt_1.x>=display.width then				--首先判断是否到了边界
			return true
		end
	else
		pt_1 = self:getPtLeftTop()			--需要检测的有左上和左下边界
		pt_2 = self:getPtLeftDown()
		pt_1.x = pt_1.x-_offX
		pt_2.x = pt_2.x-_offX
		if pt_1.x<=0 then				--首先判断是否到了边界
			return true
		end
	end

	if self:bIsMaria() then
		local mapX,mapY = _map:getPosition()
		pt_1 = cc.p((pt_1.x - mapX),(pt_1.y - mapY))  --得到玛丽在地图上的像素坐标
		pt_2 = cc.p((pt_2.x - mapX),(pt_2.y - mapY))
	end
	if sdfgh then
		print("像素pt_2: ",pt_2.x,pt_2.y)
	end
	local _x 
	if _bol then 
		_x = 1		--如果方向为向右，则在两块之间时得到右面的块
	else
		_x = -1		--如果方向为向左，则在两块之间时得到左面的块
	end
	pt_3 = cc.p((pt_1.x+pt_2.x)/2,(pt_1.y+pt_2.y)/2)

	pt_1 = _map:positionToTileCoord(pt_1,{x = _x,y=-1})										  --得到玛丽在地图上的块坐标
	pt_2 = _map:positionToTileCoord(pt_2,{x = _x,y=1})
	pt_3 = _map:positionToTileCoord(pt_3,{x = _x})

	if sdfgh then
		print("块pt_2: ",pt_2.x,pt_2.y)
	end
	
	if self:isColliSionTile(pt_1) or self:isColliSionTile(pt_2) or self:isColliSionTile(pt_3) then
		if sdfgh then
			print(self:isColliSionTile(pt_1),self:isColliSionTile(pt_2),self:isColliSionTile(pt_3))
		end
		return true
	end
	if sdfgh then
		print("返回false")
	end
	return false
end


function body:getPtLeftTop()
	local rect = self._spr:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	position.y = position.y + rect.height
	return position
end

function body:getPtLeftDown()
	local rect = self._spr:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x - rect.width/2
	return position
end

function body:getPtRightTop()
	local rect = self._spr:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width/2
	position.y = position.y + rect.height
	return position
end

function body:getPtRightDown()
	local rect = self._spr:getBoundingBox()
	local position = cc.p(self:getPositionX(),self:getPositionY())
	position.x = position.x + rect.width /2
	return position
end

return body