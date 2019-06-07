LoadTexture('item','THlib\\item\\item.png')
LoadImageGroup('item','item',0,0,32,32,2,5,8,8)
LoadImageGroup('item_up','item',64,0,32,32,2,5)
SetImageState('item8','mul+add',Color(0xC0FFFFFF))
LoadTexture('bonus1','THlib\\item\\item.png')
LoadTexture('bonus2','THlib\\item\\item.png')
LoadTexture('bonus3','THlib\\item\\item.png')

item=Class(object)

function item:init(x,y,t,v,angle)
	x=min(max(x,-184),184)
	self.x=x
	self.y=y
	angle=angle or 90
	v=v or 1.5
	SetV(self,v,angle)
	self.v=v
	self.group=GROUP_ITEM
	self.layer=LAYER_ITEM
	self.bound=false
	self.img='item'..t
	self.imgup='item_up'..t
	self.attract=0
end

function item:render()
	if self.y>224 then Render(self.imgup,self.x,216) else object.render(self) end
end

function item:frame()
	if self.timer<24 then
		self.rot=self.rot+45
		self.hscale=(self.timer+25)/48
		self.vscale=self.hscale
		if self.timer==22 then self.vy=min(self.v,2) self.vx=0 end
	elseif self.attract>0 then
		local a=Angle(self,player)
		self.vx=self.attract*cos(a)+player.dx*0.5
		self.vy=self.attract*sin(a)+player.dy*0.5
	else self.vy=max(self.dy-0.03,-1.7) end
	if self.y<-256 then Del(self) end
end

function item:colli(other)
	if other==player then
		if self.class.collect then self.class.collect(self) end
		Kill(self)
		PlaySound('item00',0.3,self.x/200)
	end
end

function GetPower(v)
	local before=int(lstg.var.power/100)
	lstg.var.power=min(400,lstg.var.power+v)
	local after=int(lstg.var.power/100)
	if after>before then PlaySound('powerup1',0.5) end
	if lstg.var.power>=400 then
		lstg.var.score=lstg.var.score+v*100
	end
--	if lstg.var.power==500 then
--		for i,o in ObjList(GROUP_ITEM) do
--			if o.class==item_power or o.class==item_power_large then
--				o.class=item_faith
--				o.img='item5'
--				o.imgup='item_up5'
--				New(bubble,'parimg12',o.x,o.y,16,0.5,1,Color(0xFF00FF00),Color(0x0000FF00),LAYER_ITEM+50)
--			end
--		end
--	end
end

item_power=Class(item)
function item_power:init(x,y,v,a) item.init(self,x,y,1,v,a) end
function item_power:collect() GetPower(1) end

item_power_large=Class(item)
function item_power_large:init(x,y,v,a) item.init(self,x,y,6,v,a) end
function item_power_large:collect() GetPower(100)  end

item_power_full=Class(item)
function item_power_full:init(x,y) item.init(self,x,y,4) end
function item_power_full:collect() GetPower(400)  end

item_extend=Class(item)
function item_extend:init(x,y) item.init(self,x,y,7) end
function item_extend:collect()
	lstg.var.lifeleft=lstg.var.lifeleft+1
	PlaySound('extend',0.5)
	New(hinter,'hint.extend',0.6,0,112,15,120)
end

item_chip=Class(item)
function item_chip:init(x,y) item.init(self,x,y,3)
--	PlaySound('bonus',0.8)
end
function item_chip:collect()
	lstg.var.chip=lstg.var.chip+1
	if lstg.var.chip==5 then
		lstg.var.lifeleft=lstg.var.lifeleft+1
		lstg.var.chip=0
		PlaySound('extend',0.5)
		New(hinter,'hint.extend',0.6,0,112,15,120)
	end
end
----------------------------
item_bombchip=Class(item)
function item_bombchip:init(x,y) item.init(self,x,y,9)
--	PlaySound('bonus2',0.8)
end
function item_bombchip:collect()
	lstg.var.bombchip=lstg.var.bombchip+1
	if lstg.var.bombchip==5 then
		lstg.var.bomb=lstg.var.bomb+1
		lstg.var.bombchip=0
		PlaySound('cardget',0.8)
	end
end
item_bomb=Class(item)
function item_bomb:init(x,y)  item.init(self,x,y,10)
end
function item_bomb:collect()
	lstg.var.bomb=lstg.var.bomb+1
	PlaySound('cardget',0.8)
end
----------------------------
item_faith=Class(item)
function item_faith:init(x,y) item.init(self,x,y,5) end
function item_faith:collect()
	local var=lstg.var
	New(float_text,'item','10000',self.x,self.y+6,0.75,90,60,0.5,0.5,Color(0x8000C000),Color(0x0000C000))
	var.faith=var.faith+100
--	var.score=var.score+10000
end

item_faith_minor=Class(object)
function item_faith_minor:init(x,y)
	self.x=x self.y=y
	self.img='item'..8
	self.group=GROUP_ITEM
	self.layer=LAYER_ITEM
	if not BoxCheck(self,lstg.world.l,lstg.world.r,lstg.world.b,lstg.world.t) then RawDel(self) end
	self.vx=ran:Float(-0.15,0.15)
	self._vy=ran:Float(3.25,3.75)
	self.flag=1
	self.attract=0
	self.bound=false
end
function item_faith_minor:frame()
	if player.death>80 and player.death<90 then self.flag=0 self.attract=0 end
	if self.timer<45 then
		self.vy=self._vy-self._vy*self.timer/45
	end
	if self.timer>=54 and self.flag==1 then
		SetV(self,8,Angle(self,player))
	end
	if self.timer>=54 and self.flag==0 then
		if self.attract>0 then
			local a=Angle(self,player)
			self.vx=self.attract*cos(a)+player.dx*0.5
			self.vy=self.attract*sin(a)+player.dy*0.5
		else self.vy=max(self.dy-0.03,-2.5) self.vx=0
		end
		if self.y<-256 then Del(self) end
	end
end
function item_faith_minor:colli(other)
	if other==player then
		if self.class.collect then self.class.collect(self) end
		Kill(self)
		PlaySound('item00',0.3,self.x/200)
	end
end
function item_faith_minor:collect()
	local var=lstg.var
	var.faith=var.faith+10
	var.score=var.score+500
end

item_point=Class(item)
function item_point:init(x,y) item.init(self,x,y,2) end
function item_point:collect()
	local var=lstg.var
	if self.attract==8 then
		New(float_text,'item',var.pointrate,self.x,self.y+6,0.75,90,60,0.5,0.5,Color(0x80FFFF00),Color(0x00FFFF00))
		var.score=var.score+var.pointrate
	else
		New(float_text,'item',int(var.pointrate/20)*10,self.x,self.y+6,0.75,90,60,0.5,0.5,Color(0x80FFFFFF),Color(0x00FFFFFF))
		var.score=var.score+int(var.pointrate/20)*10
	end
end

function item.DropItem(x,y,drop)
	local m
	if lstg.var.power==400 then
		m = drop[1]
	elseif drop[1] >= 400 then
		m = drop[1]
	else
		m = drop[1] / 100 + drop[1] % 100
	end
	local n=m+drop[2]+drop[3]
	if n<1 then return end
	local r=sqrt(n-1)*5
	--if lstg.var.power==500 then drop[2]=drop[2]+drop[1] drop[1]=0 end
	if drop[1] >= 400 then
		local r2=sqrt(ran:Float(1,4))*r
		local a=ran:Float(0,360)
		New(item_power_full,x+r2*cos(a),y+r2*sin(a))
	else
		drop[4] = drop[1] / 100
		drop[1] = drop[1] % 100
		for i=1,drop[4] do
			local r2=sqrt(ran:Float(1,4))*r
			local a=ran:Float(0,360)
			New(item_power_large,x+r2*cos(a),y+r2*sin(a))
		end
		for i=1,drop[1] do
			local r2=sqrt(ran:Float(1,4))*r
			local a=ran:Float(0,360)
			New(item_power,x+r2*cos(a),y+r2*sin(a))
		end
	end
	for i=1,drop[2] do
		local r2=sqrt(ran:Float(1,4))*r
		local a=ran:Float(0,360)
		New(item_faith,x+r2*cos(a),y+r2*sin(a))
	end
	for i=1,drop[3] do
		local r2=sqrt(ran:Float(1,4))*r
		local a=ran:Float(0,360)
		New(item_point,x+r2*cos(a),y+r2*sin(a))
	end
end

item.sc_bonus_max=2000000
item.sc_bonus_base=1000000

function item.StartChipBonus()
	lstg.var.chip_bonus=true
	lstg.var.bombchip_bonus=true
end

function item.EndChipBonus(x,y)
	if lstg.var.chip_bonus and lstg.var.bombchip_bonus then
			New(item_chip,x-20,y)
			New(item_bombchip,x+20,y)
	else
		if lstg.var.chip_bonus then New(item_chip,x,y) end
		if lstg.var.bombchip_bonus then New(item_bombchip,x,y) end
	end
end

function item.PlayerInit()
	lstg.var.power=100
	lstg.var.lifeleft=2
	lstg.var.bomb=3
	lstg.var.bonusflag=0
	lstg.var.chip=0
	lstg.var.faith=0
	lstg.var.graze=0
	lstg.var.score=0
	lstg.var.bombchip=0
	lstg.var.coun_num=0
	lstg.var.pointrate=item.PointRateFunc(lstg.var)
	lstg.var.block_spell=false
	lstg.var.chip_bonus=false
	lstg.var.bombchip_bonus=false
	lstg.var.init_player_data=true
end
------------------------------------------
function item.PlayerReinit()
	lstg.var.power=400
	lstg.var.lifeleft=2
	lstg.var.chip=0
	lstg.var.bomb=2
	lstg.var.bomb_chip=0
	lstg.var.block_spell=false
	lstg.var.init_player_data=true
	lstg.var.coun_num=min(9,lstg.var.coun_num+1)
	lstg.var.score=lstg.var.coun_num
	--if lstg.var.score % 10 ~= 9 then item.AddScore(1) end
end
------------------------------------------
--HZC的收点系统
function item.playercollect(z)
	New(tasker,function()
		local Z=0.5+0.03*(z-30)
		local var=lstg.var
		if z>=30 and z<80 then
			if lstg.var.bonusflag==4 then
				task.Wait(45)
				local x=player.x
				local y=player.y
				PlaySound('pin00',0.8)
				task.Wait(15)
				New(float_text,'bonus',string.format('BONUS %.1f',Z),x,y+70,0,90,120,0.5,0.5,Color(0xF033CC70),Color(0x0033CC70))
				New(float_text,'bonus',string.format('%d',Z*z*var.pointrate),x,y+60,0,90,120,0.5,0.5,Color(0xF033CC70),Color(0x0033CC70))
				var.score=var.score+var.pointrate*Z*z
				task.Wait(30)
				New(item_chip,x,y,3,90)
				lstg.var.bonusflag=0
			else
				task.Wait(45)
				local x=player.x
				local y=player.y
				PlaySound('pin00',0.8)
				task.Wait(15)
				New(float_text,'bonus',string.format('BONUS %.1f',Z),x,y+70,0,90,120,0.5,0.5,Color(0xF033CC70),Color(0x0033CC70))
				New(float_text,'bonus',string.format('%d',Z*z*var.pointrate),x,y+60,0,90,120,0.5,0.5,Color(0xF033CC70),Color(0x0033CC70))
				var.score=var.score+var.pointrate*Z*z
				task.Wait(30)
				New(item_bombchip,x,y,3,90)
				lstg.var.bonusflag=lstg.var.bonusflag+1
			end
		elseif z>0 and z<30 then
				local x=player.x
				local y=player.y
				task.Wait(15)
				New(float_text,'bonus','NO BONUS',x,y+60,0,90,120,0.5,0.5,Color(0xF0808080),Color(0x00808080))
		elseif z>=80 then
			task.Wait(45)
			local x=player.x
			local y=player.y
			PlaySound('pin00',0.8)
			task.Wait(15)
				New(float_text,'bonus','BONUS 2.0',x,y+70,0,90,120,0.5,0.5,Color(0xF0FFFF00),Color(0x00FFFF00))
				New(float_text,'bonus',string.format('%d',2*z*var.pointrate),x,y+60,0,90,120,0.5,0.5,Color(0xF0FFFF00),Color(0x00FFFF00))
				var.score=var.score+var.pointrate*2*z
			task.Wait(30)
			New(item_chip,x,y,3,90)
		end
		z=0
	end)

end
-----------------------------
function item.PlayerMiss()
	lstg.var.chip_bonus=false
	if lstg.var.sc_bonus then lstg.var.sc_bonus=0 end
	player.protect=360
	lstg.var.lifeleft=lstg.var.lifeleft-1
	lstg.var.power=math.max(lstg.var.power-50,100)
	lstg.var.bomb=3
	if lstg.var.lifeleft>0 then
		for i=1,7 do
			local a=90+(i-4)*18+player.x*0.26
			New(item_power,player.x,player.y+10,3,a)
		end
	else New(item_power_full,player.x,player.y+10) end
end

function item.PlayerSpell()
	if lstg.var.sc_bonus then lstg.var.sc_bonus=0 end
	lstg.var.bombchip_bonus=false
end

function item.PlayerGraze()
	lstg.var.graze=lstg.var.graze+1
	lstg.var.score=lstg.var.score+50
end

function item.PointRateFunc(var)
	local r=10000+int(var.graze/10)*10+int(lstg.var.faith/10)*10
	return r
end
