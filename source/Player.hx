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
import org.flixel.util.FlxTimer;
import org.flixel.plugin.photonstorm.FlxWeapon;
import org.flixel.plugin.photonstorm.baseTypes.Bullet;
import org.flixel.plugin.photonstorm.FlxControl;
import org.flixel.plugin.photonstorm.FlxControlHandler;
import org.flixel.util.FlxRandom;
import org.flixel.FlxTilemap;

/**
 * ...
 * @author Kael Fraga
 */
class Player extends FlxSprite
{
	private var _playerSpeed:Float = 70; //player velocity
	private var _flagWalking:Bool = false; //to signal if the player is walking
	public var _playerDie:Bool = false; //to signal if the player die
	private var _canCharge:Bool = true; //enables and disables the charging of MP
	public var shallNotPass:Bool = true; //enables and disables the player to move to right if it is on map bound
	public var mana:Int = 10; //number of times the player can attack
	private var maxMana:Int = 10; //max mana points
	public var staff:FlxWeapon; //the player weapon, a powerful invisible staff :D
		
	public function new() 
	{
		super();
		
		//Loading the animation images
		
		loadGraphic("assets/mage.png", true, true, 32, 32);
		x = 0;
		y = 0;
		addAnimation("idle1", [1]); //idle and side
		addAnimation("idle2", [4]); //standing with his front
		addAnimation("idle3", [7]); //standing with his back
		addAnimation("walkh", [0, 1, 2, 1], 4, true); //walking in horizontal
		addAnimation("walkd", [3, 4, 5, 4], 4, true); //walking down
		addAnimation("walku", [6, 7, 8, 7], 4, true); //walking up
		addAnimation("recharge", [9,10,11],8,true); //charging mana
		addAnimation("death", [12, 13, 14], 3, false); //dying
		
		/**
		 * setting speed along with a drag for the player
		 */
		maxVelocity = new FlxPoint(_playerSpeed, 200); 
		drag = new FlxPoint(_playerSpeed + 50, _playerSpeed + 50);
		
		/*
		 * uncomment FlxG.showBounds = true to see the bounding rect for the player sprite
		 * we resize the player sprite so that the collision is not completely wrong(you
		 * dont want the whole 32x32 sprite to collide but the region where the player actually is)
		*/
		width =  10;
		height = 12;
		offset = new FlxPoint(10, 16);
		
		//Creates our weapon. We'll call it "staff" and link it to the x/y coordinates of the player sprite
		staff = new FlxWeapon("staff", this);
		
		//Tell the weapon to create 50 bullets using the bullet image.
		//The 1 value is the x offset and -2 y offset
		staff.makeAnimatedBullet(50,"assets/bullet.png", 10, 9, [0, 1], 4, true, 0, 0);

	}
		
	override public function update() {
			
		/**
		 * if the player is not walking and the last animation has not finished then be idle
		 */
		
		if (!_flagWalking && finished && !_playerDie) 
		{
			velocity.x = velocity.y = 0;
			if (facing == FlxObject.LEFT || facing == FlxObject.RIGHT)
				play("idle1");
			else if (facing == FlxObject.UP) 
				play("idle3");
			else if (facing == FlxObject.DOWN) 
				play("idle2");
			
		}
			
		if (FlxG.keys.pressed("UP")&&!_playerDie) 
		{
				velocity.y = -_playerSpeed;
				velocity.x = 0;
				facing = FlxObject.UP;
				
				_flagWalking = true;
				play("walku");
							
		}
		else if (FlxG.keys.pressed("DOWN")&&!_playerDie) 
		{
			velocity.y = _playerSpeed;
			velocity.x = 0;
			facing = FlxObject.DOWN;
			
			_flagWalking = true;
			play("walkd");
					
		}
		else if (FlxG.keys.pressed("LEFT")&&!_playerDie) 
		{
			shallNotPass = true;
			velocity.x = -_playerSpeed;
			velocity.y = 0;
			facing = FlxObject.LEFT;
						
			_flagWalking = true;
			play("walkh");
				
		} 
		else if (FlxG.keys.pressed("RIGHT")&&!_playerDie && shallNotPass) 
		{
			velocity.x = _playerSpeed;
			velocity.y = 0;
			facing = FlxObject.RIGHT;
					
			_flagWalking = true;
			play("walkh");
			
		} 
		else 
		{
			_flagWalking = false;
		}
		
		/**
		 * ATTACK! when you hit Z or Space 
		 */
		if (FlxG.keys.justPressed("Z") || FlxG.keys.justPressed("SPACE")&&!_playerDie) 
			{
			velocity.x = velocity.y = 0;
			// Set fire button and other settings
			if (mana>0){
				if (staff.fire()) //if a magical attack was fired, the mana is subtracted
				{
					mana--;
				}
			}
			
			// Set fire rate
			staff.setFireRate(850);
		}
		else if ( FlxG.keys.pressed("X") || FlxG.keys.pressed("SHIFT")&& !_playerDie) 
		{
					
		/*
		 * Recharge mana! when you hit X or Shift
		*/
			velocity.x = velocity.y = 0;
			play("recharge");
				if (_canCharge && mana < maxMana) 
				{ 
					mana++;
					_canCharge = false;
					FlxTimer.manager.add(new FlxTimer().start(1, 1, onTimer)); //timer to control the charging
				}
		}
		
		if (_playerDie ) 
		{
			velocity.x = velocity.y = 0;
			play("death");
		}
		
		/*
		 * Adjust the direction of attack in relation to player facing
		*/
		
		if (this.facing == FlxObject.RIGHT)
			staff.setBulletDirection(FlxWeapon.BULLET_RIGHT,200);
		else if (this.facing == FlxObject.LEFT)
			staff.setBulletDirection(FlxWeapon.BULLET_LEFT,200);
		else if (this.facing == FlxObject.UP)
			staff.setBulletDirection(FlxWeapon.BULLET_UP, 200);
		else
			staff.setBulletDirection(FlxWeapon.BULLET_DOWN, 200);
		
		super.update();
	}
	
	private function onTimer(timer:FlxTimer):Void
			{
				
			_canCharge = true;
		
			//sound of mp recharge
			Main.playSound("mp");

			}
}