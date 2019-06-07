misc={}

LoadTexture('misc','THlib\\misc\\misc.png')
LoadImage('player_aura','misc',128,0,64,64)
LoadImageGroup('bubble','misc',192,0,64,64,1,4)
LoadImage('boss_aura','misc',0,128,128,128)
SetImageState('boss_aura','mul+add',Color(0x80FFFFFF))
LoadImage('border','misc',128,192,64,64)
LoadImage('leaf','misc',0,32,32,32)
LoadImage('white','misc',56,8,16,16)
LoadTexture('particles','THlib\\misc\\particles.png')
LoadImageGroup('parimg','particles',0,0,32,32,4,4)
LoadImageFromFile('img_void','THlib\\misc\\img_void.png')

hinter=Class(object)

function hinter:init(img,size,x,y,t1,t2,fade)
	self.img=img
	self.x=x
	self.y=y
	self.t1=t1
	self.t2=t2
	self.fade=fade
	self.group=GROUP_GHOST
	self.layer=LAYER_TOP
	self.size=size
	self.t=0
	self.hscale=self.size
end

function hinter:frame()
	if self.timer<self.t1 then
		self.t=self.timer/self.t1
	elseif self.timer<self.t1+self.t2 then
		self.t=1
	elseif self.timer<self.t1*2+self.t2 then
		self.t=(self.t1*2+self.t2-self.timer)/self.t1
	else
		Del(self)
	end
end

function hinter:render()
	if self.fade then
		SetImageState(self.img,'',Color(self.t*255,255,255,255))
		self.vscale=self.size
		object.render(self)
	else
		SetImageState(self.img,'',Color(0xFFFFFFFF))
		self.vscale=self.t*self.size
		object.render(self)
	end
end

bubble=Class(object)

function bubble:init(img,x,y,life_time,size1,size2,color1,color2,layer,blend)
	self.img=img
	self.x=x
	self.y=y
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=layer
	self.blend=blend or ''
end

function bubble:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetImageState(self.img,self.blend,c)
	Render(self.img,self.x,self.y,0,size)
end

function bubble:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end

bubble2=Class(object)

function bubble2:init(img,x,y,vx,vy,life_time,size1,size2,color1,color2,layer,blend)
	self.img=img
	self.x=x
	self.y=y
	self.vx=vx
	self.vy=vy
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=layer
	self.blend=blend or ''
end

function bubble2:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetImageState(self.img,self.blend,c)
	Render(self.img,self.x,self.y,0,size)
end

function bubble2:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end

float_text=Class(object)

function float_text:init(fnt,text,x,y,v,angle,life_time,size1,size2,color1,color2)
	self.fnt=fnt
	self.text=text
	self.x=x
	self.y=y
	self.vx=v*cos(angle)
	self.vy=v*sin(angle)
	self.group=GROUP_GHOST
	self.life_time=life_time
	self.size1=size1
	self.size2=size2
	self.color1=color1
	self.color2=color2
	self.layer=LAYER_TOP
end

function float_text:render()
	local t=(self.life_time-self.timer)/self.life_time
	local size=self.size1*t+self.size2*(1-t)
	local c=self.color1*t+self.color2*(1-t)
	SetFontState(self.fnt,'',c)
	RenderText(self.fnt,self.text,self.x,self.y,size,'centerpoint')
end
function float_text:frame()
	if self.timer==self.life_time-1 then
		Del(self)
	end
end
--

function misc.RenderRing(img,x,y,r1,r2,rot,n,nimg)
	local da=360/n
	for i=1,n do
		local a=rot-da*i
		Render4V(img..((i-1)%nimg+1),
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end
--
function misc.Renderhp(x,y,rot,la,r1,r2,n,c)
	local da=la/n
	local nn=int(n*c)
	for i=1,nn do
		local a=rot+da*i
		Render4V('hpbar1',
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end
function misc.Renderhpbar(x,y,rot,la,r1,r2,n,c)
	local da=la/n
	local nn=int(n*c)
	for i=1,nn do
		local a=rot+da*i
		Render4V('hpbar2',
			r1*cos(a+da)+x,r1*sin(a+da)+y,0.5,
			r2*cos(a+da)+x,r2*sin(a+da)+y,0.5,
			r2*cos(a)+x,r2*sin(a)+y,0.5,
			r1*cos(a)+x,r1*sin(a)+y,0.5)
	end
end
--
shaker_maker=Class(object)

function shaker_maker:init(time,size)
	lstg.tmpvar.shaker=self
	self.time=time
	self.size=size
	self.l=lstg.world.l
	self.r=lstg.world.r
	self.b=lstg.world.b
	self.t=lstg.world.t
end

function shaker_maker:frame()
	local a=int(self.timer/3)*360/5*2
	local x=self.size*cos(a)
	local y=self.size*sin(a)
	lstg.world.l=self.l+x
	lstg.world.r=self.r+x
	lstg.world.b=self.b+y
	lstg.world.t=self.t+y
	if self.timer==self.time then
		Del(self)
	end
end

function shaker_maker:del()
	lstg.world.l=self.l
	lstg.world.r=self.r
	lstg.world.b=self.b
	lstg.world.t=self.t
	lstg.tmpvar.shaker=nil
end

function shaker_maker:kill()
	lstg.world.l=self.l
	lstg.world.r=self.r
	lstg.world.b=self.b
	lstg.world.t=self.t
	lstg.tmpvar.shaker=nil
end

function misc.ShakeScreen(t,s)
	if lstg.tmpvar.shaker then
		lstg.tmpvar.shaker.time=t
		lstg.tmpvar.shaker.size=s
		lstg.tmpvar.shaker.timer=0
	else
		New(shaker_maker,t,s)
	end
end

tasker=Class(object)
function tasker:init(f,group)
	self.group=group or GROUP_GHOST
	task.New(self,f)
end
function tasker:frame()
	task.Do(self)
	if coroutine.status(self.task[1])=='dead' then
		Del(self)
	end
end

ParticleKepper=Class(object)

function ParticleKepper:frame()
	if ParticleGetn(self)==0 then
		Del(self)
	end
end

function misc.KeepParticle(o)
	o.class=ParticleKepper
	PreserveObject(o)
	ParticleStop(o)
	o.bound=false
	o.group=GROUP_GHOST
end

shutter=Class(object)

function shutter:init(mode)
	self.layer=LAYER_TOP+100
	self.group=GROUP_GHOST
	self.open=(mode=='open')
end

function shutter:frame()
	if self.timer==60 then
		Del(self)
	end
end
if setting.resx>setting.resy then
	function shutter:render()
		SetViewMode'ui'
		SetImageState('white','',Color(0xFF000000))
		if self.open then
			for i=0,15 do
				RenderRect('white',(i+1-min(max(1-self.timer/30+i/16,0),1))*40,(i+1)*40,0,480)
			end
		else
			for i=0,15 do
				RenderRect('white',i*40,(i+min(max(self.timer/30-i/16,0),1))*40,0,480)
			end
		end
	end
else
	function shutter:render()
		SetViewMode'ui'
		SetImageState('white','',Color(0xFF000000))
		if self.open then
			for i=0,15 do
				RenderRect('white',(i+1-min(max(1-self.timer/30+i/16,0),1))*24.75,(i+1)*24.75,0,528)
			end
		else
			for i=0,15 do
				RenderRect('white',i*24.75,(i+min(max(self.timer/30-i/16,0),1))*24.75,0,528)
			end
		end
	end
end

mask_fader=Class(object)

function mask_fader:init(mode)
	self.layer=LAYER_TOP+100
	self.group=GROUP_GHOST
	self.open=(mode=='open')
end

function mask_fader:frame()
	if self.timer==30 then
		Del(self)
	end
end

function mask_fader:render()
	SetViewMode'ui'
	if self.open then
		SetImageState('white','',Color(255-self.timer*8.5,0,0,0))
	else
		SetImageState('white','',Color(self.timer*8.5,0,0,0))
	end
	if setting.resx>setting.resy then
		RenderRect('white',0,640,0,480)
	else
		RenderRect('white',0,396,0,528)
	end
end

function renderstar(x,y,r,point)
	local ang=360/(2*point)
	for angle=360/point,360,360/point do
		local x1,y1=x+r*cos(angle+ang)^3,r*sin(angle+ang)^3
		local x2,y2=x+r*cos(angle-ang)^3,r*sin(angle-ang)^3
		SetImageState('white','mul+sub',Color(255,100,100,100),
		Color(255,255,255,255),
		Color(255,0,0,0),
		Color(255,0,0,0))
		Render4V('white',x,y,0.5,
		x,y,0.5,
		x1,y1,0.5,
		x2,y2,0.5)
		SetImageState('white','',Color(255,255,255,255))
	end
end

function rendercircle(x,y,r,point)
	local ang=360/(2*point)
	for angle=360/point,360,360/point do
		local x1,y1=x+r*cos(angle+ang),y+r*sin(angle+ang)
		local x2,y2=x+r*cos(angle-ang),y+r*sin(angle-ang)
		SetImageState('white','add+sub',Color(255,255,255,255),
		Color(255,255,255,255),
		Color(255,0,0,0),
		Color(255,0,0,0))
		Render4V('white',x,y,0.5,
		x,y,0.5,
		x1,y1,0.5,
		x2,y2,0.5)
	end
end

