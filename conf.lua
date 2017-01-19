function love.conf(t)
	t.title         	= "The Tower"
	t.version 			  = "0.10.2"
  t.identity        = "__data"

	t.window.width  	= 1280
	t.window.height 	= 720
  --t.window.width    = 0 -- use desktop resolution
  --t.window.height   = 0 -- use desktop resolution

	t.window.fullscreen = false  --//TODO mudar para true

  t.window.resizable = true

  t.console = true
end
