laser_bent=Class(object)

function laser_bent:init(index,x,y,l,w,sample,node)
	self.index=index
	self.x=x self.y=y
	self.l=max(int(l),2) self.w=w
	self.group=GROUP_INDES
	self.layer=LAYER_ENEMY_BULLET
	self.data=BentLaserData()
	self._data=BentLaserData()
	self.bound=false
	self._bound=true
	self.prex=x
	self.prey=y
	self.listx={}
	self.listy={}
	self.node=node or 0
	self._l=int(l/4)
	self.img4='laser_node'..int((self.index+1)/2)
	if sample==0 then
		self.class=laser_bent_elec
	end
--	for i=1,self._l do
--		self.listx[i]=self.x
--		self.listy[i]=self.y
--		end
	setmetatable(self,{__index=GetAttr,__newindex=laser_bent_meta_newindex})
end

function laser_bent_meta_newindex(t,k,v)
	if k=='bound' then rawset(t,'_bound',v)
	else SetAttr(t,k,v) end
end

function laser_bent:frame()
	task.Do(self)
	local _l=self._l
	if self.timer%4==0 then
	self.listx[(self.timer/4)%_l]=self.x
	self.listy[(self.timer/4)%_l]=self.y
	end
	self.data:Update(self,self.l,self.w)
	self._data:Update(self,self.l,self.w+48)
	if self.colli and self.data:CollisionCheck(player.x,player.y) then player.class.colli(player,self) end
	if self.timer%4==0 then
		if self.colli and self._data:CollisionCheck(player.x,player.y) then item.PlayerGraze() player.grazer.grazed=true end
	end
	if self._bound and not self.data:BoundCheck() and
		not BoxCheck(self,lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt) then
			Del(self)
	end
end

function laser_bent:render()
	self.data:Render('laser3','mul+add',Color(0xFFFFFFFF),0,self.index*16-12,256,8)
	if self.timer<self._l*4 and self.node then
		local c=Color(255,255,255,255)
		SetImageState(self.img4,'mul+add',c)
		Render(self.img4,self.prex,self.prey,-3*self.timer,(8+self.timer%3)*0.125*self.node/8)
		Render(self.img4,self.prex,self.prey,-3*self.timer+180,(8+self.timer%3)*0.125*self.node/8)
	end
end
function laser_bent:del()
	PreserveObject(self)
	if self.class~=laser_bent_death_ef then
		self.class=laser_bent_death_ef
		self.group=GROUP_GHOST
		self.timer=0
		task.Clear(self)
	end
end

function laser_bent:kill()
	PreserveObject(self)
	if self.class~=laser_bent_death_ef then
		for i=0,self._l do
			if self.listx[i] and self.listy[i] then
				New(item_faith_minor,self.listx[i],self.listy[i])
				if self.index and i%2==0 then New(BulletBreak,self.listx[i],self.listy[i],self.index) end
			end
		end
		self.class=laser_bent_death_ef
		self.group=GROUP_GHOST
		self.timer=0
		task.Clear(self)
	end
end

laser_bent_death_ef=Class(Object)
function laser_bent_death_ef:frame()
	if self.timer==30 then Del(self) end
end
function laser_bent_death_ef:render()
	self.data:Render('laser3','mul+add',Color(255-8.5*self.timer,255,255,255),0,self.index*16-12,256,8)
end

---------------------------------------------------
LoadTexture('laser_bent2','THlib\\laser\\laser5.png')
laser_bent_elec=Class(object)
function laser_bent_elec:init(index,x,y,l,w,sample,node)
	self.index=index
	self.x=x self.y=y
	self.l=max(int(l),2) self.w=w
	self.group=GROUP_INDES
	self.layer=LAYER_ENEMY_BULLET
	self.data=BentLaserData()
	self._data=BentLaserData()
	self.bound=false
	self._bound=true
	self.prex=x
	self.prey=y
	self.node=node or 0
	self.listx={}
	self.listy={}
	self._l=int(l/4)
	self.img4='laser_node'..int((self.index+1)/2)
	setmetatable(self,{__index=GetAttr,__newindex=laser_bent_meta_newindex})
end

function laser_bent_meta_newindex(t,k,v)
	if k=='bound' then rawset(t,'_bound',v)
	else SetAttr(t,k,v) end
end

function laser_bent_elec:frame()
	task.Do(self)
	local _l=self._l
	if self.timer%4==0 then
	self.listx[(self.timer/4)%_l]=self.x
	self.listy[(self.timer/4)%_l]=self.y
	end
	self.data:Update(self,self.l,self.w)
	self._data:Update(self,self.l,self.w+48)
	if self.colli and self.data:CollisionCheck(player.x,player.y) then player.class.colli(player,self) end
	if self.timer%4==0 then
		if self.colli and self._data:CollisionCheck(player.x,player.y) then item.PlayerGraze() player.grazer.grazed=true end
	end
	if self._bound and not self.data:BoundCheck() and
		not BoxCheck(self,lstg.world.boundl,lstg.world.boundr,lstg.world.boundb,lstg.world.boundt) then
			Del(self)
	end
end

function laser_bent_elec:render()
	self.data:Render('laser_bent2','mul+add',Color(0xFFFFFFFF),0,32*(int(0.5*self.timer)%4),256,32)
	if self.timer<self._l*4 and self.node then
		local c=Color(255,255,255,255)
		SetImageState(self.img4,'mul+add',c)
		Render(self.img4,self.prex,self.prey,-3*self.timer,(8+self.timer%3)*0.125*self.node/8)
		Render(self.img4,self.prex,self.prey,-3*self.timer+180,(8+self.timer%3)*0.125*self.node/8)
	end
end
function laser_bent_elec:del()
	PreserveObject(self)
	if self.class~=laser_bent_death_ef then
		self.class=laser_bent2_death_ef
		self.group=GROUP_GHOST
		self.timer=0
		task.Clear(self)
	end
end

function laser_bent_elec:kill()
	PreserveObject(self)
	if self.class~=laser_bent_death_ef then
		for i=0,self._l do
			if self.listx[i] and self.listy[i] then
				New(item_faith_minor,self.listx[i],self.listy[i])
			end
		end
		self.class=laser_bent2_death_ef
		self.group=GROUP_GHOST
		self.timer=0
		task.Clear(self)
	end
end

laser_bent2_death_ef=Class(Object)
function laser_bent2_death_ef:frame()
	if self.timer==30 then Del(self) end
end
function laser_bent2_death_ef:render()
	self.data:Render('laser_bent2','mul+add',Color(255-8.5*self.timer,255,255,255),0,32*(int(0.5*self.timer)%4),256,32)
end
-------------------------------------------

function laser_bent_death_ef:del() self.data:Release() end
function laser_bent_death_ef:kill() self.data:Release() end
function laser_bent2_death_ef:del() self.data:Release() end
function laser_bent2_death_ef:kill() self.data:Release() end

