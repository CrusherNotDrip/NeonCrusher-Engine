package;

import flixel.math.FlxMath;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public var char:String;
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;
	public var canBounce:Bool = false;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		antialiasing = true;
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

		if(canBounce) {
			setGraphicSize(Std.int(FlxMath.lerp(150, width, 0.85)));
			updateHitbox();
		}
	}

	public function bounce(amount:Float) {
		if(canBounce) {
			setGraphicSize(Std.int(width * amount));
			updateHitbox();
		}
	}
}