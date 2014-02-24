/*
Copyright (c) 2013 Kael Fraga

	This file is part of Mage Escape.

    Mage Escape is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Mage Escape is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Mage Escape.  If not, see <http://www.gnu.org/licenses/>.
*/
package;

import org.flixel.FlxSprite;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.util.FlxPoint;

/**
 * ...
 * @author Kael Fraga
 */
class Enemy extends FlxSprite
{
	private var targ:FlxSprite; //who the enemy will chase
	private var flightDirection:Int = 1; //th direction of the bat flight, 1 if left, 2 if right
			
	public function new() 
	{
		super();
	
		this.loadGraphic("assets/bat.png", true, true, 30, 30);
		addAnimation("flyRight", [5, 6, 7, 8, 9], 10, true);
		addAnimation("flyLeft", [0, 1, 2, 3, 4], 10, true);
				
		this.x = 0;
		this.y = 0;
						
		//Setting drag for the enemy
		drag.x = 100;
				
		/*
		 * uncomment FlxG.showBounds = true to see the bounding rect for the enemy sprite
		 * we resize the enemy sprite so that the collision is not completely wrong(you
		 * dont want the whole 32x32 sprite to collide but the region where the enemy actually is)
		*/
		width = 10;
		height = 10;
		offset = new FlxPoint(13, 13);
	
	}
	
	public function setTarget(t:FlxSprite) { //receives the player as a target
		targ = t;
	}
	
	override public function update() {
		
		//Calculates the distance between the enemy and its target and sets its way
		var distX:Int = Math.round(this.x - targ.x);
		var distY:Int = Math.round(this.y - targ.y);
		
		if ( this.onScreen() )
		{
		if (distX > 5) {
			this.velocity.x = -30;
			this.facing = FlxObject.LEFT;
			play("flyLeft");
			flightDirection = 1;
			
		} else if (distX < -5){
			this.velocity.x = 30;
			this.facing = FlxObject.RIGHT;
			play("flyRight");
			flightDirection = 2;
			
		}else 
			if (flightDirection == 1)
				play("flyLeft");
			else
				play("flyRight");
			
		
		if (distY > 0) {
			this.velocity.y = -30;
			this.facing = FlxObject.UP;
			
		} else {
			this.velocity.y = 30;
			this.facing = FlxObject.DOWN;
			
		}
		}

		super.update();
	}
	
}