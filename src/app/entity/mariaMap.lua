local mariaMap = class("mariaMap", function ()
	return display.newNode()
end)

TileType = {}
TileType.eTile_None 			= 0		--什么也没有
TileType.eTile_Monster_image	= 1		--怪物对应的图块
TileType.eTile_Object_image 	= 2		--对象物体对应的图块
TileType.eTile_Barrier 			= 3		--各种障碍物，（地板、石块、管道）
TileType.eTile_Ground 		    = 4		--陆地背景，树、栅栏等装饰物
TileType.eTile_Mountain 		= 5		--山
TileType.eTile_Cloud 			= 6		--云
TileType.eTile_Pillar 			= 7		--背景柱子
TileType.eTile_BackGround 		= 8	--背景天空
TileType.eTile_Bounder  		= 9  	--边界

function mariaMap:ctor(tmxPath)
	self.tmxPath = tmxPath
	local map = ccexp.TMXTiledMap:create(tmxPath)
					:addTo(self)

	self.tileSize = map:getTileSize()   --每一块的像素大小
	self.mapSize = map:getMapSize()		--一共有多少块

	self.m_monster_image = map:getLayer("monster_image")	 --怪物对应的图块
	self.m_object_image = map:getLayer("object_image")		 --对象物体对应的图块
	self.m_barrier = map:getLayer("barrier")				     --各种障碍物，（地板、石块、管道）
	self.m_ground = map:getLayer("ground")				     --陆地背景，树、栅栏等装饰物
	self.m_mountain = map:getLayer("hill")		         --山
	self.m_cloud = map:getLayer("cloud")			         --云
	self.m_pillar = map:getLayer("pillar")			         --背景柱子
	self.m_background = map:getLayer("background")			 --背景天空

	self.m_objectGroup = map:getObjectGroup("object")		 --对象

	printTable(self.tileSize)
	printTable(self.mapSize)
end

--offSet是处理刚好两个砖块之间的情况，格式为{x,y}，x>0表示取右边，y>0表示取上边，小于0以此类推
function mariaMap:positionToTileCoord(pos,offSet)
	offSet.x = offSet.x or 0
	offSet.y = offSet.y or 0
	if math.mod(pos.x,self.tileSize.width) ==0 and math.mod(pos.y,self.tileSize.height) ==0 then  --四个块中间
		pos.x = pos.x + offSet.x
		pos.y = pos.y + offSet.y
	elseif math.mod(pos.x,self.tileSize.width) ==0 then				--横向两块之间
		pos.x = pos.x + offSet.x
	elseif math.mod(pos.y,self.tileSize.height) ==0 then			--纵向两块之间
		pos.y = pos.y + offSet.y		
	end
	-- if pos.y==31.5 then
	-- 	print("-------------地图Y坐标：31.5")
	-- 	print(self.mapSize.height)
	-- 	print(pos.y / self.tileSize.height)
	-- 	print((self.mapSize.height - 1)-math.floor(pos.y / self.tileSize.height))
	-- 	print(math.floor((self.mapSize.height - 1) - pos.y / self.tileSize.height))
	-- end
	local x = math.floor(pos.x / self.tileSize.width)
	--local y = math.floor((self.mapSize.height - 1) - pos.y / self.tileSize.height)
	local y = (self.mapSize.height - 1)-math.floor(pos.y / self.tileSize.height)
	return cc.p(x, y)
end

--通过块坐标获得实际坐标，依次是左下角，左上角，右下角，右上角
function mariaMap:tilecoordToPosition(tileCoord)
	local x = tileCoord.x * self.tileSize.width;
	local y = (self.mapSize.height - 1 - tileCoord.y) * self.tileSize.height
	local ret_1 = cc.p(x, y)
	local ret_2 = cc.p(x,y+self.tileSize.height)
	local ret_3 = cc.p(x+self.tileSize.width,y)
	local ret_4 = cc.p(x+self.tileSize.width,y+self.tileSize.height)
	return ret_1,ret_2,ret_3,ret_4
end

function mariaMap:tileTypeforPos(tileCoord)
	if tileCoord.x<0 or tileCoord.x>=self.mapSize.width or tileCoord.y<0 or tileCoord.y>=self.mapSize.height then
		return TileType.eTile_None
	end
	local GID = self.m_monster_image:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Monster_image
	end

	GID = self.m_object_image:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Object_image
	end

	GID = self.m_barrier:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Barrier
	end

	GID = self.m_ground:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Ground
	end

	GID = self.m_mountain:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Mountain
	end

	GID = self.m_cloud:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Cloud
	end

	GID = self.m_pillar:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_Pillar
	end

	GID = self.m_background:getTileGIDAt(tileCoord)
	if GID > 0 then
		return TileType.eTile_BackGround
	end

end

return mariaMap