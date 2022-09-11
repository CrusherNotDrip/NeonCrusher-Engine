package;

import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;
import openfl.geom.Matrix;
import flixel.addons.transition.TransitionData;
import ui.PreferencesMenu;
import lime.app.Application;
#if DISCORD_RPC
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import WiggleEffect.WiggleShader;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;

#if VIDEOS_ALLOWED
import VideoHandler;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var gameVar:PlayState;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var practiceMode:Bool = false;
	public static var botplay:Bool = false;
	public static var modeUsed:Bool = false;
	public static var seenCutscene:Bool = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;
	private var vocalsFinished = false;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	private var daWindow:FunkinWindow;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var dadStrums:FlxTypedGroup<FlxSprite>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var notesHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var lightColors:Array<FlxColor>;
	var light:FlxSprite;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var lightFadeShader:BuildingShaders;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var laHentaiShader:PixelShader = new PixelShader();

	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var talking:Bool = true;

	var scoreTxt:FlxText;
	var watermarks:FlxText;
	var judgementCounter:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	public static var pixelStage:Bool = false;

	var inCutscene:Bool = false;

	#if DISCORD_RPC
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//sum song ratings shit n stuff like that

	public var ghostTaps:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var songScore:Int = 0;
	public var combo:Int = 0;
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public static var blueballed:Int = 0;

	override public function create()
	{
		gameVar = this;
		if (isStoryMode) 
			FunkinWindow.changeAppName("Friday Night Funkin': NeonCrusher Engine" + " - " + SONG.song + " - " + CoolUtil.difficultyString()  + " - (Story Mode)");
		else
			FunkinWindow.changeAppName("Friday Night Funkin': NeonCrusher Engine" + " - " + SONG.song + " - " + CoolUtil.difficultyString()  + " - (Freeplay)");

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var instPath = Paths.inst(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(instPath, SOUND) || OpenFlAssets.exists(instPath, MUSIC))
			OpenFlAssets.getSound(instPath, true);
		var vocalsPath = Paths.voices(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(vocalsPath, SOUND) || OpenFlAssets.exists(vocalsPath, MUSIC))
			OpenFlAssets.getSound(vocalsPath, true);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		notesHUD = new FlxCamera();
		notesHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(notesHUD, false);
		FlxG.cameras.add(camHUD, false);

		pixelStage = false;

		if(!PreferencesMenu.getPref('performance-mode'))
		{
			grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
			var splash:NoteSplash = new NoteSplash(100, 100, 0);
			grpNoteSplashes.add(splash);
			splash.alpha = 0;
		}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if DISCORD_RPC
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		curStage = SONG.stage;
		if (SONG.stage == null) {
			switch (SONG.song.toLowerCase())
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					curStage = 'tank';
				default:
					curStage = 'stage';
			}
		}

		switch (curStage)
		{
			case 'stage':
		        defaultCamZoom = 0.9;

				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		        add(bg);

		        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		        stageFront.updateHitbox();
		        stageFront.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        stageFront.scrollFactor.set(0.9, 0.9);
		        stageFront.active = false;
		        add(stageFront);

		        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		        stageCurtains.updateHitbox();
		        stageCurtains.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        stageCurtains.scrollFactor.set(1.3, 1.3);
		        stageCurtains.active = false;
		        add(stageCurtains);

            case 'spooky':
	            halloweenLevel = true;

		        var hallowTex = Paths.getSparrowAtlas('halloween_bg');
	            halloweenBG = new FlxSprite(-200, -100);
		        halloweenBG.frames = hallowTex;
	            halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				if (!PreferencesMenu.getPref('performance-mode'))
	            	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
                halloweenBG.animation.play('idle');
	            halloweenBG.antialiasing = !PreferencesMenu.getPref('performance-mode');
	            add(halloweenBG);

		        isHalloween = true;

		    case 'philly':
		        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		        bg.scrollFactor.set(0.1, 0.1);
		        add(bg);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					lightFadeShader = new BuildingShaders();
	
					lightColors = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
					light = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win'));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = !PreferencesMenu.getPref('performance-mode');
					light.shader = lightFadeShader.shader;
					add(light);
	
					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					add(streetBehind);
	
					if (!PreferencesMenu.getPref('performance-mode')) {
						phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
						add(phillyTrain);
					}
	
					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
					FlxG.sound.list.add(trainSound);
				}

		        var street:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/street'));
	            add(street);

		    case 'limo':
		        defaultCamZoom = 0.90;

		        var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		        skyBG.scrollFactor.set(0.1, 0.1);
		        add(skyBG);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);
	
					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}
	
					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
					overlayShit.alpha = 0.5;
	
					var limoTex = Paths.getSparrowAtlas('limo/limoDrive');
	
					limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = !PreferencesMenu.getPref('performance-mode');
	
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
				}
		    
		    case 'mall':
		        defaultCamZoom = 0.80;

		        var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		        bg.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        bg.scrollFactor.set(0.2, 0.2);
		        bg.active = false;
		        bg.setGraphicSize(Std.int(bg.width * 0.8));
		        bg.updateHitbox();
		        add(bg);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = !PreferencesMenu.getPref('performance-mode');
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);
				}

		        var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		        bgEscalator.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        bgEscalator.scrollFactor.set(0.3, 0.3);
		        bgEscalator.active = false;
		        bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		        bgEscalator.updateHitbox();
		        add(bgEscalator);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
		        	var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		        	tree.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        	tree.scrollFactor.set(0.40, 0.40);
		        	add(tree);

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = !PreferencesMenu.getPref('performance-mode');
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					add(bottomBoppers);
				}

		        var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		        fgSnow.active = false;
		        fgSnow.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        add(fgSnow);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = !PreferencesMenu.getPref('performance-mode');
					add(santa);
				}

		    case 'mallEvil':
		        var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		        bg.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        bg.scrollFactor.set(0.2, 0.2);
		        bg.active = false;
		        bg.setGraphicSize(Std.int(bg.width * 0.8));
		        bg.updateHitbox();
		        add(bg);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
		        	var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		        	evilTree.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        	evilTree.scrollFactor.set(0.2, 0.2);
		        	add(evilTree);
				}

		        var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	            evilSnow.antialiasing = !PreferencesMenu.getPref('performance-mode');
		        add(evilSnow);
            
		    case 'school':
				pixelStage = true;

		        var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		        bgSky.scrollFactor.set(0.1, 0.1);
		        add(bgSky);

				var widShit = Std.int(bgSky.width * 6);

		        var repositionShit = -200;

		        var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		        bgSchool.scrollFactor.set(0.6, 0.90);
		        add(bgSchool);

		        var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		        bgStreet.scrollFactor.set(0.95, 0.95);
		        add(bgStreet);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
	
					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					bgTrees.updateHitbox();
					add(bgTrees);
	
					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
				}

		        bgSky.setGraphicSize(widShit);
		        bgSchool.setGraphicSize(widShit);
		        bgStreet.setGraphicSize(widShit);
		        
		        bgSky.updateHitbox();
		        bgSchool.updateHitbox();
		        bgStreet.updateHitbox();

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);
	
					if (SONG.song.toLowerCase() == 'roses')
						bgGirls.getScared();
	
					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}
		    
		    case 'schoolEvil':
				pixelStage = true;

				var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 1, -1, 1.5);

				var posX:Float = 502;
				var posY:Float = 376;

		        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("weeb/evilSchoolBG"));
				var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("weeb/evilSchoolFG"));

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var waveSprite = new FlxEffectSprite(bg, [waveEffect]);
					waveSprite.x = posX;
					waveSprite.y = posY;
					waveSprite.scrollFactor.set(0.8, 0.9);
					waveSprite.scale.set(6, 6);
					add(waveSprite);

					var waveSpriteFG = new FlxEffectSprite(fg, [waveEffect]);
					waveSpriteFG.x = waveSprite.x;
					waveSpriteFG.y = waveSprite.y;
					waveSpriteFG.scrollFactor.set(0.8, 0.9);
					waveSpriteFG.scale.set(6, 6);
					add(waveSpriteFG);
				}
				else
				{
					bg.x = posX;
					bg.y = posY;
					bg.scrollFactor.set(0.8, 0.9);
		        	bg.scale.set(6, 6);
		        	add(bg);

					fg.x = posX;
					fg.y = posY;
					fg.scrollFactor.set(0.8, 0.9);
		        	fg.scale.set(6, 6);
		        	add(fg);
				}

			case 'tank':
				defaultCamZoom = 0.9;
						
				var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
				add(sky);
						
				var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
				clouds.active = true;
				clouds.velocity.x = FlxG.random.float(5, 15);
				add(clouds);
	
				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					add(mountains);
							
					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					add(buildings);
							
					var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					add(ruins);
				
					var smokeL:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					add(smokeL);
							
					var smokeR:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					add(smokeR);
							
					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					add(tankWatchtower);
							
					tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
					add(tankGround);

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);
				}
						
				var ground:BGSprite = new BGSprite('tankGround', -420, -150);
				ground.setGraphicSize(Std.int(ground.width * 1.15));
				ground.updateHitbox();
				add(ground);

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					moveTank();

					var tankdude0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
					foregroundSprites.add(tankdude0);
	
					var tankdude1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
					foregroundSprites.add(tankdude1);
	
					var tankdude2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
					foregroundSprites.add(tankdude2);
	
					var tankdude4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
					foregroundSprites.add(tankdude4);
	
					var tankdude5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
					foregroundSprites.add(tankdude5);
	
					var tankdude3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
					foregroundSprites.add(tankdude3);
				}
        }

		//too lazy to test to see if this actually works right now
		if (SONG.girlfriend == null)
		{
			switch (curStage)
			{
				case 'limo':
					SONG.girlfriend = 'gf-car';
				case 'mall' | 'mallEvil':
					SONG.girlfriend = 'gf-christmas';
				case 'school':
					SONG.girlfriend = 'gf-pixel';
				case 'schoolEvil':
					SONG.girlfriend = 'gf-pixel';
				case 'tank':
					SONG.girlfriend = 'gf-tankmen';
			}
		}

		gf = new Character(400, 130, SONG.girlfriend);
		gf.scrollFactor.set(0.95, 0.95);
		if (SONG.girlfriend == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;
			if (!PreferencesMenu.getPref('performance-mode'))
			{
				var tankmen:TankmenBG = new TankmenBG(20, 500, true);
				tankmen.strumTime = 10;
				tankmen.resetShit(20, 600, true);
				tankmanRun.add(tankmen);
				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var man:TankmenBG = tankmanRun.recycle(TankmenBG);
						man.strumTime = TankmenBG.animationNotes[i][0];
						man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(man);
					}
				}
			}
		}

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "tankman":
				dad.y += 180;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.x += 260;
				boyfriend.y -= 220;

				if (!PreferencesMenu.getPref('performance-mode')) {
					resetFastCar();
					add(fastCar);
				}

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				if (!PreferencesMenu.getPref('performance-mode'))
				{
					var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
					// evilTrail.changeValuesEnabled(false, false, false, false);
					// evilTrail.changeGraphic()
					add(evilTrail);
					// evilTrail.scrollFactor.set(1.1, 1.1);
				}

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (SONG.girlfriend != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		if(!PreferencesMenu.getPref('performance-mode'))
			add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		dadStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.iconColour, boyfriend.iconColour);
		healthBar.screenCenter(X);
		add(healthBar);
		add(healthBarBG);

		// HayNeonCrusher Engine Watermark
		watermarks = new FlxText(0, 10, FlxG.width, SONG.song + " - " + CoolUtil.difficultyString() + " // NeonCrusher Engine v" + MainMenuState.getVer() + " // Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		watermarks.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermarks.scrollFactor.set();
		add(watermarks);

		judgementCounter = new FlxText(20, 0, FlxG.width, "", 20);
		judgementCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		judgementCounter.borderSize = 2;
		judgementCounter.borderQuality = 2;
		judgementCounter.scrollFactor.set();
		judgementCounter.screenCenter(Y);
		add(judgementCounter);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		scoreTxt.borderQuality = 2;
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		if(!PreferencesMenu.getPref('performance-mode'))
			grpNoteSplashes.cameras = [notesHUD];
		strumLineNotes.cameras = [notesHUD];
		notes.cameras = [notesHUD];

		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		watermarks.cameras = [camHUD];
		judgementCounter.cameras = [camHUD];
		doof.cameras = [camHUD];
		
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					notesHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							notesHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh':
					startVideo('ughCutscene');
				case 'guns':
					startVideo('gunsCutscene');
				case 'stress':
					startVideo('stressCutscene');
				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function startVideo(name:String)
	{
		inCutscene = true;

		#if VIDEOS_ALLOWED
		var filepath:String = Paths.video(name);

		var video:VideoHandler = new VideoHandler();
		video.playVideo(filepath);
		video.finishCallback = function()
		{
			switch (SONG.song.toLowerCase())
			{
				case 'ugh' | 'guns' | 'stress':
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
			}
			startAndEnd();
			return;
		}
		if(SONG.song.toLowerCase() == 'ugh')
		{
			FlxG.camera.zoom = defaultCamZoom * 1.2;
			camFollow.x += 100;
			camFollow.y += 100;
		}
		#else //fuck html5 fr
		var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		new FlxVideo('videos/' + name + '.mp4').finishCallback = function()
		{
			remove(black);
			camHUD.visible = false;
			notesHUD.visible = false;
			switch (SONG.song.toLowerCase())
			{
				case 'ugh' | 'guns' | 'stress':
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
			}
			startCountdown();
		};
		if(SONG.song.toLowerCase() == 'ugh')
		{
			FlxG.camera.zoom = defaultCamZoom * 1.2;
			camFollow.x += 100;
			camFollow.y += 100;
		}
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		camHUD.visible = true;
		notesHUD.visible = true;
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % gfSpeed == 0)
				{
					gf.dance();
				}
				if (swagCounter % 2 == 0)
				{
					if (!boyfriend.animation.curAnim.name.startsWith('sing'))
						boyfriend.dance();
					if (!dad.animation.curAnim.name.startsWith('sing'))
						dad.dance();
				}
				else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
	
				if (generatedMusic)
				{
					notes.members.sort(function (Obj1:Note, Obj2:Note)
					{
						return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
					});
				}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (pixelStage == true)
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (pixelStage == true)
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (pixelStage == true)
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		#if DISCORD_RPC
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong():Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
	{
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			if (pixelStage == true)
			{
				babyArrow.loadGraphic(Paths.image('pixelUI/NOTE_assets'), true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);

				babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.add('static', [0]);
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						}
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.add('static', [1]);
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						}
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.add('static', [2]);
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						}
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.add('static', [3]);
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						}
					}
			}
			else
			{
				babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

				babyArrow.antialiasing = !PreferencesMenu.getPref('performance-mode');
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

				switch (Math.abs(i))
				{
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						}
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						}
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP');
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						}
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						if (!PreferencesMenu.getPref('performance-mode'))
						{
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}
				}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					dadStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if DISCORD_RPC
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if DISCORD_RPC
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if DISCORD_RPC
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if (!_exiting)
		{
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			if (!vocalsFinished)
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	override public function update(elapsed:Float)
	{
		if (botplay)
			scoreTxt.text = "BOTPLAY MODE // Health: " + healthBar.percent + "%";
		if (practiceMode)
			scoreTxt.text = "PRACTICE MODE // Health: " + healthBar.percent + "% // Misses: " + songMisses;
		if (practiceMode && botplay)
			scoreTxt.text = "BOTPLAY MODE // PRACTICE MODE // Health: " + healthBar.percent + "%";
		if (!modeUsed)
			scoreTxt.text = "Score: " + songScore + " // Health: " + healthBar.percent + "% // Misses: " + songMisses;

		judgementCounter.text = 
		'Total Notes Hit: ' + songHits + 
		'\nCombo: ' + combo + 
		
		'\n\nSicks: '+ sicks +
		'\nGoods: ' + goods +
		'\nBads: ' + bads +
		'\nShits: ' + shits +
		'\nMisses: ' + songMisses;

		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
	
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
	
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		switch (curStage)
		{
			case 'philly':
				if (!PreferencesMenu.getPref('performance-mode'))
				{
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}
					lightFadeShader.update(1.5 * (Conductor.crochet / 1000) * FlxG.elapsed);
				}
			case 'tank':
				if (!PreferencesMenu.getPref('performance-mode'))
					moveTank();
		}

		/*
		if(SONG.song.toLowerCase() == 'thorns')
		{
			var currentBeat:Float = (Conductor.songPosition/1000) * (Conductor.bpm/230);

			for (i in 0...8)
			{
				if (PreferencesMenu.getPref('downscroll'))
					noteTweenY(i, FlxG.height - 150 - 40 * Math.cos((currentBeat + i*0.25) * Math.PI), 0.01);
				else
					noteTweenY(i, 50 - 40 * Math.cos((currentBeat + i*0.25) * Math.PI), 0.01);
			}
			
		}
		*/

		super.update(elapsed);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var screenPos:FlxPoint = boyfriend.getScreenPosition();
				var pauseMenu:PauseSubState = new PauseSubState(screenPos.x, screenPos.y);
				openSubState(pauseMenu);
				pauseMenu.camera = camHUD;
			}
		
			#if DISCORD_RPC
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if DISCORD_RPC
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
        iconP1.updateHitbox();
		iconP2.updateHitbox();
		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.play('lose', true);
		else
			iconP1.animation.play('normal', true);

		if (healthBar.percent > 80)
			iconP2.animation.play('lose', true);
		else
			iconP2.animation.play('normal', true);

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming && PreferencesMenu.getPref('camera-zoom'))
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			notesHUD.zoom = FlxMath.lerp(1, notesHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			if (health <= 0 && !practiceMode)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				blueballed++;

				if (FlxG.random.bool(0.1))
					FlxG.switchState(new OldGameOverState());
				else
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_RPC
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
			}
			else
			{
				break;
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var center = strumLine.y + (Note.swagWidth / 2);
				
				// i am so fucking sorry for these if conditions
				if (PreferencesMenu.getPref('downscroll'))
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							
							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	
					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					dadNoteHit(daNote);
				}

				if (botplay)
				{
					if(daNote.mustPress && daNote.botCanHit)
					{
						goodNoteHit(daNote);

						if(!PreferencesMenu.getPref('performance-mode'))
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
									spr.centerOffsets();
								else
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
							});
						}
					}
					if(daNote.mustPress && daNote.isSustainNote && daNote.canBeHit)
					{
						goodNoteHit(daNote);

						if(!PreferencesMenu.getPref('performance-mode'))
						{
							playerStrums.forEach(function(spr:FlxSprite)
							{
								if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
									spr.centerOffsets();
								else
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
							});
						}
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill = daNote.y < -daNote.height;
				if (PreferencesMenu.getPref('downscroll'))
					doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						songMisses++;
						health -= 0.0475;
						vocals.volume = 0;
						combo = 0;

						switch (daNote.noteData)
						{
						    case 0:
							    boyfriend.playAnim('singLEFTmiss', true);
							case 1:
							    boyfriend.playAnim('singDOWNmiss', true);
						    case 2:
							    boyfriend.playAnim('singUPmiss', true);
							case 3:
							    boyfriend.playAnim('singRIGHTmiss', true);
					    }
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		dadStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.finished)
			{
				spr.animation.play('static');
				spr.centerOffsets();
			}
		});

		if (botplay)
		{
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});

			if (boyfriend.animation.curAnim.name.startsWith("sing") && boyfriend.animation.finished)
				boyfriend.dance();
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		GameStatsState.lastPlayed = SONG.song;
		GameStatsState.icon = iconP2.char;
		GameStatsState.iconColour = dad.iconColour;

		if (!modeUsed)
		{
			GameStatsState.totalNotesHit += songHits;
			GameStatsState.totalSicks += sicks;
			GameStatsState.totalGoods += goods;
			GameStatsState.totalBads += bads;
			GameStatsState.totalShits += shits;
			GameStatsState.totalMisses += songMisses;
			GameStatsState.totalBlueballed += blueballed;
	
			GameStatsState.songNotesHit = songHits;
			GameStatsState.songSicks = sicks;
			GameStatsState.songGoods = goods;
			GameStatsState.songBads = bads;
			GameStatsState.songShits = shits;
			GameStatsState.songMisses = songMisses;
			GameStatsState.songBlueballed = blueballed;
		}
		else
		{
			GameStatsState.totalNotesHit += 0;
			GameStatsState.totalSicks += 0;
			GameStatsState.totalGoods += 0;
			GameStatsState.totalBads += 0;
			GameStatsState.totalShits += 0;
			GameStatsState.totalMisses += 0;
			GameStatsState.totalBlueballed += 0;
	
			GameStatsState.songNotesHit = 0;
			GameStatsState.songSicks = 0;
			GameStatsState.songGoods = 0;
			GameStatsState.songBads = 0;
			GameStatsState.songShits = 0;
			GameStatsState.songMisses = 0;
			GameStatsState.songBlueballed = 0;
		}
		
		GameStatsState.songBpm = SONG.bpm;

		blueballed = 0;
		botplay = false;
		practiceMode = false;
		modeUsed = false;
		
		pixelStage = false; //it keeps pixel stage on even if the stage isnt pixelated so we put this here lol
		canPause = false;
		seenCutscene = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !modeUsed)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();

				GameStatsState.saveGameData();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;
					notesHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
				GameStatsState.saveGameData();
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
			GameStatsState.saveGameData();
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		var doSplash:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			doSplash = false;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			doSplash = false;
				bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			doSplash = false;
			goods++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0)
		{
			daRating = 'sick';
			score = 350;
			doSplash = true;
			sicks++;
		}

		if (doSplash && !PreferencesMenu.getPref('performance-mode'))
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
			if (pixelStage)
			{
				laHentaiShader.pixelAmount = 0.1;
				splash.shader = laHentaiShader.shader;
			}
		}

		if (!modeUsed)
			songScore += score; //no use getting score if you dont see it

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (pixelStage == true)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!pixelStage == true)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = !PreferencesMenu.getPref('performance-mode');
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = !PreferencesMenu.getPref('performance-mode');
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!pixelStage == true)
			{
				numScore.antialiasing = !PreferencesMenu.getPref('performance-mode');
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 9 || combo == 0)
				add(numScore);

			if (combo >= 9) {
				add(comboSpr);
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function cameraMovement():Void
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var releaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		if (!botplay)
		{
			if (holdingArray.contains(true) && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
			if (controlArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
				
				var removeList:Array<Note> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (ignoreList.contains(daNote.noteData))
						{
							for (possibleNote in possibleNotes)
							{
								if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
								{
									removeList.push(daNote);
								}
								else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
								{
									possibleNotes.remove(possibleNote);
									possibleNotes.push(daNote);
								}
							}
						}
						else
						{
							possibleNotes.push(daNote);
							ignoreList.push(daNote.noteData);
						}
					}
				});
				for (badNote in removeList)
				{
					badNote.kill();
					notes.remove(badNote, true);
					badNote.destroy();
				}
	
				possibleNotes.sort(function(note1:Note, note2:Note)
				{
					return Std.int(note1.strumTime - note2.strumTime);
				});
	
				if (perfectMode)
				{
					goodNoteHit(possibleNotes[0]);
				}
				else if (possibleNotes.length > 0)
				{
					for (i in 0...controlArray.length)
					{
						if (controlArray[i] && !ignoreList.contains(i))
						{
							badNoteHit();
						}
					}
					for (possibleNote in possibleNotes)
						{
							if (controlArray[possibleNote.noteData])
							{
								goodNoteHit(possibleNote);
							}
						}
					}
					else
						badNoteHit();
			}
	
			if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet && !holdingArray.contains(true) && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');
			}
			if (!PreferencesMenu.getPref('performance-mode'))
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!holdingArray[spr.ID])
						spr.animation.play('static');
			
					if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
						spr.centerOffsets();
					else
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
				});
			}
		}
	}

	function noteMiss(direction:Int = 1):Void
	{
		ghostTaps++;
		if (PreferencesMenu.getPref('ghostTapping') != true)
		{
		    songMisses++;
			
			if (!boyfriend.stunned)
		    {
			    health -= 0.04;
			    if (combo > 10 && gf.animOffsets.exists('sad'))
			    {
				    gf.playAnim('sad');
			    }
			    combo = 0;

				if (!modeUsed)
			    	songScore -= 10;

			    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			    // FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			    // FlxG.log.add('played imss note');

			    boyfriend.stunned = true;

			    // get stunned for 5 seconds
			    new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			    {
				    boyfriend.stunned = false;
			    });
				
				switch (direction)
				{
					case 0:
					    boyfriend.playAnim('singLEFTmiss', true);
					case 1:
					    boyfriend.playAnim('singDOWNmiss', true);
					case 2:
					    boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
				}
			}
		}
	}

	function badNoteHit()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var leftP = controls.NOTE_LEFT_P;
		var downP = controls.NOTE_DOWN_P;
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			var altAnim:String = "";

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim)
					altAnim = '-alt';
			}
			if (note.altNote)
				altAnim = '-alt';

			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
				songHits++;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT' + altAnim, true);
				case 1:
					boyfriend.playAnim('singDOWN' + altAnim, true);
				case 2:
					boyfriend.playAnim('singUP' + altAnim, true);
				case 3:
					boyfriend.playAnim('singRIGHT' + altAnim, true);
			}

			if (!PreferencesMenu.getPref('performance-mode'))
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
			}

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function dadNoteHit(note:Note):Void
	{
		if (SONG.song != 'Tutorial')
			camZooming = true;

		var altAnim:String = "";

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].altAnim)
				altAnim = '-alt';
		}
		if (note.altNote)
			altAnim = '-alt';

		switch (Math.abs(note.noteData))
		{
			case 0:
				dad.playAnim('singLEFT' + altAnim, true);
			case 1:
				dad.playAnim('singDOWN' + altAnim, true);
			case 2:
				dad.playAnim('singUP' + altAnim, true);
			case 3:
				dad.playAnim('singRIGHT' + altAnim, true);
		}

		if (!PreferencesMenu.getPref('performance-mode'))
		{
			dadStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !pixelStage == true)
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				}
			});
		}

		dad.holdTimer = 0;

		if (SONG.needsVoices)
			vocals.volume = 1;

		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		if (!inCutscene && !PreferencesMenu.getPref('performance-mode'))
		{
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			if (trainSound.time >= 4700)
				{
					startedMoving = true;
					gf.playAnim('hairBlow');
				}
		
				if (startedMoving)
				{
					phillyTrain.x -= 400;
		
					if (phillyTrain.x < -2000 && !trainFinishing)
					{
						phillyTrain.x = -1150;
						trainCars -= 1;
		
						if (trainCars <= 0)
							trainFinishing = true;
					}
		
					if (phillyTrain.x < -4000 && trainFinishing)
						trainReset();
				}
		}
	}

	function trainReset():Void
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
				trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		if (!PreferencesMenu.getPref('performance-mode'))
		{
			FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
			halloweenBG.animation.play('lightning');
			if(halloweenBG.animation.curAnim.name == 'lighting' && halloweenBG.animation.finished)
				halloweenBG.animation.play('idle');
		}

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.members.sort(function(note1:Note, note2:Note)
			{
				return sortNotes(FlxSort.DESCENDING, note1, note2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if (PreferencesMenu.getPref('camera-zoom'))
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				camGame.zoom += 0.015;
				camHUD.zoom += 0.03;
				notesHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				camGame.zoom += 0.015;
				camHUD.zoom += 0.03;
				notesHUD.zoom += 0.03;
			}
		}

		iconP1.scale.set(1, 1);
		iconP2.scale.set(1, 1);
		FlxTween.tween(iconP1, {"scale.x": 1.2, "scale.y": 1.2}, 0.3, {ease: FlxEase.circInOut, type: FlxTweenType.BACKWARD}); 
		FlxTween.tween(iconP2, {"scale.x": 1.2, "scale.y": 1.2}, 0.3, {ease: FlxEase.circInOut, type: FlxTweenType.BACKWARD}); 

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.dance();
	
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}
		else if (dad.animation.name.startsWith("dance"))
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'tank':
				if (!PreferencesMenu.getPref('performance-mode'))
					tankWatchtower.dance();
			case 'school':
				if (!PreferencesMenu.getPref('performance-mode'))
					bgGirls.dance();

			case 'mall':
				if (!PreferencesMenu.getPref('performance-mode'))
				{
					upperBoppers.animation.play('bop', true);
					bottomBoppers.animation.play('bop', true);
					santa.animation.play('idle', true);
				}

			case 'limo':
				if (!PreferencesMenu.getPref('performance-mode'))
				{
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});

					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (!PreferencesMenu.getPref('performance-mode'))
				{
					if (!trainMoving)
						trainCooldown += 1;
	
					if (curBeat % 4 == 0)
					{
						lightFadeShader.reset();
	
						curLight = FlxG.random.int(0, lightColors.length - 1);
						light.color = lightColors[curLight];
						light.visible = true;
					}
	
					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
