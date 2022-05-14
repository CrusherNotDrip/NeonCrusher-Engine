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
	public var canBounce:Bool = true;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		this.isPlayer = isPlayer;
		changeIcon(char);
		antialiasing = true;
		scrollFactor.set();
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
				loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
				animation.add(char, [0, 1], 0, false, isPlayer);
			}
			animation.play(char);
			this.char = char;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);

		if(canBounce) {
			var mult:Float = FlxMath.lerp(1, scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
			scale.set(mult, mult);
			updateHitbox();
		}
	}

	public function bounce() {
		if(canBounce) {
			var mult:Float = 1.2;
			scale.set(mult, mult);
			updateHitbox();
		}
	}
}