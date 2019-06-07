galaxy_background=Class(background)

function galaxy_background:init()
	background.init(self,false)
	LoadImageFromFile('galaxy','THlib\\background\\galaxy\\galaxy.png')
	LoadImageFromFile('galaxy2','THlib\\background\\galaxy\\timg.jpg')
	Set3D('z',0.8,8)
	Set3D('eye',0.0,-2,0)
	Set3D('at',0,0,2)
	Set3D('up',0,1,0)
	Set3D('fovy',0.35)
	Set3D('fog',0,0,Color(0x00000000))
	self.yos=0
	self.speed=0.03
end

function galaxy_background:frame()
	self.rot=self.rot-0.03
end

function galaxy_background:render()
--	SetViewMode'world'
--	Render('galaxy2',0,0,0,0.7)
	SetViewMode'3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end

--	RenderClear(lstg.view3d.fog[3])
	local rot=self.rot
	SetViewMode'world'
	Render('galaxy2',0,0,0,0.7)
	SetViewMode'3d'
	Render4V('galaxy',
		cos(rot),sin(rot),2,
		cos(rot-90),sin(rot-90),2,
		cos(rot-180),sin(rot-180),2,
		cos(rot-270),sin(rot-270),2
	)

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
