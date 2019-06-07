skyandcloud_background=Class(background)

function skyandcloud_background:init()
	background.init(self,false)
	LoadTexture('magic_forest_ground','THlib\\background\\skyandcloud\\ground.png')
	LoadImage('magic_forest_ground','magic_forest_ground',0,360,1000,1300)
	LoadTexture('magic_forest_mask','THlib\\background\\skyandcloud\\mask.png')
	LoadImage('magic_forest_mask','magic_forest_mask',0,0,256,256)
	Set3D('z',1.8,4.5)
	Set3D('eye',0.25,-1.5,2)
	Set3D('at',0.2,0,0)
	Set3D('up',0,0,1)
	Set3D('fovy',0.35)
	Set3D('fog',0,0,Color(0x00000000))
	self.yos=0
	self.speed=0.03
end

function skyandcloud_background:frame()
	self.yos=self.yos+self.speed
end

function skyandcloud_background:render()
	SetViewMode'3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	
	RenderClear(lstg.view3d.fog[3])
	local y=self.yos%1
	for i=-1,2 do
		Render4V('magic_forest_ground',0,0-y+i,0,0,1-y+i,0,1,1-y+i,0,1,-y+i,0)
		Render4V('magic_forest_ground',-1,0-y+i,0,-1,1-y+i,0,0,1-y+i,0,0,-y+i,0)
	end
	for i=-1,3 do
		Render4V('magic_forest_mask',0,0-y+i,-0.2,0,1-y+i,-0.2,1,1-y+i,-0.2,1,-y+i,-0.2)
		Render4V('magic_forest_mask',-1,0-y+i,-0.2,-1,1-y+i,-0.2,0,1-y+i,-0.2,0,-y+i,-0.2)
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
