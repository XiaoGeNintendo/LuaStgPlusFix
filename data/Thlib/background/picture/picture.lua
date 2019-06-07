picture=Class(object)

function picture:init()
	--
	background.init(self,false)
	--resource
	LoadImageFromFile('low','THlib\\background\\picture\\low.png')
	LoadImageFromFile('flower_1','THlib\\background\\picture\\flower_1.png')
	LoadImageFromFile('flower_2','THlib\\background\\picture\\flower_2.png')
	SetImageState('low','mul+add')
	SetImageState('flower_1','mul+add')
	SetImageState('flower_2','mul+add')
	self.imgs={'flower_1','flower_2'}
	self.list={}
	self.liststart=1
	self.listend=0
	--set 3d camera and fog
	--Set3D('eye',1.8,1.7,-21.80)
	Set3D('eye',1.8,1.7,-10.00)
	Set3D('at',-5.7,2.9,-0)
	Set3D('up',0,1,0)
	Set3D('z',1,10000)
	Set3D('fovy',0.6)
	Set3D('fog',1000,1000,Color(0x8033FF00))

	time_=45
	scale=1.6
	z_at_,_d_z_at_=(0),(-4.7/25)*1
	z_eye_,_d_z_eye_=(-10.00),(-11.8/25)*1
	_d_z_eye_T_=_d_z_eye_
	_d_z_at_T_=_d_z_at_
	self.speed=0
	self.z=0
	x_eye,_d_x_eye=(1.8),(-3/time_)*scale
	y_eye,_d_y_eye=(1.7),(7.2/time_)*scale
	z_eye,_d_z_eye=(-21.80),(-11.9/time_)*scale
	_d_x_eye_T=_d_x_eye*scale
	_d_y_eye_T=_d_y_eye*scale
	_d_z_eye_T=_d_z_eye*scale
	N=0
	x_at,_d_x_at=(-5.7),(9.2/time_)*scale
	y_at,_d_y_at=(2.9),(0.6/time_)*scale
	z_at,_d_z_at=(-4.7),(-5/time_)*scale
	_d_x_at_T=_d_x_at*scale
	_d_y_at_T=_d_y_at*scale
	_d_z_at_T=_d_z_at*scale
	A=1
end

rnd=math.random

function picture:frame()
	if self.timer%20==0 then
		for _=1,2 do
			local x=rnd(-16,16)
			local y=ran:Float(11.5,12.5)
			local z=rnd(-30,-6)
			local scale=ran:Float(0.2,0.7)
			local speed=ran:Float(0.02,0.08)
			local rot=ran:Float(-10,10)
			self.listend=self.listend+1
			self.list[self.listend]={rnd(1,2), x,y,z,scale,0,speed,rot}
		end
	end
	for i=self.liststart,self.listend do
		self.list[i][3]=self.list[i][3]-self.list[i][7]
		self.list[i][6]=self.list[i][6]-self.list[i][8]
	end
	while true do
		if self.list[self.liststart][3]<-12 then
			self.list[self.liststart]=nil
			self.liststart=self.liststart+1
		else break
		end
	end
end


function picture:render()
	SetViewMode'mean3d'
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	
	Render4V('low',-16,12,0,16,12,0,16,-12,0,-16,-12,0)
	for i=self.listend,self.liststart,-1 do
		local p=self.list[i]
		Magic_RingRender_V(self.imgs[p[1]],p[2],p[3],p[4],p[5],p[6])
	end
	
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
    end
	SetViewMode'ui'
end

function Get_point( i,j,r )
	local point={}
	local x = r*sin(i)*cos(j)
	local y = 3+r*sin(i)*sin(j)
	local z = r*cos(i)
	point[1]=x
	point[2]=y
	point[3]=z
	return point
end

function Get_point4(R,angle,range)
	x0=R*cos(angle)
	y0=0.3+R*sin(angle)
	x1=x0+range*cos(angle-45)
	y1=y0+range*sin(angle-45)
	x2=x0+range*cos(angle-45+90)
	y2=y0+range*sin(angle-45+90)
	x3=x0+range*cos(angle-45+90+90)
	y3=y0+range*sin(angle-45+90+90)
	x4=x0+range*cos(angle-45+90+90+90)
	y4=y0+range*sin(angle-45+90+90+90)
	local point={}
	point[1]={x1,y1}
	point[2]={x2,y2}
	point[3]={x3,y3}
	point[4]={x4,y4}
	return(point)
end

function Magic_RingRender_V(img,x,y,z,R,rot)
	local x0=x
	local z0=z
	local y0=y
	local H=R*cos(rot-45)
	local L=R*sin(rot-45)
	local x1=x0+H	----------------+R*cos(rot-45)   -- H
	local y1=y0+L	----------------+R*sin(rot-45)	-- L
	local x2=x0-L	----------------+R*cos(rot+45)	-- -L
	local y2=y0+H	----------------+R*sin(rot+45)   -- H
	local x3=x0-H	----------------+R*cos(rot+135)  -- -H
	local y3=y0-L	----------------+R*sin(rot+135)  -- -L
	local x4=x0+L	----------------+R*cos(rot+225)	-- L
	local y4=y0-H	----------------+R*sin(rot+225)  -- -H
	local point={}
	point1={x1,y1,z0}
	point2={x2,y2,z0}
	point3={x3,y3,z0}
	point4={x4,y4,z0}
	Render4V(img,
				point1[1],point1[2],point1[3],
				point2[1],point2[2],point2[3],
				point3[1],point3[2],point3[3],
				point4[1],point4[2],point4[3])
end




























