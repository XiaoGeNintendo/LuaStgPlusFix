gamecontinueflag=false
LoadTexture('pause','THlib\\UI\\pause.png')
LoadImage('pause_pausemenu','pause',2,0,168,70)
SetImageCenter('pause_pausemenu',0,35)
LoadImage('pause_gameover','pause',172,0,170,70)
SetImageCenter('pause_gameover',0,35)
LoadImage('pause_replyover','pause',352,0,162,70)
SetImageCenter('pause_replyover',0,35)
LoadImage('pause_Return to Game','pause',0,80,245,60)
SetImageCenter('pause_Return to Game',0,30)
LoadImage('pause_Return to Title','pause',0,140,260,56)
SetImageCenter('pause_Return to Title',0,28)
LoadImage('pause_Give up and Retry','pause',0,197,200,58)
SetImageCenter('pause_Give up and Retry',0,29)
LoadImage('pause_Restart','pause',0,197,200,58)
SetImageCenter('pause_Restart',0,29)
LoadImage('pause_yes','pause',200,196,112,60)
SetImageCenter('pause_yes',0,30)
LoadImage('pause_no','pause',340,196,112,60)
SetImageCenter('pause_no',0,30)
LoadImage('pause_Quit and Save Replay','pause',0,256,360,58)
SetImageCenter('pause_Quit and Save Replay',0,29)
LoadImage('pause_really','pause',0,316,240,60)
SetImageCenter('pause_really',0,30)
LoadImage('pause_savereply','pause',0,368,188,60)
SetImageCenter('pause_savereply',0,30)
LoadImage('pause_Replay Again','pause',0,432,224,56)
SetImageCenter('pause_Replay Again',0,28)
LoadImage('pause_Continue','pause',232,432,120,58)
SetImageCenter('pause_Continue',0,29)
LoadImage('pause_eff','pause',408,320,104,384)

LoadMusic('deathmusic','THlib\\music\\player_score.ogg',34.834,27.54)

ext = { replay = {} }

ext.mask_color=Color(0,255,255,255)
ext.mask_alph={0,0,0}
ext.mask_x={0,0,0}
ext.pause_menu_text={{'Return to Game','Return to Title','Give up and Retry'},
					 {'Return to Game','Return to Title','Replay Again'}}

function ext.GetPauseMenuOrder()
	return ext.pause_menu_order
end
--------------------------------------------------------------------------------
local REPLAY_DIR = "replay"

if not plus.DirectoryExists(REPLAY_DIR) then
	plus.CreateDirectory(REPLAY_DIR)
end

local replayManager = plus.ReplayManager(REPLAY_DIR.."\\"..setting.mod)

local replayFilename = nil  -- 当前打开的Replay文件名称
local replayInfo = nil  -- 当前打开的Replay文件信息
local replayStageIdx = 1  -- 当前正在播放的关卡
local replayReader = nil  -- 帧读取器
local replayTicker = 0  -- 控制录像速度时有用
local slowTicker = 0    -- 控制时缓的变量

local replayStages = {}  -- 记录所有关卡的录像数据
local replayWriter = nil  -- 帧记录器

function ext.replay.IsReplay()  -- 兼容性接口
	return replayReader ~= nil
end

function ext.replay.IsRecording()
	return replayWriter ~= nil
end

function ext.replay.GetCurrentReplayIdx()
	return replayStageIdx
end

function ext.replay.GetReplayFilename()
	return replayFilename
end

function ext.replay.GetReplayStageName(idx)
	assert(replayInfo ~= nil)
	return replayInfo.stages[idx].stageName
end

function ext.replay.RefreshReplay()
	replayManager:Refresh()
end

function ext.replay.GetSlotCount()
	return replayManager:GetSlotCount()
end

function ext.replay.GetSlot(idx)
	return replayManager:GetRecord(idx)
end

function ext.replay.SaveReplay(stageNames, slot, playerName, finish)
	local stages = {}
  finish=finish or 0
	for _, v in ipairs(stageNames) do
		assert(replayStages[v])
		table.insert(stages, replayStages[v])
	end

	-- TODO: gameName和gameVersion可以被用来检查录像文件的合法性
	plus.ReplayManager.SaveReplayInfo(replayManager:MakeReplayFilename(slot),
	    {
			gameName = setting.mod, gameVersion = 1, userName = playerName, group_finish = finish,
			stages = stages
    	})
end
--------------------------------------------------------------------------------
--! @brief 设置场景
--! @param mode 录像模式，可选none\load\save
--! @param path 录像文件路径（可选）
--! @param stage 关卡名称
--!
--! 本方法覆盖core.lua/stage.Set以实现录像系统
--!
--! 当mode == none时，参数stage用于表明下一个跳转的场景
--! 当mode == load时，参数path有效，指明从path录像文件中加载场景stage的录像数据
--! 当mode == save时，参数path无效，使用stage指定场景名称并开始录像

function stage.Set(mode, path, stageName)
	ext.pause_menu_order = nil

	-- 针对上一个可能的场景保存其数据
	if replayWriter ~= nil then
		local recordStage = replayStages[lstg.var.stage_name]
		recordStage.score = lstg.var.score
		recordStage.stageTime = os.time() - recordStage.stageTime  -- TODO：这个方法只保存了大致时间，包括了暂停
		recordStage.stageExtendInfo = Serialize(lstg.var)
	end

	-- 关闭上一个场景的录像读写
	replayWriter = nil
	if replayReader then
		replayReader:Close()
		replayReader = nil
	end
	if mode ~= "load" then
		replayFilename = nil  -- 装载时使用缓存的数据
		replayInfo = nil
		replayStageIdx = 0
	end
	replayTicker = 0
	slowTicker = 0

	-- 刷新最高分
	if (not stage.current_stage.is_menu) and (not ext.replay.IsReplay()) then
		local str = stage.current_stage.stage_name..'@'..tostring(lstg.var.player_name)
		if scoredata.hiscore[str] == nil then
			scoredata.hiscore[str] = 0
		end
		scoredata.hiscore[str] = max(scoredata.hiscore[str], lstg.var.score)
	end

	-- 转场
	if mode == "save" then
		assert(stageName == nil)
		stageName = path
		-- 设置随机数种子
		lstg.var.ran_seed = ((os.time() % 65536) * 877) % 65536
		ran:Seed(lstg.var.ran_seed)
		-- 开始执行录像
		local sg=string.match(stageName,'^.+@(.+)$')
		replayWriter = plus.ReplayFrameWriter()
		replayStages[stageName] = {
			stageName = stageName, score = 0, randomSeed = lstg.var.ran_seed,
            stageTime = os.time(), stageDate = os.time(), stagePlayer=lstg.var.rep_player,
            group_num=stage.groups[sg].number,
            cur_stage_num=(stage.current_stage.number or 100),
            frameData = replayWriter
		}

		-- 转场
		lstg.var.stage_name = stageName
		stage.next_stage = stage.stages[stageName]
	elseif mode == "load" then
		if path ~= replayFilename then
			replayFilename = path
			replayInfo = plus.ReplayManager.ReadReplayInfo(path)  -- 重新读取录像信息以保证准确性
			assert(#replayInfo.stages > 0)
		end

		-- 决定场景顺序
		if stageName then
			replayStageIdx = nil
			for i, v in ipairs(replayInfo.stages) do
				if replayInfo.stages[i].stageName == stageName then
					replayStageIdx = i
					break
				end
			end
			assert(replayStageIdx ~= nil)
		else
			replayStageIdx = 1
		end

		-- 加载数据
		local nextRecordStage = replayInfo.stages[replayStageIdx]
		replayReader = plus.ReplayFrameReader(path, nextRecordStage.frameDataPosition, nextRecordStage.frameCount)

		-- 加载数据
		lstg.var = DeSerialize(nextRecordStage.stageExtendInfo)
		assert(lstg.var.ran_seed == nextRecordStage.randomSeed)  -- 这两个应该相等

		-- 初始化随机数
		if lstg.var.ran_seed then
			ran:Seed(lstg.var.ran_seed)
		end

		-- 转场
		lstg.var.stage_name = nextRecordStage.stageName
		stage.next_stage = stage.stages[stageName]
	else
		assert(mode == "none")
		assert(stageName == nil)
		stageName = path

		-- 转场
		lstg.var.stage_name = stageName
		stage.next_stage = stage.stages[stageName]
	end
end

--! @brief 重新开始场景
function stage.Restart()
	stage.preserve_res = true  -- 保留资源在转场时不清空

	if ext.replay.IsReplay() then
		stage.Set("load", ext.replay.GetReplayFilename(), lstg.var.stage_name)
--     stage.Set("load", ext.replay.GetReplayStageName(1), lstg.var.stage_name)
	elseif ext.replay.IsRecording() then
		stage.Set("save", lstg.var.stage_name)
	else
		stage.Set("none", lstg.var.stage_name)
	end
end
----------------------------------------------------------------------

function GetInput()
	if stage.next_stage then
		-- 把一些转场的破事放到这里处理，NOT GOOD
		lstg.world.l=-192
		lstg.world.r= 192
		lstg.world.b=-224
		lstg.world.t= 224
		lstg.tmpvar={}

		KeyStatePre = {}
		if not stage.next_stage.is_menu then
			if scoredata.hiscore == nil then
				scoredata.hiscore = {}
			end
			lstg.tmpvar.hiscore = scoredata.hiscore[stage.next_stage.stage_name..'@'..tostring(lstg.var.player_name)]
		end
	else
		-- 刷新KeyStatePre
		for k, v in pairs(setting.keys) do
			KeyStatePre[k] = KeyState[k]
		end
	end

	-- 不是录像时更新按键状态
	if not ext.replay.IsReplay() then
		for k,v in pairs(setting.keys) do
			KeyState[k] = GetKeyState(v)
		end
	end

	if ext.replay.IsRecording() then
		-- 录像模式下记录当前帧的按键
		replayWriter:Record(KeyState)
	elseif ext.replay.IsReplay() then
		-- 回放时载入按键状态
		replayReader:Next(KeyState)
		--assert(replayReader:Next(KeyState), "Unexpected end of replay file.")
	end
end

local time_slow_level={1, 2, 3, 4}--60/30/20/15  4个程度

function FrameFunc()
	if GetLastKey() == setting.keysys.snapshot and setting.allowsnapshot then
		-- 看，时区都考虑进去了。。
		Snapshot('snapshot\\'..os.date("!%Y-%m-%d-%H-%M-%S", os.time() + setting.timezone * 3600)..'.png')
	end

	-- 无暂停时执行场景逻辑
	if ext.pause_menu == nil then
		-- 处理录像速度与正常更新逻辑
		if ext.replay.IsReplay() then
			replayTicker = replayTicker + 1
			slowTicker = slowTicker + 1
			if GetKeyState(setting.keysys.repfast) then
				DoFrame(true, false)
				ext.pause_menu_order = nil
				DoFrame(true, false)
				ext.pause_menu_order = nil
				DoFrame(true, false)
				ext.pause_menu_order = nil
				DoFrame(true, false)
				ext.pause_menu_order = nil
			elseif GetKeyState(setting.keysys.repslow) then
				if replayTicker % 4 == 0 then
					DoFrame(true, false)
					ext.pause_menu_order = nil
				else
					--DoFrame(false, false)
				end
			else
				if lstg.var.timeslow then
					local tmp=min(4,max(1,lstg.var.timeslow))
					if slowTicker%(time_slow_level[tmp])==0 then
					DoFrame(true, false) end
				else DoFrame(true, false) end
				ext.pause_menu_order = nil
			end
		else
			slowTicker=slowTicker+1
			if lstg.var.timeslow and lstg.var.timeslow>0 then
				local tmp=min(4,max(1,lstg.var.timeslow))
				if slowTicker%(time_slow_level[tmp])==0 then
				DoFrame(true, false) end
			else DoFrame(true, false) end
		end

		-- 按键弹出菜单
		if (GetLastKey() == setting.keysys.menu or ext.pop_pause_menu) and not stage.current_stage.is_menu then
			ext.pop_pause_menu = nil
			ext.rep_over=false
			PlaySound('pause', 0.5)
			if not(ext.sc_pr) then
        local _, bgm = EnumRes('bgm')
        for _,v in pairs(bgm) do
          if GetMusicState(v) ~= 'stopped' and v ~= 'deathmusic' then
            PauseMusic(v)
          end
        end
      end
--[[			local sound, _ = EnumRes('snd')
			for _,v in pairs(sound) do
				if GetSoundState(v)~='stopped' and v ~= 'pause' then
					PauseSound(v)
				end
			end]]
			---\_menu_pause=New(pause_menu_main,'menuchangeball1',320,240,1)
			ext.pause_menu={}
			ext.pause_menu.pos=1
			ext.pause_menu.pos2=2
			ext.pause_menu.ok=false
			ext.pause_menu.choose=false
			ext.pause_menu.pos_pre=1
			ext.pause_menu.timer=0
			ext.pause_menu.t=30
			ext.pause_menu.eff=0
			ext.pause_menu.pos_changed=0
			task.New(ext.pause_menu,function()
				ext.pause_menu.lock=true
				ext.mask_alph={0,0,0}
				ext.mask_x={0,0,0}
				for i=1,50 do
					ext.mask_color=Color(i*4.1,0,0,0)
					ext.mask_alph[1]=min(i*8,239)
					ext.mask_alph[2]=max(min((i-10)*8,239),0)
					ext.mask_alph[3]=max(min((i-20)*8,239),0)
					ext.mask_x[1]=min(-210+i,-180)
					ext.mask_x[2]=min(-220+i,-180)
					ext.mask_x[3]=min(-230+i,-180)
					ext.font_alpha=i*0.0333
					task.Wait(1)
				end
				ext.pause_menu.lock=nil
			end)
		end
	else
		-- 暂停菜单部分
		local m
		if ext.replay.IsReplay() then
			m = 2
		else
			m = 1
		end
		--
		local pause_menu_text
		if lstg.tmpvar.pause_menu_text then
			pause_menu_text=lstg.tmpvar.pause_menu_text
		else
			pause_menu_text=ext.pause_menu_text[m]
		end
		--
		if GetLastKey()==setting.keys.up and ext.pause_menu.t<=0 and ext.pause_menu then
			if not ext.pause_menu.choose then
				ext.pause_menu.pos=ext.pause_menu.pos-1
			else
				ext.pause_menu.pos2=ext.pause_menu.pos2-1
			end
			PlaySound('select00',0.3)
		end
		if GetLastKey()==setting.keys.down  and ext.pause_menu.t<=0 and ext.pause_menu then
			if not ext.pause_menu.choose then
				ext.pause_menu.pos=ext.pause_menu.pos+1
			else
				ext.pause_menu.pos2=ext.pause_menu.pos2+1
			end
			PlaySound('select00',0.3)
		end
		ext.pause_menu.pos=(ext.pause_menu.pos-1)%(#pause_menu_text)+1
		ext.pause_menu.pos2=(ext.pause_menu.pos2-1)%(2)+1
		--
		ext.pause_menu.timer=ext.pause_menu.timer+1
		if ext.pause_menu.t>0 then ext.pause_menu.t=ext.pause_menu.t-1 end
		if ext.pause_menu.choose then
      ext.pause_menu.eff=min(ext.pause_menu.eff+1,15)
    else
      ext.pause_menu.eff=max(ext.pause_menu.eff-1,0)
    end
		if ext.pause_menu.pos_changed>0 then
			ext.pause_menu.pos_changed=ext.pause_menu.pos_changed-1
		end
		if ext.pause_menu.pos_pre~=ext.pause_menu.pos then
			ext.pause_menu.pos_changed=ui.menu.shake_time
		end
		ext.pause_menu.pos_pre=ext.pause_menu.pos
		--
		task.Do(ext.pause_menu)
		--DoFrame(false, false)
		if IsValid(_menu_pause) then
		    task.Do(_menu_pause)
		end
		if (GetLastKey()==setting.keysys.menu or GetLastKey()==setting.keys.shoot or GetLastKey()==setting.keys.spell or GetLastKey()==setting.keysys.retry) and ext.pause_menu and
			not ext.pause_menu.lock then
			    Del(_menu_pause)
			if GetLastKey()==setting.keysys.retry then
				PlaySound('ok00',0.3)
				lstg.tmpvar.death = false
				ext.pause_menu.t=60
				ext.pause_menu.pos2=1
				if ext.replay.IsReplay() then
					ext.pause_menu_order='Replay Again'
				else
					ext.pause_menu_order='Give up and Retry'
				end
			end
			if GetLastKey()==setting.keys.shoot and ext.pause_menu.t<1 then
				ext.pause_menu.t=15
				if not ext.pause_menu.choose then
					PlaySound('ok00',0.3)
					if ext.pause_menu.pos==1 then
						lstg.tmpvar.death = false
						ext.pause_menu_order=pause_menu_text[ext.pause_menu.pos]
						if ext.pause_menu.pos ~= 1 then
							for img,v in pairs(bullet.gclist) do
								for color,status in pairs(v) do
									if status then ChangeBulletHighlight(img,color,false) end
								end
							end
						end
					else
						ext.pause_menu.choose=true
					end
				else
					if ext.pause_menu.pos2==1 then
						PlaySound('ok00',0.3)
						ext.pause_menu.t=60
						if not(ext.sc_pr) then
						task.New(ext.pause_menu,function()
						local _,bgm=EnumRes('bgm')
						for i=1,30 do
              for _,v in pairs(bgm) do
                if GetMusicState(v)=='playing' then
                SetBGMVolume(v,1-i/30) end
              end
							task.Wait()
							end
						end)
						end
						ext.pause_menu.t=60
						lstg.tmpvar.death = false
						ext.pause_menu_order=pause_menu_text[ext.pause_menu.pos]
						if ext.pause_menu.pos ~= 1 then
							for img,v in pairs(bullet.gclist) do
								for color,status in pairs(v) do
									if status then ChangeBulletHighlight(img,color,false) end
								end
							end
						end
					else
						ext.pause_menu.choose=false
						PlaySound('cancel00',0.3)
						ext.pause_menu.t=15
					end
				end
			end
			if GetLastKey()==setting.keys.spell and ext.pause_menu.t<1 and ext.pause_menu.choose==true then
				ext.pause_menu.choose=false
				ext.pause_menu.t=15
				PlaySound('cancel00',0.3)
			end
			if not lstg.tmpvar.death and (ext.pause_menu.pos2==1 or ext.pause_menu.pos==1) then
				task.New(ext.pause_menu,function()
					ext.pause_menu.lock=true
					for i=30,1,-1 do
						ext.mask_color=Color(i*7,0,0,0)
						for j=1,3 do
						    ext.mask_alph[j]=i*8
						end
						ext.font_alpha=i*0.0333
						task.Wait(1)
					end
					task.New(stage.current_stage,function()
						task.Wait(1)
						local _,bgm=EnumRes('bgm')
						for _,v in pairs(bgm) do
							if GetMusicState(v)~='stopped' then
								ResumeMusic(v)
							end
						end
--[[						local sound,_=EnumRes('snd')
						for _,v in pairs(sound) do
							if GetSoundState(v)=='paused' then
                				ResumeSound(v)
							end
						end]]
	--					StopMusic('deathmusic')
					end)
					ext.pause_menu=nil
				end)
			end
		end
	end
	if lstg.quit_flag then
		GameExit()
	end
	return lstg.quit_flag
end
--[[
ext.replay.ticker=0

local _fps_level=4
local _fps={7.5,15,30,60,120,240,480}
]]

function RenderFunc()
	if stage.current_stage.timer and stage.current_stage.timer > 1 and stage.next_stage == nil then
		BeginScene()
		BeforeRender()
		stage.current_stage:render()
		ObjRender()
		AfterRender()
		EndScene()
	end
end

function AfterRender()
	if ext.pause_menu then
		SetViewMode'ui'
		SetImageState('white','',ext.mask_color)
		RenderRect('white',0,640,0,480)
		SetViewMode'world'
		local m
		if ext.replay.IsReplay() then
			m=2
		else
			m=1
		end
		SetImageState('pause_eff','',Color(ext.mask_alph[1]/3,200*ext.pause_menu.eff/15+55,200*(1-ext.pause_menu.eff/15)+55,200*(1-ext.pause_menu.eff/15)+55))
		Render('pause_eff',-150+180*ext.pause_menu.eff/15,-90,4+4*sin(ext.pause_menu.timer*3),0.4,0.6)
		local pause_menu_text
		local pause_menu_choose={'yes','no'}
		if lstg.tmpvar.pause_menu_text then
			pause_menu_text = lstg.tmpvar.pause_menu_text
		else
			pause_menu_text = ext.pause_menu_text[m]
		end
		local textnumber=0
		if pause_menu_text[3] then
			textnumber=3
		else
			textnumber=2
        end
		if pause_menu_text then
		    if lstg.tmpvar.pause_menu_text then
          if ext.rep_over then
            if ext.pause_menu.choose then
              SetImageState('pause_replyover','',Color(ext.mask_alph[1]+15,100,100,100))
            else
              SetImageState('pause_replyover','',Color(ext.mask_alph[1]+15,255,255,255))
            end
				    Render('pause_replyover',ext.mask_x[1],-30,0,0.7,0.7)
          elseif not ext.sc_pr then
            if ext.pause_menu.choose then
              SetImageState('pause_gameover','',Color(ext.mask_alph[1]+15,100,100,100))
            else
              SetImageState('pause_gameover','',Color(ext.mask_alph[1]+15,255,255,255))
            end
            Render('pause_gameover',ext.mask_x[1],-30,0,0.7,0.7)
          end
		    else
			    if m==1 then
            if ext.pause_menu.choose then
              SetImageState('pause_pausemenu','',Color(ext.mask_alph[1]+15,100,100,100))
            else
              SetImageState('pause_pausemenu','',Color(ext.mask_alph[1]+15,255,255,255))
            end
				    Render('pause_pausemenu',ext.mask_x[1],-30,0,0.7,0.7)
				else
            if ext.pause_menu.choose then
              SetImageState('pause_replyover','',Color(ext.mask_alph[1]+15,100,100,100))
            else
              SetImageState('pause_replyover','',Color(ext.mask_alph[1]+15,255,255,255))
            end
				    Render('pause_replyover',ext.mask_x[1],-30,0,0.7,0.7)
				end
		    end
		    for i=1,textnumber do
          if not(ext.pause_menu.choose) then
            if i==ext.pause_menu.pos and ext.mask_alph[i]+15>=245 then
              SetImageState('pause_'..pause_menu_text[i],'',Color(ext.mask_alph[i]+15,155+100*sin(ext.pause_menu.timer*4.5),255,222))
            else
              SetImageState('pause_'..pause_menu_text[i],'',Color(ext.mask_alph[i]+15,100,100,100))
            end
			    else
            if i==ext.pause_menu.pos and ext.mask_alph[i]+15>=245 then
              SetImageState('pause_'..pause_menu_text[i],'',Color(55,255,255,255))
            else
              SetImageState('pause_'..pause_menu_text[i],'',Color(55,100,100,100))
            end
          end
				Render('pause_'..pause_menu_text[i],ext.mask_x[i]+(1+i)*10,-30-i*40,0,0.62,0.62)
			end
		end
		if ext.pause_menu.choose then
      Render('pause_really',0,-50,0,0.62,0.62)
      for i=1,2 do
        if i==ext.pause_menu.pos2 then
          SetImageState('pause_'..pause_menu_choose[i],'',Color(ext.mask_alph[i]+15,155+100*sin(ext.pause_menu.timer*4.5),255,255))
        else
          SetImageState('pause_'..pause_menu_choose[i],'',Color(ext.mask_alph[i]+15,100,100,100))
        end
        Render('pause_'..pause_menu_choose[i],15+i*10,-50-i*40,0,0.62,0.62)
      end
    end
		--
		--ui.DrawMenu('',pause_menu_text,ext.pause_menu.pos,0,0,
			--ext.font_alpha,ext.pause_menu.timer,ext.pause_menu.pos_changed)
	end
end
--[[
function ext.GetPauseMenuOrder()
	return ext.pause_menu_order
end
]]
function FocusLoseFunc()
	if ext.pause_menu==nil and stage.current_stage then
		if not stage.current_stage.is_menu then
			ext.pop_pause_menu=true
		end
	end
end
-------------------------------------------------------------------------
stage.group={}

stage.groups={}

stage.group={}

stage.groups={}

function stage.group.New(title,stages,name,item_init,allow_practice,difficulty)
	local sg={['title']=title,number=#stages}
	for i=1,#stages do
		sg[i]=stages[i]
		local s=stage.New(stages[i])
		s.frame=stage.group.frame
		s.render=stage.group.render
		s.number=i
		s.group=sg
		sg[stages[i]]=s
		s.x,s.y=0,0
		s.name=stages[i]
	end
	if name then
		stage.groups[name]=sg table.insert(stage.groups,name)
	end
	if item_init then
		sg.item_init=item_init
	end
	sg.allow_practice=allow_practice or false
	sg.difficulty=difficulty or 1
	return sg
end

function stage.group.AddStage(groupname,stagename,item_init,allow_practice)
	local sg=stage.groups[groupname]
	if sg~=nil then
		sg.number=sg.number+1
		table.insert(sg,stagename)
		local s=stage.New(stagename)
		if groupname=='Spell Practice' then
			s.frame=stage.group.frame_sc_pr
    else
      s.frame=stage.group.frame
    end
		s.render=stage.group.render
		s.number=sg.number
		s.group=sg
		sg[stagename]=s
		s.x,s.y=0,0
		s.name=stagename
		if item_init then
			s.item_init=item_init
		end
		s.allow_practice=allow_practice or false
		return s
	end
end

function stage.group.DefStageFunc(stagename,funcname,f)
	stage.stages[stagename][funcname]=f
end

function stage.group.frame(self)
  ext.sc_pr=false
	if not lstg.var.init_player_data then
		error('Player data has not been initialized. (Call function item.PlayerInit.)')
	end
	--
	if lstg.var.lifeleft<=-1 then
		if ext.replay.IsReplay() then
      ext.pop_pause_menu=true
      ext.rep_over=true
			lstg.tmpvar.pause_menu_text={'Replay Again','Return to Title',nil}
		else
			PlayMusic('deathmusic',0.8)
			ext.pop_pause_menu=true
			lstg.tmpvar.death = true
			lstg.tmpvar.pause_menu_text={'Continue','Quit and Save Replay','Restart'}
		end
		lstg.var.lifeleft=0
	end
	--
	if ext.GetPauseMenuOrder()=='Return to Title' then
		lstg.var.timeslow=nil
		stage.group.ReturnToTitle(false,0)
	end
	if ext.GetPauseMenuOrder()=='Replay Again' then
		lstg.var.timeslow=nil
		stage.Restart()
	end
	if ext.GetPauseMenuOrder()=='Give up and Retry' then
		StopMusic('deathmusic')
		lstg.var.timeslow=nil
		if lstg.var.is_practice then
			stage.group.PracticeStart(self.name)
		else
			stage.group.Start(self.group)
		end
	end
	if ext.GetPauseMenuOrder()=='Continue' then
	lstg.var.timeslow=nil
    StopMusic('deathmusic')
    if not Extramode then
    gamecontinueflag=true
		if lstg.var.block_spell then
			if lstg.var.is_practice then
				stage.group.PracticeStart(self.name)
			else
				stage.group.Start(self.group)
			end
			lstg.tmpvar.pause_menu_text=nil
		else
			--item.PlayerInit()
    		-- START: modified by 二要 打分等代码修改记录
			local temp=lstg.var.score or 0
			lstg.var.score=0
			item.PlayerReinit()
			lstg.tmpvar.hiscore=lstg.tmpvar.hiscore or 0
			if lstg.tmpvar.hiscore<temp then
				lstg.tmpvar.hiscore=temp
			end
			-- END
			lstg.tmpvar.pause_menu_text=nil
			ext.pause_menu_order=nil
			if lstg.var.is_practice then
			stage.group.PracticeStart(self.name)
			else
			stage.stages[stage.current_stage.group.title].save_replay=nil
			end
		end
		else
		stage.group.Start(self.group)
		lstg.tmpvar.pause_menu_text=nil
		end
	end
	if ext.GetPauseMenuOrder()=='Quit and Save Replay' then
		stage.group.ReturnToTitle(true,0)
		lstg.tmpvar.pause_menu_text=nil
		lstg.tmpvar.death = true
		lstg.var.timeslow=nil
	end
	if ext.GetPauseMenuOrder()=='Restart' then
    StopMusic('deathmusic')
		if lstg.var.is_practice then
			stage.group.PracticeStart(self.name)
		else
			stage.group.Start(self.group)
		end
		lstg.tmpvar.pause_menu_text=nil
		lstg.var.timeslow=nil
	end
end

function stage.group.render(self)
	SetViewMode'ui'
	ui.DrawFrame()
	if lstg.var.init_player_data then
		ui.DrawScore()
	end
	SetViewMode'world'
	RenderClear(Color(0x00000000))
end

function stage.group.frame_sc_pr(self)
  ext.sc_pr=true
	if not lstg.var.init_player_data then
		error('Player data has not been initialized. (Call function item.PlayerInit)')
	end
	if lstg.var.lifeleft<=-1 then
		if ext.replay.IsReplay() then
      ext.pop_pause_menu=true
      ext.rep_over=true
			lstg.tmpvar.pause_menu_text={'Replay Again','Return to Title',nil}
		else
			ext.pop_pause_menu=true
			lstg.tmpvar.death = true
      lstg.tmpvar.pause_menu_text={'Continue','Quit and Save Replay','Return to Title'}
		end
		lstg.var.lifeleft=0
	end
	if ext.GetPauseMenuOrder()=='Give up and Retry' then
		stage.Restart()
		lstg.tmpvar.pause_menu_text=nil
		lstg.var.timeslow=nil
	end
	if ext.GetPauseMenuOrder()=='Return to Title' then
		stage.group.ReturnToTitle(false,0)
		lstg.var.timeslow=nil
	end
	if ext.GetPauseMenuOrder()=='Replay Again' then
		stage.Restart()
		lstg.var.timeslow=nil
	end
	if ext.GetPauseMenuOrder()=='Continue' then
		stage.Restart()
		lstg.var.timeslow=nil
	end
	if ext.GetPauseMenuOrder()=='Quit and Save Replay' then
		stage.group.ReturnToTitle(true,0)
		lstg.tmpvar.pause_menu_text=nil
		lstg.tmpvar.death = true
		lstg.var.timeslow=nil
	end
end

function stage.group.Start(group)
	lstg.var.is_practice=false
	stage.Set('save', group[1])
	stage.stages[group.title].save_replay = { group[1] }
end

function stage.group.PracticeStart(stagename)
	lstg.var.is_practice=true
	stage.Set('save', stagename)
	stage.stages[stage.stages[stagename].group.title].save_replay = { stagename }
end

function stage.group.FinishStage()
	local self=stage.current_stage
	local group=self.group
	if self.number==group.number or lstg.var.is_practice then
		if ext.replay.IsReplay() then
      ext.rep_over=true
			ext.pop_pause_menu=true
      lstg.tmpvar.pause_menu_text={'Replay Again','Return to Title',nil}
		else
			if lstg.var.is_practice then
        stage.group.ReturnToTitle(true,0)
      else
        stage.group.ReturnToTitle(true,1)
      end
		end
	else
		if ext.replay.IsReplay() then
			-- 载入关卡并执行录像
			--stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[self.number+1]})
			stage.Set('load', ext.replay.GetReplayFilename(), ext.replay.GetReplayStageName(ext.replay.GetCurrentReplayIdx() + 1))
		else
			-- 载入关卡并开始保存录像
			--stage.Set('save','temp/'..group[self.number+1],group[self.number+1])
			stage.Set('save', group[self.number + 1])
			if stage.stages[group.title].save_replay then
				table.insert(stage.stages[group.title].save_replay,group[self.number+1])
			end
		end
	end
end
-----
function stage.group.FinishReplay()
	local self=stage.current_stage
	local group=self.group
	if self.number==group.number or lstg.var.is_practice then
		if ext.replay.IsReplay() then
      ext.rep_over=true
			ext.pop_pause_menu=true
      lstg.tmpvar.pause_menu_text={'Replay Again','Return to Title',nil}
		end
	else
		if ext.replay.IsReplay() then
			-- 载入关卡并执行录像
			--stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[self.number+1]})
			stage.Set('load', ext.replay.GetReplayFilename(), ext.replay.GetReplayStageName(ext.replay.GetCurrentReplayIdx() + 1))
		end
	end
end
-----

function stage.group.GoToStage(number)
	local self=stage.current_stage
	local group=self.group
	number=number or self.number+1
	if number>group.number or lstg.var.is_practice then
    if lstg.var.is_practice then
      stage.group.ReturnToTitle(true,0)
    else
      stage.group.ReturnToTitle(true,1)
    end
	else
		if ext.replay.IsReplay() then
			--stage.Set('load',{ext.replay.sts.filename[1],'temp/'..group[number]})
			stage.Set('load', ext.replay.GetReplayFilename(), group[number])
		else
			--stage.Set('save','temp/'..group[number],group[number])
			stage.Set('save', group[number])
			if stage.stages[group.title].save_replay then
				table.insert(stage.stages[group.title].save_replay,group[number])
			end
		end
	end
end

function stage.group.FinishGroup()
	stage.group.ReturnToTitle(true,1)
end

function stage.group.ReturnToTitle(save_rep,finish)
  StopMusic('deathmusic')
  gamecontinueflag=false
	local self=stage.current_stage
	local title=stage.stages[self.group.title]
	title.finish=finish or 0
	if ext.replay.IsReplay() then
		title.save_replay=nil
	elseif not save_rep then
		title.save_replay=nil
		moveoverflag=true
	end
	stage.Set('none', self.group.title)
end
