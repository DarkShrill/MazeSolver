function love.conf(t)

  t.identity                     = ""                                           -- The name of the save directory
  t.version                      = "11.1"                                       -- The LOVE version this was made for
  t.console                      = true                                         -- Attach a console (Windows only)
  
  t.window.title                 = ""                                           -- The title of the window
  t.window.icon                  = nil                                          -- File to an image to use as the window icon
  
  t.window.width                 = 800                                          -- Window width 1280, 1366, 1680, 1920
  t.window.height                = 800                                          -- Window height 800, 768, 1050, 1080
  t.window.borderless            = false                                        -- Remove all border visuals from the window
  t.window.resizable             = false                                        -- Let the window be user-resizeable
  t.window.minwidth              = 800                                          -- Minimum window width if the window is resizeable
  t.window.minheight             = 800                                          -- Minimum window height if the window is resizeable
  
  t.window.fullscreen            = false                                        -- Enable full screen
  t.window.fullscreentype        = "exclusive"                                  -- Desktop, exclusive
  
  t.window.vsync                 = 0                                            -- Enable vertical sync
  t.window.msaa                  = 0                                            -- The number of samples to use with multi-sampled anti-aliasing
  t.window.display               = 1                                            -- Index of the monitor to show the window in
  t.window.highdpi               = false                                        -- Enable high-dpi mode for the window on a Retina display
  t.window.gammacorrect          = false                                        -- Enable gamma correction when drawing to the screen
  
  t.modules.filesystem           = true                                         -- 
  t.modules.audio                = true                                         -- 
  t.modules.event                = true                                         -- 
  t.modules.graphics             = true                                         -- 
  t.modules.image                = true                                         -- 
  t.modules.joystick             = true                                         -- 
  t.modules.keyboard             = true                                         -- 
  t.modules.math                 = true                                         -- 
  t.modules.mouse                = true                                         -- 
  t.modules.sound                = true                                         -- 
  t.modules.system               = true                                         -- 
  t.modules.timer                = true                                         -- 
  t.modules.window               = true                                         -- 
  t.modules.thread               = true                                         -- 
  
  t.modules.video                = false                                        -- 
  t.modules.touch                = false                                        -- 
  t.modules.data                 = false                                        -- 
  t.modules.physics              = false                                        -- 
  t.accelerometerjoystick        = false                                        -- 
  t.externalstorage              = false                                        -- 
  
end
