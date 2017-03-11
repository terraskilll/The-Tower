require("..engine.lclass")

require("..engine.input")
require("..engine.io.io")
require("..engine.globalconf")
require("..engine.camera/camera")
require("..engine.render/drawmanager")
require("..engine.collision/collisionmanager")

require("../game/screen/credits")
require("../game/screen/menu")
require("../game/screen/play")
require("../game/screen/splash")

require("..engine.game")
require("../game/actors/player/player")

class "TheTower" ("Game")

function TheTower:TheTower()
  self.screens = {}

  self.savegame  = nil

  self.gameobjects = {}

  self.deletedObjects = {}

  self:configure()

  self:addScreen( "EditorScreen", Editor( self ) )

  self:addScreen( "MenuScreen", MenuScreen( self ) )
  self:addScreen( "PlayScreen", PlayScreen( self ) )
  self:addScreen( "SplashScreen", SplashScreen( self ) )
  self:addScreen( "CreditsScreen", CreditsScreen( self ) )

  --//TODO change to SplashScreen
  --self:setCurrentScreen( "PlayScreen" )
  self:setCurrentScreen( "MenuScreen" )
end
