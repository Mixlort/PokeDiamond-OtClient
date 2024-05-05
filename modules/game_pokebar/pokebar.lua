
pokemonBar = nil

local currentSlotBar = nil
local pokeBarButton = nil

local POKEBAR_OPCODE = 131
local ACTION_POKEBAR_ADD = 1
local ACTION_POKEBAR_REMOVE = 2
local ACTION_POKEBAR_UPDATE = 3

local function getHealthColor(health)
  return (health < 35) and '#d72800' or
	     (health < 65) and '#e7c148' or '#5fda4c'
end

local function resize()
  local height = ((pokemonBar:getChildCount() == 0) and 35 or 5) + pokemonBar:getPaddingBottom()
  
  for i, slotBar in pairs(pokemonBar:getChildren()) do
    height = height + slotBar:getHeight() + slotBar:getMarginTop()
  end
  
  pokemonBar:setHeight(height)
end

local function updateSlotBar(slotBar, pokemon)
  if ( pokemon.text == tr("USE") ) then
    if ( currentSlotBar ) then
      slotBar.background:setOn(false)
    end
    slotBar.background:setOn(true)
    currentSlotBar = slotBar   
  elseif ( slotBar == currentSlotBar ) then
    slotBar.background:setOn(false) 
    currentSlotBar = nil
  end

  if pokemon.health then
    slotBar.progress:setBackgroundColor(getHealthColor(pokemon.health))
    slotBar.background:setEnabled(pokemon.health ~= 0)
    slotBar.health:setText(pokemon.health..'%') 
    slotBar.progress:setPercent(pokemon.health)
  end
  if pokemon.outfit then
    slotBar.portrait:setOutfit(pokemon.outfit)
  end
  if pokemon.name then
    slotBar.name:setText(pokemon.name)
  end
  --   slotBar.gender:setImageSource(getSkullImagePath(pokemon.gender))
  --   slotBar.portrait:setImageSource("icons/"..pokemon.name..".png")
end

local function removeSlotBar(slotBar)
  if ( slotBar == currentSlotBar ) then
	currentSlotBar = nil
  end
  pokemonBar[slotBar:getId()] = nil
  slotBar:destroy()
end
  
local function onDragEnter(slotBar, mousePos)
  pokemonBar:breakAnchors()
  slotBar.movingReference = { x = mousePos.x - pokemonBar:getX(), y = mousePos.y - pokemonBar:getY() }
  return true
end

local function onDragMove(slotBar, mousePos, mouseMoved)
  local pos = { x = mousePos.x - slotBar.movingReference.x, y = mousePos.y - slotBar.movingReference.y }
    
  pokemonBar:setPosition(pos)
  pokemonBar:bindRectToParent()
end

local function onDragLeave(slotBar, mousePos)
  slotBar.dragLeave = g_clock.millis() + 2
end

function init()
  connect(g_game, {
    onGameStart = onGameStart,
	  onGameEnd = onGameEnd,
  })
  
  connect(Creature, {
    onHealthPercentChange = onCreatureHealthPercentChange,
  })
	
  pokeBarButton = modules.client_topmenu.addRightGameToggleButton('pokeBarButton', tr('Poke Bar') .. ' ', '/images/topbuttons/bar', toggle)

  ProtocolGame.registerExtendedJSONOpcode(POKEBAR_OPCODE, function(protocol, opcode, json_data)
    local action = json_data.action
    local data = json_data.data
    switch( action ){
      [ACTION_POKEBAR_ADD] 	  = function() onPokemonBarAdd(data)    end,
      [ACTION_POKEBAR_REMOVE] = function() onPokemonBarRemove(data) end,
      [ACTION_POKEBAR_UPDATE] = function() onPokemonBarUpdate(data) end,
    }
  end)
  
  pokemonBar = g_ui.loadUI('pokebar', modules.game_interface.getRootPanel())
end

function terminate()
  disconnect(g_game, {
    onGameStart = onGameStart,
	onGameEnd = onGameEnd,
  })
  disconnect(Creature, {
    onHealthPercentChange = onCreatureHealthPercentChange,
  })
  ProtocolGame.unregisterExtendedJSONOpcode(POKEBAR_OPCODE)
end

function onGameStart()
  local settings = g_settings.getNode('pokebar') 
  
  if ( settings ) then  
	  pokemonBar:breakAnchors()
	  setCompactMode(settings.mode)
      pokemonBar:setPosition(topoint(settings.pos))
      pokeBarButton:setOn(settings.button)
  end   
  if pokeBarButton:isOn() then
      pokemonBar:setVisible(true)
  else
      pokemonBar:setVisible(false)
  end
end

function onGameEnd()
  local settings = {
	mode = pokemonBar:isOn(),
	pos = pointtostring(pokemonBar:getPosition()),
    button = pokeBarButton:isOn(),
  }

  pokemonBar:destroyChildren()
  currentSlotBar = nil
  
  g_settings.setNode('pokebar', settings)
end

function onCreatureHealthPercentChange(creature, health)
  if ( creature:isSummon() and currentSlotBar ) then
    currentSlotBar.progress:setPercent(health)
	currentSlotBar.health:setText(health..'%') 
	currentSlotBar.progress:setBackgroundColor(getHealthColor(health))
  end
end

function onPokemonBarAdd(pokemon)
  local slotBar = g_ui.createWidget('SlotBar', pokemonBar)
  slotBar.onMouseRelease = function(self, mousePosition, mouseButton)	
    if mouseButton == MouseLeftButton and g_clock.millis() > self.dragLeave then
		g_game.talkChannel(MessageModes.None, 0 , '!p ' .. pokemon.fastcallNumber)
	end
	return true
  end
  
  slotBar.onDragEnter = onDragEnter
  slotBar.onDragMove = onDragMove
  slotBar.onDragLeave = onDragLeave
    
  g_mouse.bindPress(slotBar, createMenu, MouseRightButton) 

  slotBar.background:setChecked(pokemonBar:isOn())
  slotBar:setId(pokemon.fastcallNumber)  
  updateSlotBar(slotBar, pokemon)
  resize()
end

function onPokemonBarRemove(fastcallNumber)
  local slotBar = pokemonBar[fastcallNumber]
  if ( slotBar ) then
    removeSlotBar(slotBar)
	resize()
  end
end

function onPokemonBarUpdate(pokemon)
  local slotBar = pokemonBar[pokemon.fastcallNumber]
  if slotBar then
    updateSlotBar(slotBar, pokemon)
  else
    onPokemonBarAdd(pokemon)
  end
end

function toggle()
    if pokeBarButton:isOn() then
        pokemonBar:setVisible(false)
        pokeBarButton:setOn(false)
    else
        pokemonBar:setVisible(true)
        pokeBarButton:setOn(true)
    end
end

function setCompactMode(value)
  for i, child in pairs(pokemonBar:getChildren()) do
    child.background:setChecked(value)
  end
  pokemonBar:setOn(value)
end

function createMenu()
  local menu = g_ui.createWidget('PopupMenu')
  menu:addOption((pokemonBar:isOn() and tr('Big') or tr('Small')), function() setCompactMode(not pokemonBar:isOn()) end)
  menu:display()
end