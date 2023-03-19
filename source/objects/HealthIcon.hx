package objects;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
		if(isPlayer == true)
			flipX = true; //stupid animation.addByPrefix doesnt flip it
	}

	public function swapOldIcon()
	{
		isOldIcon = !isOldIcon;
		changeIcon(isOldIcon ? 'bf-old' : 'bf');
	}

	public function changeIcon(char:String)
	{
		if (char == 'senpai')
			antialiasing = false;
		else if (char == 'spirit')
			antialiasing = false;
		else
			antialiasing = !PreferencesMenu.getPref('performance-mode');

		if (char != 'bf-pixel' && char != 'bf-old' && char != 'bf-holding-gf')
			char = char.split('-')[0].trim();

		if (char != this.char)
		{
			if (animation.getByName(char) == null)
			{
				frames = Paths.getSparrowAtlas('icons/icon-' + char);
				animation.addByPrefix('normal', char + ' normal', 24, true);
				animation.addByPrefix('lose', char + ' lose', 24, true);
			}
			animation.play('normal', true);
			this.char = char;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function bounce(amount:Float) {
		setGraphicSize(Std.int(150 * amount));
		updateHitbox();
	}
}