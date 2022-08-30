package;

import flixel.math.FlxMath;
import ui.PreferencesMenu;
import lime.utils.Assets;
import ui.OptionsState;
#if DISCORD_RPC
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	//public static var neoncrusherEngineVersion:String = '0.1';
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story_mode', 'freeplay', 'stats', 'donate', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var bgl:FlxSprite;

	override function create()
	{
		#if DISCORD_RPC
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

		FunkinWindow.changeAppName(FunkinWindow.appName + " - Main Menu");

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = !PreferencesMenu.getPref('performance-mode');
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = !PreferencesMenu.getPref('performance-mode');
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		bgl = new FlxSprite(0, 0).loadGraphic(Paths.image('mainmenu/menubg'));
		bgl.screenCenter();
		bgl.x -= 40;
		bgl.scrollFactor.set();
		add(bgl);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var tex = Paths.getSparrowAtlas('mainmenu/items/' + optionShit[i]);
			var menuItem:FlxSprite = new FlxSprite(70, 60 + (i * 130));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scale.set(0.8, 0.8);
			menuItem.scrollFactor.set(0, 1);
			menuItem.antialiasing = !PreferencesMenu.getPref('performance-mode');
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 38, 0, "NeonCrusher Engine v" + getVer(), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeItem();

		super.create();
	}

	public static function getVer() {
		if (Assets.getText(Paths.txt('version')) != null)
			return Assets.getText(Paths.txt('version'));
		else
			return "???";
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		menuItems.forEach(function(spr:FlxSprite)
		{
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
	
			if (spr.ID == curSelected)
			{
				spr.x = FlxMath.lerp(spr.x, 130, lerpVal);
			} else {
				spr.x = FlxMath.lerp(spr.x, 60, lerpVal);
			}
	
			//spr.updateHitbox();

			switch (spr.ID) {
				case 0:
					//FlxTween.color(bgl, 0.3, FlxColor.fromRGB());
			}	
		});

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if (PreferencesMenu.getPref('flashing-menu'))
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (PreferencesMenu.getPref('flashing-menu'))
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'story_mode':
											FlxG.switchState(new StoryMenuState());
										case 'freeplay':
											FlxG.switchState(new FreeplayState());
										case 'stats':
											FlxG.switchState(new GameStatsState());
										case 'donate':
											#if linux
											Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
											#else
											FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
											#end
											FlxG.resetState();
										case 'options':
											FlxG.switchState(new OptionsState());
									}
								});
							}
							else
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										FlxG.switchState(new StoryMenuState());
									case 'freeplay':
										FlxG.switchState(new FreeplayState());
									case 'stats':
										FlxG.switchState(new GameStatsState());
									case 'donate':
										#if linux
										Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
										#else
										FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
										#end
										FlxG.switchState(new MainMenuState()); //Had to switch it back to main menu otherwise everything dies in the main menu
									case 'options':
										FlxG.switchState(new OptionsState());
								}
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		/*
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
		*/
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
