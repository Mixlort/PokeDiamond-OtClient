local cdBarWin = nil
local isIn = 'V'
local namesAtks = ''
local icons = {}
local prefix = "F"

function init()
	cdBarWin = g_ui.displayUI('cdBar', modules.game_interface.getRootPanel())
	cdBarWin:setVisible(false)
	cdBarWinShape = cdBarWin:getChildById('cdbarShape')
	ProtocolGame.registerExtendedOpcode(82, function(protocol, opcode, buffer)
	
		local t = string.explode(buffer, ";")
		if t[1] == "c" then
			show()
			parsePokeMoves(t[2])
		elseif t[1] == "m" then
			parsePokeMove(t[2], t[3])
		elseif t[1] == "h" then
			hide()
		end
	end)
   connect(g_game, { onGameEnd = hide } )
   connect(LocalPlayer, { onLevelChange = onLevelChange })
   g_mouse.bindPress(cdBarWin, function() createMenu() end, MouseRightButton)
   createIcons()
	cdBarWin.totalmoves = 12
end

function terminate()
	disconnect(g_game, { onGameEnd = hide })
	--disconnect(g_game, 'onTextMessage', getParams)
	disconnect(LocalPlayer, { onLevelChange = onLevelChange })
	ProtocolGame.unregisterExtendedOpcode(82)
	destroyIcons()
	cdBarWin:destroy()
end

function parsePokeMoves(moves)
	local m = string.explode(moves, "|")
	local t = moves == "none" and 0 or #m
	if t > 0 then
		for a = 1,#m do
			local i = string.explode(m[a], ",")
			local ic = icons['Icon'..(a)]
			ic.icon:setMarginLeft(isIn == 'H' and 7 or ic.dist)
			ic.icon:setMarginTop(isIn == 'H' and ic.dist or 7)
			ic.icon:show()
			ic.progress:setTooltip(i[1])
			ic.progress:setVisible(true)
			barChange(a, tonumber(i[2]), tonumber(i[3]), tonumber(i[4]), i[1])
		end
		cdBarWin:setVisible(true)
		cdBarWin.totalmoves = t
	else
		cdBarWin:setVisible(false)
		cdBarWin.totalmoves = 12
	end
	if t < 12 then
		for b = t+1,12 do
			icons['Icon'..(b)].icon:hide()
		end
	end
	if isIn == "H" then
		cdBarWin:setHeight(422 - ((12-t)*34))
		cdBarWinShape:setHeight(422 - ((12-t)*34))
		cdBarWinShape:setImageSource('/images/game/cdbar/v'..t)
	else
		cdBarWin:setWidth(422 - ((12-t)*34))
		cdBarWinShape:setWidth(422 - ((12-t)*34))
		cdBarWinShape:setImageSource('/images/game/cdbar/h'..t)
	end
end

function parsePokeMove(id, move)
	local m = string.explode(move, ",")
	barChange(tonumber(id), tonumber(m[1]), tonumber(m[2]), tonumber(m[3]))
end

function atualizarCDs(text)
if not g_game.isOnline() then return end
if not cdBarWin:isVisible() then return end 
   local t = text:explode(",")
   table.remove(t, 1)   
   for i = 1, 12 do
       local t2 = t[i]:explode("|")
       barChange(i, tonumber(t2[1]), tonumber(t2[1]), tonumber(t2[2]))--, tonumber(t2[3]))
   end 
end

function changePercent(progress, icon, perc, num, totalNum, code, init)
	if not cdBarWin:isVisible() or not icons[icon:getId()].eventCode or code ~= icons[icon:getId()].eventCode then return end      
	if init then
		local initPercent = num >= totalNum and 0 or (totalNum-num)*(100/totalNum)
		progress:setPercent(initPercent)
	else
		progress:setPercent(progress:getPercent()+(perc))
	end
	if progress:getPercent() >= 100 then 
		progress:setText("")
		return
	end
	icons[icon:getId()].event = scheduleEvent(function() changePercent(progress, icon, perc, num, totalNum, code) end, (1000/(100/totalNum)))
end

function changePercentText(progress, icon, num, code)
	if not icons[icon:getId()].eventCode or code ~= icons[icon:getId()].eventCode then return end
	if progress:getPercent() >= 100 then 
		progress:setText("")
		return
	end
	progress:setText(num)
	-- if num <= 2 then
	-- 	progress:setColor('#e5e5f2')
	-- elseif num <= 5 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 10 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 15 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 20 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 25 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 30 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 45 then
	-- 	progress:setColor('#000000')
	-- elseif num <= 60 then
	-- 	progress:setColor('#000000')
	-- else
	-- 	progress:setColor('#000000')
	-- end
    -- progress:setColor('#FF0000')
	icons[icon:getId()].event2 = scheduleEvent(function() changePercentText(progress, icon, num-1, code) end, 1000)
end

function barChange(ic, num, totalNum, lvl, name)
	if not g_game.isOnline() then return end
	if not cdBarWin:isVisible() then return end 
	local icon = icons['Icon'..ic].icon
	local progress = icons['Icon'..ic].progress
	local player = g_game.getLocalPlayer()
	if name then
		local pathOn = "/images/game/cdbar/moves/"..name.."_on.png"
		icon:setImageSource(pathOn)
	end
	if num and num >= 1 then   
		cleanEvents('Icon'..ic)
		local code = math.random(1000,9999)
		icons[icon:getId()].eventCode = code
		changePercent(progress, icon, 1, num, totalNum, code, true)
		changePercentText(progress, icon, num, code)
	else   
		if player:getLevel() < lvl then
			progress:setPercent(0)
			progress:setText('L.'.. lvl)
			progress:setColor('#FF0000')
		else
			progress:setPercent(100)
			progress:setText("") 
		end
	end    
end

function FixTooltip()
	for a = 1, 12 do
		local ic = icons['Icon'..a]
		ic.icon:setMarginLeft(isIn == 'H' and 7 or ic.dist)
		ic.icon:setMarginTop(isIn == 'H' and ic.dist or 7)
	end
	if isIn == "H" then
		cdBarWin:setHeight(cdBarWin:getWidth())
		cdBarWin:setWidth(46)
		cdBarWinShape:setHeight(cdBarWinShape:getWidth())
		cdBarWinShape:setWidth(46)
		cdBarWinShape:setImageSource('/images/game/cdbar/v'..(cdBarWin.totalmoves))
	else
		cdBarWin:setWidth(cdBarWin:getHeight())
		cdBarWin:setHeight(46)
		cdBarWinShape:setWidth(cdBarWinShape:getHeight())
		cdBarWinShape:setHeight(46)
		cdBarWinShape:setImageSource('/images/game/cdbar/h'..(cdBarWin.totalmoves))
	end
end

function createIcons()
   local d = 41
   for i = 1, 12 do
      local icon = g_ui.createWidget('SpellIcon', cdBarWin)
      local progress = g_ui.createWidget('SpellProgress', cdBarWin) 
      icon:setId('Icon'..i)  
      progress:setId('Progress' ..i)
      icons['Icon'..i] = {icon = icon, progress = progress, dist = (8 + ((i-1)*34)), event = nil}
      icon:setMarginTop(icons['Icon'..i].dist)
      icon:setMarginLeft(7)
	  if prefix then icon:getChildById('text'):setText(prefix..i) else icon:getChildById('text'):setText('') end
      progress:fill(icon:getId())
      progress.onClick = function() g_game.talk('m'..i) end
   end
end

function destroyIcons()
	for i = 1, 12 do
		icons['Icon'..i].icon:destroy()
		icons['Icon'..i].progress:destroy()
	end                                
	cleanEvents()
	icons = {}
end

function cleanEvents(icon)
	local e = icons[icon] 
	if icon then
	   if e and e.event ~= nil then
		  removeEvent(e.event)
		  e.event = nil
	   end
	else
	   for i = 1, 12 do
		   e = icons['Icon'..i]
		   cleanEvents('Icon'..i)
		   e.progress:setPercent(100)
		   e.progress:setText("")
	   end
	end
end

function createMenu()
	local menu = g_ui.createWidget('PopupMenu')
	menu:addOption("Set "..(isIn == 'H' and 'Horizontal' or 'Vertical'), function() toggle() end)
	if not prefix or prefix ~= "" then menu:addOption("Show Numbers", function() prefix = "" refreshPrefix() end) end
	if not prefix or prefix ~= "F" then menu:addOption("Show Hotkeys", function() prefix = "F" refreshPrefix() end) end
	if prefix then menu:addOption("Hide "..(prefix == "" and "Numbers" or "Hotkeys"), function() prefix = false refreshPrefix() end) end
	menu:display()
end

function refreshPrefix()
	for a = 1, 12 do
		local ic = icons['Icon'..a]
		if prefix then ic.icon:getChildById('text'):setText(prefix..a) else ic.icon:getChildById('text'):setText('') end
	end
end

function toggle()
	if not cdBarWin:isVisible() then return end 
	cdBarWin:setVisible(false)
	if isIn == 'H' then
		isIn = 'V'
	else 
		isIn = 'H'
	end
	FixTooltip()
	show()
end

function hide()
	-- local settings = {
    --     pos = pointtostring(cdBarWin:getPosition())
	-- }
	-- g_settings.setNode("game_pokemoves", settings)

	cleanEvents()
	cdBarWin:setVisible(false)
end

function show()
	-- local settings = g_settings.getNode("game_pokemoves")
	-- if settings then
        -- cdBarWin:breakAnchors()
    --     cdBarWin:setPosition(topoint(settings.pos))
	-- end

	cdBarWin:setVisible(true)
	cdBarWinShape:raise()
end