cube_background=Class(object)

function cube_background:init()
	--
	background.init(self,false)
	--
	LoadImageFromFile('cube','THlib\\background\\cube\\cube.png')
	--
	Set3D('eye',0,3.3,-3.8)
	Set3D('at',0,1.5,-0.4)
	Set3D('up',-1.8,1,0)
	Set3D('z',1,100)
	Set3D('fovy',0.6)
	Set3D('fog',3,10,Color(0xFF1E46FF))
	--
	self.z=0
	self.speed=0.01
	--
end

function cube_background:frame()
	self.z=self.z+self.speed
end

function cube_background:render()
	SetViewMode'3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	
	RenderClear(lstg.view3d.fog[3])
	local long = 1
	local st = 0.5
	for j=4,-2,-1 do
		for i=-2,2,1 do
			for k=0,1 do
				local dz=j*2-math.mod(self.z,2)
				local dy=i*2
				local dx=k*2
				Render4V('cube',	-(st+dx),0+long+dy,dz,
									-(st+long+dx),0+long+dy,dz,
									-(st+long+dx),0+dy,dz,
									-(st+dx),0+dy,dz)
				Render4V('cube',	-(st+dx),0+long+dy,dz,
									-(st+dx),0+long+dy,dz+long,
									-(st+dx),0+dy,dz+long,
									-(st+dx),0+dy,dz)
				Render4V('cube',	-(st+dx),0+long+dy,dz+long,
									-(st+long+dx),0+long+dy,dz+long,
									-(st+long+dx),0+long+dy,dz,
									-(st+dx),0+long+dy,dz)
			end
		end
	end
	for j=4,-2,-1 do
		for i=-2,2,1 do
			for k=0,1 do
				local dz=j*2-math.mod(self.z,2)
				local dy=i*2
				local dx=k*2
				Render4V('cube',	(st+dx),0+long+dy,dz,
									(st+long+dx),0+long+dy,dz,
									(st+long+dx),0+dy,dz,
									(st+dx),0+dy,dz)
				Render4V('cube',	(st+dx),0+long+dy,dz,
									(st+dx),0+long+dy,dz+long,
									(st+dx),0+dy,dz+long,
									(st+dx),0+dy,dz)
				Render4V('cube',	(st+dx),0+long+dy,dz+long,
									(st+long+dx),0+long+dy,dz+long,
									(st+long+dx),0+long+dy,dz,
									(st+dx),0+long+dy,dz)
			end
		end
	end
	
	if showboss then
		local x,y = WorldToScreen(_boss.x,_boss.y)
		local x1 = x * screen.scale
		local y1 = (screen.height - y) * screen.scale
		local fxr = _boss.fxr or 163
		local fxg = _boss.fxg or 73
		local fxb = _boss.fxb or 164
		PostEffectApply("boss_distortion", "", {
			centerX = x1,
			centerY = y1,
			size = _boss.aura_alpha*200*lstg.scale_3d,
			color = Color(125,fxr,fxg,fxb),
			colorsize = _boss.aura_alpha*200*lstg.scale_3d,
			arg=1500*_boss.aura_alpha/128*lstg.scale_3d,
			timer = self.timer
        })
	end
	SetViewMode'world'
end
