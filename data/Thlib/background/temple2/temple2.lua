temple2_background=Class(background)

function temple2_background:init()
	background.init(self,false)
	LoadImageFromFile('temple2_step','THlib\\background\\temple2\\t2_step.png')
	LoadImageFromFile('temple2','THlib\\background\\temple2\\t2_o3.png')
	LoadImageFromFile('temple2_torii','THlib\\background\\temple2\\t2_torii.png')
	LoadImageFromFile('temple2_fog','THlib\\background\\temple2\\t2_fog.png')
	LoadImageFromFile('temple2_ground','THlib\\background\\temple2\\t2_bg2.png')
	--Set3D('z',1.8,20)
	Set3D('z',1.8,11.1)
	Set3D('eye',0,0.8,-4.1)
	Set3D('at',0,0,0)
	Set3D('up',0,1,0)
	Set3D('fovy',1.75)
	--Set3D('fog',0,18,Color(0x00FFFFFF))
	Set3D('fog',3.8,6.5,Color(0x00DDDDDD))
	self.yos=0
	self.speed=0.004
end

function temple2_background:frame()
	self.yos=self.yos+self.speed
end

function temple2_background:render()
	SetViewMode'3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	
	RenderClear(lstg.view3d.fog[3])
	local y=self.yos%1
	local y2=self.yos%10
	for i=-5,4 do
		Render4V('temple2_step',-1.5,1-y+i,1-y+i,1.5,1-y+i,1-y+i,1.5,0-y+i,0-y+i,-1.5,0-y+i,0-y+i)
		Render4V('temple2_ground',-4.5,1-y+i,1-y+i,-1.5,1-y+i,1-y+i,-1.5,0-y+i,0-y+i,-4.5,0-y+i,0-y+i)
		Render4V('temple2_ground',1.5,1-y+i,1-y+i,4.5,1-y+i,1-y+i,4.5,0-y+i,0-y+i,1.5,0-y+i,0-y+i)
		Render4V('temple2_ground',-8.5,1-y+i,1-y+i,-4.5,1-y+i,1-y+i,-4.5,0-y+i,0-y+i,-8.5,0-y+i,0-y+i)
		Render4V('temple2_ground',4.5,1-y+i,1-y+i,8.5,1-y+i,1-y+i,8.5,0-y+i,0-y+i,4.5,0-y+i,0-y+i)
	end
	Render4V('temple2',-4,8,2.8,4,8,2.8,4,2,3,-4,2,3)
	
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
