laser_texture_num = 1
laser_data = {}
function LoadLaserTexture(text,l1,l2,l3)

	local n = laser_texture_num
	local texture = 'laser'..n
	LoadTexture(texture,'THlib\\laser\\'..text..'.png')
	LoadImageGroup(texture..1,texture,    0,0, l1,16,1,16)
	LoadImageGroup(texture..2,texture,   l1,0, l2,16,1,16)
	LoadImageGroup(texture..3,texture,l1+l2,0, l3,16,1,16)
	for i=1,3 do
		for j=1,16 do
			SetImageCenter(texture..i..j,0,8)
		end
	end
	laser_data[n] = {l1,l2,l3}
	laser_texture_num = n + 1
end

LoadLaserTexture('laser1', 64,128, 64)
LoadLaserTexture('laser2',  5,236, 15)
LoadLaserTexture('laser3',127,  1,128)
LoadLaserTexture('laser4',  1,254,  1)

LoadImageGroup('laser_node','bullet1',80,0,32,32,1,8)

laser=Class(object)

function laser:init(index,x,y,rot,l1,l2,l3,w,node,head)
	self.index=max(min(int(index),16),1)
	self.imgid=1
	self.img1='laser11'..self.index
	self.img2='laser12'..self.index
	self.img3='laser13'..self.index
	self.img4='laser_node'..int((self.index+1)/2)
	self.img5='ball_mid_b'..int((self.index+1)/2)
	self.x=x self.y=y self.rot=rot
	self.prex=x self.prey=y
	self.l1=l1 self.l2=l2 self.l3=l3 self.w0=w self.w=0
	self.alpha=0
	self.node=node or 0
	self.head=head or 0
	self.group=GROUP_INDES
	self.layer=LAYER_ENEMY_BULLET
	self.a=0
	self.b=0
	self.dw=0
	self.da=0
	self.counter=0
end

function laser:frame()
	task.Do(self)
	if self.counter>0 then
		self.counter=self.counter-1
		self.w=self.w+self.dw
		self.alpha=self.alpha+self.da
	end
	if self.alpha>0.999 and self.colli then
		local x=player.x-self.x
		local y=player.y-self.y
		local rot=self.rot
		local dist=2
		x,y=x*cos(rot)+y*sin(rot),y*cos(rot)-x*sin(rot)
		y=abs(y)
		if x>0 then
			if x<self.l1 then
				if y<x/self.l1*self.w/dist then player.class.colli(player,self) end
			elseif x<self.l1+self.l2 then
				if y<self.w/dist then player.class.colli(player,self) end
			elseif x<self.l1+self.l2+self.l3 then
				if y<(self.l1+self.l2+self.l3-x)/self.l3*self.w/dist then player.class.colli(player,self) end
			end
			if self.timer%4==0 then
				if x<self.l1 then
					if y<x/self.l1*self.w/dist+16 then item.PlayerGraze() player.grazer.grazed=true end
				elseif x<self.l1+self.l2 then
					if y<self.w/dist+16 then item.PlayerGraze() player.grazer.grazed=true end
				elseif x<self.l1+self.l2+self.l3 then
					if y<(self.l1+self.l2+self.l3-x)/self.l3*self.w/dist+16 then item.PlayerGraze() player.grazer.grazed=true end
				end
			end
		end
	end
end

function laser:render()
	if self.w>0 then
		local c=Color(255*self.alpha,255,255,255)
		local data = laser_data[self.imgid]
		local l=(self.l1+self.l2+self.l3)*0.95
		SetImageState(self.img1,'mul+add',c)
		Render(self.img1,self.x,self.y,self.rot,self.l1/data[1],self.w/7)
		SetImageState(self.img2,'mul+add',c)
		Render(self.img2,self.x+self.l1*cos(self.rot),self.y+self.l1*sin(self.rot),self.rot,self.l2/data[2],self.w/7)
		SetImageState(self.img3,'mul+add',c)
		Render(self.img3,self.x+(self.l1+self.l2)*cos(self.rot),self.y+(self.l1+self.l2)*sin(self.rot),self.rot,self.l3/data[3],self.w/7)
		if self.node>0 then
			c=Color(255*self.w/self.w0,255,255,255)
			SetImageState(self.img4,'mul+add',c)
			Render(self.img4,self.x,self.y, 18*self.timer,self.node/8)
			Render(self.img4,self.x,self.y,-18*self.timer,self.node/8)
		end
		if self.head>0 then
			c=Color(255*self.w/self.w0,255,255,255)
			SetImageState(self.img5,'mul+add',c)
			Render(self.img5,self.x+l*cos(self.rot),self.y+l*sin(self.rot),0,self.head/8)
			Render(self.img5,self.x+l*cos(self.rot),self.y+l*sin(self.rot),0,0.75*self.head/8)
		end
	end
end

function laser:del()
	PreserveObject(self)
	if self.class~=laser_death_ef then
		self.class=laser_death_ef
		self.group=GROUP_GHOST
		local alpha=self.alpha
		local d=self.w
		task.Clear(self)
		task.New(self,function()
			for i=1,30 do
				self.alpha=self.alpha-alpha/30
				self.w=self.w-d/30
				task.Wait()
			end
			Del(self)
		end)
	end
end

function laser:kill()
	PreserveObject(self)
	if self.class~=laser_death_ef then
		local cx, cy = cos(self.rot), sin(self.rot)
		for l=0,self.l1+self.l2+self.l3,12 do
			New(item_faith_minor,self.x+l*cx,self.y+l*cy)
			if self.index and l%2==0 then New(BulletBreak,self.x+l*cx,self.y+l*cy,self.index) end
		end
		self.class=laser_death_ef
		self.group=GROUP_GHOST
		local alpha=self.alpha
		local d=self.w
		task.Clear(self)
		task.New(self,function()
			for i=1,30 do
				self.alpha=self.alpha-alpha/30
				self.w=self.w-d/30
				task.Wait()
			end
			Del(self)
		end)
	end
end

function laser:ChangeImage(id, index)
	self.imgid = max(min(int(id),laser_texture_num-1),1)
	if index then self.index = max(min(int(index),16),1) end
	local index = self.index
	local id = self.imgid
	self.img1 = 'laser'..id..'1'..index
	self.img2 = 'laser'..id..'2'..index
	self.img3 = 'laser'..id..'3'..index
end

function laser:grow(time, mute, wait)
	if mute then PlaySound('lazer00',0.25,self.x/200) end
	if time == 0 then return end
	local l1, l2, l3 = self.l1, self.l2, self.l3
	local add = (l1 + l2 + l3) / time
	self.l1, self.l2, self.l3 = 0, 0, 0
	self.alpha = 1
	self.w = self.w0
	task.New(self, function()
		for i = 1,time do
			if not IsValid(self) then
				break
			elseif self.l2 == l2 then
				self.l1 = self.l1 + add
			elseif self.l2 > l2 then
				self.l1 = self.l1 + add + self.l2 - l2
				self.l2 = l2
			elseif self.l3 == l3 then
				self.l2 = self.l2 + add
			elseif self.l3 > l3 then
				self.l2 = self.l2 + add + self.l3 - l3
				self.l3 = l3
			else
				self.l3 = self.l3 + add
			end
			task.Wait(1)
		end
		if IsValid(self) then self.l1 = l1 end
	end)
	if task.GetSelf()==self and wait then task.Wait(time) end
end

function laser:TurnOn(t,mute)
	t=t or 30
	t=max(1,int(t))
	if not mute then PlaySound('lazer00',0.25,self.x/200) end
	self.counter=t
	self.da=(1-self.alpha)/t
	self.dw=(self.w0-self.w)/t
end
function laser:TurnHalfOn(t)
	t=t or 30
	t=max(1,int(t))
	self.counter=t
	self.da=(0.5-self.alpha)/t
	self.dw=(0.5*self.w0-self.w)/t
end
function laser:TurnOff(t)
	t=t or 30
	t=max(1,int(t))
	self.counter=t
	self.da=-self.alpha/t
	self.dw=-self.w/t
end

laser_death_ef=Class(laser)
function laser_death_ef:frame() task.Do(self) end
function laser_death_ef:del() end
function laser_death_ef:kill() end


Include("THlib\\laser\\bent laser.lua")
