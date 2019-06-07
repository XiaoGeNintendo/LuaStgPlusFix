gensokyosora_background=Class(object)

function gensokyosora_background:init()
	background.init(self,false)
	LoadTexture('sora_1','THlib\\background\\gensokyosora\\sora_1.png')
	LoadTexture('sora_2','THlib\\background\\gensokyosora\\sora_2.png')
	LoadImageFromFile('fog_1','THlib\\background\\gensokyosora\\fog_1.png')
	LoadTexture('aosora','THlib\\background\\gensokyosora\\aosora.png')
	LoadImage('sora_1','sora_1',0,0,512,512)
	LoadImage('sora_2','sora_2',0,0,512,512)
	LoadImage('aosora','aosora',0,0,512,512)
	SetImageState('sora_2','',Color(0x64FFFFFF))
	SetImageState('aosora','',Color(0xFFFFFFFF))
	--set camera
	Set3D('eye',0.20,0.10,-1.30)
	Set3D('at',0.20,0.00,0.30)
	Set3D('up',0.00,2.90,5.70)
	Set3D('fovy',0.62)
	Set3D('z',0.01,6.60)
	Set3D('fog',3.00,3.70,Color(0,155,155,175))
	--
	self.zos=0
	self.speed=0.01
	--
end

function gensokyosora_background:frame()
	self.zos=self.zos+self.speed
end

function gensokyosora_background:render()
	SetViewMode'3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	
	RenderClear(lstg.view3d.fog[3])
	local z=self.zos%1
	for i=-1,6 do
		Render4V('sora_1',-1,-0.6,1-z+i, 1.4,-0.6,1-z+i, 1.4,-0.6,0-z+i,-1,-0.6,0-z+i)
	end
	for i=-1,4 do
		Render4V('sora_2',-0.8,-0.4,1-z+i, 1.6,-0.4,1-z+i, 1.6,-0.4,0-z+i,-0.8,-0.4,0-z+i)
	end
	for i=-5,6 do
		Render4V('fog_1',-0.5,-0.2,2-z+i,0,-0.2,2-z+i,0,-0.6,2-z+i,-0.5,-0.6,2-z+i)
		Render4V('fog_1',-0.4,-0.2,2.4-z+i,0.1,-0.2,2.4-z+i,0.1,-0.6,2.4-z+i,-0.4,-0.6,2.4-z+i)
		Render4V('fog_1',-0.1,-0.2,1.25-z+i,0.33,-0.2,1-z+i,0.33,-0.6,1-z+i,-0.1,-0.6,1.25-z+i)
		Render4V('fog_1',0.3,-0.2,2.4-z+i,0.8,-0.2,2.4-z+i,0.8,-0.6,2.4-z+i,0.3,-0.6,2.4-z+i)
	end
	Render4V('aosora',-1,1,0.5,1,1,0.5,1,-1,0.5,-1,-1,0.5)
	
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
