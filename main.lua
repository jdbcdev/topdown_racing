
application:setKeepAwake(true)
application:setOrientation(Application.LANDSCAPE_LEFT)

local width = application:getContentWidth()
local height = application:getContentHeight()

local function draw_loading()
	loading = Sprite.new()
	
	local logo = Bitmap.new(Texture.new("images/jdbc_games.png", true))
	logo:setPosition((width - logo:getWidth()) * 0.5, 130)
	loading:addChild(logo)	
		
	stage:addChild(loading)
end

local function preloader()
 	
	stage:removeEventListener(Event.ENTER_FRAME, preloader)
	
	-- Load all your assets here
	--ImagesLoader.setup()
	
	-- Game starting
	--scenes = {"menu", "choose", "game", "score", "worldcup"}
	scenes = {"track"}

	sceneManager = SceneManager.new({
		--["menu"] = MenuScene,
		["game"] = GameScene,
		["track"] = TrackScene
		})

	stage:addChild(sceneManager)
	
	local currentScene = scenes[1]
	
	local timer = Timer.new(1000, 1)
	timer:addEventListener(Event.TIMER, 
				function()
					-- Remove loading scene
					stage:removeChild(loading)
					loading = nil
					sceneManager:changeScene(currentScene)
				end)
	timer:start()
end

draw_loading()
stage:addEventListener(Event.ENTER_FRAME, preloader)