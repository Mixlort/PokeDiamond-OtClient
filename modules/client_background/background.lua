-- private variables
local background
local clientVersionLabel

-- public functions
function init()
  background = g_ui.displayUI('background')
  background:lower()

  clientVersionLabel = background:getChildById('clientVersionLabel')
  clientVersionLabel:setText("Pokemon Diamond - 2024")

  background:getChildById("config").advancedTooltip = "Configurações"
--   background:getChildById("aviso").advancedTooltip = "pokenumb.com.br"

    -- if not g_game.isOnline() then
      -- addEvent(function() g_effects.fadeIn(clientVersionLabel, 1500) end)
      -- addEvent(function() g_effects.fadeIn(background, 1500) end)
    -- end

  addEvent(function() modules.client_topmenu.getTopMenu():setHeight(0, 1500) end)
  -- modules.client_topmenu.getTopMenu():setHeight(1)

  connect(g_game, { onGameStart = hide })
  connect(g_game, { onGameEnd = show })
end

function terminate()
  disconnect(g_game, { onGameStart = hide })
  disconnect(g_game, { onGameEnd = show })

  -- g_effects.cancelFade(background:getChildById('clientVersionLabel'))
  background:destroy()

  Background = nil
end

function hide()
  background:hide()
  local name = g_game.getCharacterName()
  -- g_window.setTitle("PokeMS (BR)")
  g_window.setTitle("PokeMS (BR) - "..name)
  modules.client_topmenu.getTopMenu():setHeight(36)
end

function show()
  background:show()
  modules.client_topmenu.getTopMenu():setHeight(0)
end

function hideVersionLabel()
  -- background:getChildById('clientVersionLabel'):hide()
end

function setVersionText(text)
  -- clientVersionLabel:setText(text)
end
