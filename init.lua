-- CONFIG
APP_NAME = "pokediamond"  -- important, change it, it's name for config dir and files in appdata
APP_VERSION = 1       -- client version for updater and login to identify outdated client
DEFAULT_LAYOUT = "default" -- on android it's forced to "mobile", check code bellow

-- If you don't use updater or other service, set it to updater = ""
Services = {
  -- website = "http://otclient.ovh", -- currently not used
--   updater = "http://pokebs.com.br/api/updater.php",
  -- stats = "",
  -- crash = "http://otclient.ovh/api/crash.php",
  -- feedback = "http://otclient.ovh/api/feedback.php",
  -- status = "http://otclient.ovh/api/status.php"
}

-- Servers accept http login url, websocket login url or ip:port:version
Servers = {
  PokeDiamond = "127.0.0.1:7171:1098",
--   PokeDiamondTests = "127.0.0.1:7171:1098"
}

--Server = "ws://otclient.ovh:3000/"
--Server = "ws://127.0.0.1:88/"
--USE_NEW_ENERGAME = true -- uses entergamev2 based on websockets instead of entergame
ALLOW_CUSTOM_SERVERS = false -- if true it shows option ANOTHER on server list

g_app.setName("Pokemon Diamond")
-- CONFIG END

-- print first terminal message
g_logger.info(os.date("== application started at %b %d %Y %X"))
g_logger.info(g_app.getName() .. ' ' .. g_app.getVersion() .. ' rev ' .. g_app.getBuildRevision() .. ' (' .. g_app.getBuildCommit() .. ') made by ' .. g_app.getAuthor() .. ' built on ' .. g_app.getBuildDate() .. ' for arch ' .. g_app.getBuildArch())

-- local files = g_resources.listDirectoryFiles('/')
-- for _,file in pairs(files) do
--   if g_resources.isFileType(file, 'ini') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'key') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'spr') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'dat') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'rar') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'zip') then
--     g_logger.fatal("O Client não pode ser iniciado!.")
--   end
--   if g_resources.isFileType(file, 'dll') then
--     if file ~= 'd3dcompiler_47.dll' and 
--        file ~= 'libEGL.dll' and 
--        file ~= 'libGLESv2.dll' and 
--        file ~= 'lua5.1.dll' and 
--        file ~= 'msvcp140.dll' and 
--        file ~= 'vcruntime140.dll' then
--       g_logger.fatal("O Client não pode ser iniciado!.")
--     end
--   end
  -- if g_resources.isFileType(file, 'exe') then
  --   if file ~= 'otclient_gl.exe' and file ~= 'otclient_dx.exe' then
  --     g_logger.fatal("O Client não pode ser iniciado!.")
  --   end
  -- end
--   if g_resources.isFileType(file, 'lua') then
--     if file ~= 'init.lua' then
--       g_logger.fatal("O Client não pode ser iniciado!.")
--     end
--   end
-- end

if not g_resources.directoryExists("/data") then
  g_logger.fatal("Data dir doesn't exist.")
end

if not g_resources.directoryExists("/modules") then
  g_logger.fatal("Modules dir doesn't exist.")
end

-- settings
g_configs.loadSettings("/config.otml")

-- set layout
local settings = g_configs.getSettings()
local layout = DEFAULT_LAYOUT
if g_app.isMobile() then
  layout = "mobile"
elseif settings:exists('layout') then
  layout = settings:getValue('layout')
end
g_resources.setLayout(layout)

-- load mods
g_modules.discoverModules()
g_modules.ensureModuleLoaded("corelib")
  
local function loadModules()
  -- libraries modules 0-99
  g_modules.autoLoadModules(99)
  g_modules.ensureModuleLoaded("gamelib")

  -- client modules 100-499
  g_modules.autoLoadModules(499)
  g_modules.ensureModuleLoaded("client")

  -- game modules 500-999
  g_modules.autoLoadModules(999)
  g_modules.ensureModuleLoaded("game_interface")

  -- mods 1000-9999
  g_modules.autoLoadModules(9999)
end

-- report crash
if type(Services.crash) == 'string' and Services.crash:len() > 4 and g_modules.getModule("crash_reporter") then
  g_modules.ensureModuleLoaded("crash_reporter")
end

-- run updater, must use data.zip
if type(Services.updater) == 'string' and Services.updater:len() > 4 
  and g_resources.isLoadedFromArchive() and g_modules.getModule("updater") then
  g_modules.ensureModuleLoaded("updater")
  return Updater.init(loadModules)
end
loadModules()
