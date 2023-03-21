package options;

import flixel.FlxObject;
import flixel.FlxCamera;
import haxe.ds.StringMap;

class PreferencesMenu extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;
	
	var prefDescription:FlxText;
	var description:String = 'Unknown';

	override public function new()
	{
		super();
		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;
		add(items = new TextMenuList());
		#if !html5
		createPrefItem('120 FPS Mode', '120-fps', false); //until I figure out how to code my OWN options menu we are just gonna do this for now
		#end
		createPrefItem('Performance Mode', 'performance-mode', false);
		createPrefItem('Ghost Tapping', 'ghostTapping', true);
		createPrefItem('Downscroll', 'downscroll', false);
		createPrefItem('Flashing Lights', 'flashing-lights', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', true);
		createPrefItem('FPS Counter', 'fps-counter', true);
		createPrefItem('Freeplay Autoplay Song', 'fas', true);
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}

		/*
		var idk:FlxSprite = new FlxSprite(0, FlxG.height - 220).makeGraphic(1100, 200, FlxColor.BLACK);
		idk.scrollFactor.set();
		idk.screenCenter(X);
		idk.alpha = 0.8;
		add(idk);
		
		prefDescription = new FlxText(0, idk.y + 10, idk.width - 200, "", 32);
		prefDescription.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		prefDescription.scrollFactor.set();
		add(prefDescription);
		*/

		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	public static function getPref(pref:String)
	{
		return preferences.get(pref);
	}

	/*
	public static function savePrefs()
	{
		FlxG.save.data.censorNaughty = getPref('censor-naughty');

		FlxG.save.flush();
	}
	*/

	public static function initPrefs()
	{
		#if !html5
		preferenceCheck('120-fps', false);
		#end
		preferenceCheck('performance-mode', false);
		preferenceCheck('ghostTapping', true);
		preferenceCheck('downscroll', false);
		preferenceCheck('flashing-lights', true);
		preferenceCheck('camera-zoom', true);
		preferenceCheck('fps-counter', true);
		preferenceCheck('master-volume', 1);
		preferenceCheck('fas', true);

		/*
		if(FlxG.save.data.censorNaughty != null)
		{
			var censorNaughty:Bool = getPref('censor-naughty');
			censorNaughty = FlxG.save.data.censorNaughty;
			preferenceCheck('censor-naughty', censorNaughty);
		}
		*/
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			trace('set preference!');
		}
		else
		{
			trace('found preference: ' + Std.string(preferences.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		else
		{
			trace('swag');
		}
		trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		//savePrefs();
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;
		trace('toggled? ' + Std.string(preferences.get(identifier)));
		switch (identifier)
		{
			#if !html5
			case '120-fps':
				FlxG.updateFramerate = 120;
				FlxG.drawFramerate = 120;
			#end
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		menuCamera.followLerp = CoolUtil.camLerpShit(0.05);
		items.forEach(function(item:MenuItem)
		{
			if (item == items.members[items.selectedIndex])
			{
				/*
				switch (item)
				{
					case 'performance-mode':
						description = 'If Enabled: Disables Antialiasing, Removes some animations and Removes some sprites.';
					case 'ghost-tapping':
						description = 'If Enabled: Everytime you press a note keybind, You wont get a miss.';
					case 'downscroll':
						description = 'If Enabled: Some parts of the UI go from bottom to top instead of top to bottom.';
					case 'flashing-lights':
						description = "If Enabled: Flashing Lights Show.\nIt's Recommended to disable this if you are sensitive to flashing lights!";
					case 'camera-zoom':
						description = 'If Enabled: Camera Zooms in every beat hit.';
					case 'fps-counter':
						description = "If Disabled: FPS Counter doesn't show.";
					default:
						description = 'Unknown';
				}
				*/
				item.x = 150;
			}
			else
				item.x = 120;
		});
	}
}