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

import org.flixel.FlxButton;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;
import org.flixel.plugin.photonstorm.FlxWeapon;
import org.flixel.plugin.photonstorm.baseTypes.Bullet;
import org.flixel.plugin.photonstorm.FlxControl;
import org.flixel.plugin.photonstorm.FlxControlHandler;
import org.flixel.util.FlxRandom;
import org.flixel.addons.FlxBackdrop;
import haxe.Timer;
import flash.events.Event;
import flash.Lib;

//Procedural elements
import procedural.RandomCave;
import procedural.Composer;
import procedural.DungeonGenerator;
import procedural.MazeGenerator;

//Explosion
import org.flixel.addons.FlxEmitterExt;
import org.flixel.FlxGroup;
import org.flixel.FlxText;
import org.flixel.util.FlxTimer;

//Sounds
import org.si.sion.SiONData;

/**
 * ...
 * @author Kael Fraga
 */

class Level extends FlxState 
{
	private var level:Int = 1;
	public var _player:Player; //the mage
	public var playerSpawn:FlxPoint; //the position of mage on map
	private var enemyGroup:FlxGroup; //group of enemies
	private var _gemas:FlxGroup; //itens to pick up
	private var enemiesPerLevel:Int;
	
	//Scenario
	private var _map:FlxTilemap; 
	private var mapMatrix:Array<Array<Int>>; //array which stores all map positions
	private var availableTiles:Array<FlxPoint>; //array which stores all positions there are not walls
	private var _floor:FlxBackdrop; //background image
	private var _edge:FlxSprite; //finish line
	private var _interface:FlxSprite; //UI

	//Background music
	private var song:SiONData;

	//Magic effects
	private var _explosion:FlxEmitterExt;
	
	//Information on the interface
	private var _info:FlxText; //prints the level number
	private var _infoScore:FlxText; //prints acquired points
	private var _warning:FlxText; //warning message
	private var _kills:Int = 0; //number of enemies killed
	private var showWarning:Bool = false; //enables the warning message
	private var _score:Int = 0; //auxiliary variable to store the points acquired in each level
	private var _playerKills:FlxText; //prints the number of enemies killed
	private var _mpBar:FlxSprite; //prints the quantity of mana available
	
	//Debugs
	private var _debug:FlxButton; //shows boxes
	private var _debug2:FlxButton; //level hack buttons
	private var _debug3:FlxButton;
	private var developerMode = false; //actives the debug mode if TRUE

	override public function new(level:Int=1):Void { //receives as a parameter the last level before Game Over
		super();
		this.level = level;
		FlxRandom.globalSeed = level; //sets the global seed for random numbers as the level
		if (level == 1) Reg.score = 0; //resets the points 
	}

	override public function create():Void 
	{
		enemiesPerLevel = Math.ceil(Math.sqrt(level)); //sets the number of enemies in each level
	
		_score = 0; //resets the points acquired in a private level
					
		/**
		 * Fade in from black 
		 */
		FlxG.flash(FlxColor.BLACK, 1, null);
		FlxG.mouse.hide(); //hides the mouse
		
		/*
		 * Creating the level scenario (Cave,Maze or Dungeon)
		*/
		createScenario(); 
		
		//Setup collectables
		makeCollectibles();
		
		/**
		 * Creating the player
		 */
		makePlayer();	   
						
		//Interface Informations
		makeInterface();
					
		/**
		 * The world bounds need to be set for the collision to work properly
		 */
		FlxG.worldBounds = new FlxRect(0, 0, _map.width+50, _map.height+50);
						
		/**
		 * We ask the Flixel camera subsystem to follow the player sprite with a slight lag or not(lerp)
		 */
		FlxG.camera.follow(_player, FlxCamera.STYLE_PLATFORMER);
		FlxG.camera.bounds = _map.getBounds();		
				
		//Add explosion emitter to magic attack effects
		makeExplosion();
				
		 //Setup enemies
		makeEnemies();
		
		//Setup background song
		makeSong(); 
		
		//Add the debug buttons
		if (developerMode){
			makeDebug();
		}
	
		//Level start sound
		Main.playSound("change");
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	/**
	 * We override the update funtion to update the player position, do collision checks and check input to move
	 * the player around each frame.
	 */
	override public function update():Void 
	{	
		/**
		 * Checks collision
		 */
		FlxG.collide(_player, _map);
		
		//if the player overlaps with the exit sprite, then it calls this anonymous function
		//and fades the screen to the next state
		FlxG.overlap(_player, _edge, onEnd);  
			
		FlxG.collide(_map, _player.staff.group, BulletHit);
		
		FlxG.collide(_map, enemyGroup);
		
		FlxG.collide(enemyGroup, enemyGroup);
		
		if (!_player._playerDie) //if the player is dead the enemies don't collide with him. If not, the player die
			FlxG.collide(_player, enemyGroup, killPlayer);
		else
			FlxG.overlap(_player, enemyGroup);
			
		//FlxG.overlap(_player, _gemas, playerCollect, null);
		FlxG.overlap(_player, _gemas, playerCollect);
		
		FlxG.collide(enemyGroup, _player.staff.group, BulletHit);
	
		//Updates the number of killed enemies
		_playerKills.text = Std.string(_kills +" / " + enemiesPerLevel);
		
		if (showWarning){ //if te player find the exit but don't killed all enemies, shows this message to him
			_warning.text = Std.string("To leave you must\ndefeat all enemies!");
		}
		else {
			_warning.text = Std.string(" ");
		}
		
		if (FlxG.keys.justPressed("ESCAPE")) 
		{
			BackMenu(); //back to Menu screen
		}
		
		//Updates the current mana available
		manaBarAnimation();
		
		super.update();
	}
	
	/*
	 *Collision Functions
	*/
	
	private function onEnd(Obj1:FlxObject, Obj2:FlxObject):Void //called when the player reaches the end of the level
	{
		_player.shallNotPass = false; //prevents the player to advance if it reaches the end of the map
		_player.velocity.x = 0; //stops the player 
		if (_kills == enemiesPerLevel) //if the player killed all enemies he passes level
		{
			FlxG.switchState(new Level(level + 1));
			Reg.score += _score; //the points adquired in the level is added to general score
			Reg.level = level + 1;
		}
		else
		{
			showWarning = true; //if the player dont killed all enemies he is adverted
			FlxTimer.manager.add(new FlxTimer().start(1, 1, onTimer2)); //after one second the message disappear
		}
	}
	
	private function BulletHit(Obj1:FlxObject, Obj2:FlxObject):Void  //called when the magical attack hit some target
	{
		Obj2.kill();
		explode(Obj2.x, Obj2.y); //happens a explosion on the collision position

		if (Std.is(Obj1, Enemy)){
			Obj1.kill();
			_kills++; //if the target is a enemy the target is killed and the counter is added
		}
	}
	
	function playerCollect(player:FlxObject, collectible:FlxObject):Void //called when the player picks up an item
	{ 
		//sound of pick up
		Main.playSound("pick");
		
		_gemas.remove(collectible);
		_score += 1; 
		
		//Updates the score information
		_infoScore.text = Std.string(Reg.score+_score);
	}
	
	private function killPlayer(Obj1:Player, Obj2:FlxObject):Void //called when the player die
	{
		//sound of death
		Main.playSound("death");
		
		Obj1._playerDie = true;
		
		Reg.score += _score;
		if (level == 1) {
			Reg.maxScore = Reg.score; //stores the score to show it to the player
		}
		else {
			if (Reg.score > Reg.maxScore) {
				Reg.maxScore = Reg.score; //stores the score and compare with last scores
			}	
		}
		FlxTimer.manager.add(new FlxTimer().start(2, 1, onTimer)); //after 2 seconds call the fade
	}
	
	private function onFade():Void
	{
		// FlxG.fade.start also takes in a callback which is called after the fade ends!!
		Main.driver.pause(); //pauses the song
		FlxG.switchState(new EndGame()); //return to game over screen
	}
	
	/*
	 *Creation functions
	*/ 
	
	private function makeExplosion():Void 
	{			
		_explosion = new FlxEmitterExt();
		_explosion.setMotion(0, 30, 0.001, 360, 30, 0.001);
		_explosion.setMotion(0, 5, 0.2, 360, 10, 0.8);
		_explosion.makeParticles("assets/particles.png", 20, 0, true, 0);
		_explosion.setAlpha(1, 1, 0, 0);
		_explosion.setColor(0xFFFFFF00, 0xFFFF0000); 
		_explosion.setScale(1, 1, 0, 0);
		add(_explosion);				
	}	
	
	private function explode(x:Float = 0, y:Float = 0):Void //called when explode something 
	{			
			_explosion.x = x;
			_explosion.y = y;
			_explosion.start(true, 0.4, 0.1, 0, 0.4);
			_explosion.update();
			
			//sound of boom
			Main.playSound("boom");
	}
	
	private function makePlayer():Void 
	{
		var playerSpawn:FlxPoint = definePlayerSpawn(); //a random place in the left side of map to player spawn
		_player = new Player();
		
		//Stores the coordinates 
		_player.x = playerSpawn.x; 
		_player.y = playerSpawn.y;
				
		add(_player); 
		_player.staff.setBulletBounds(_map.getBounds()); //set the limits of player attacks
		add(_player.staff.group); //creates the player "weapon"
	}
	
	private function makeCollectibles():Void 
	{
		_gemas = new FlxGroup(); //creates a group of items
		add(_gemas);
		
		var gemSpawn:FlxPoint;
		var j:Int = 0;
		while (j < 5) { //always five per level
			
			//sorts random position to the items
			var cx = FlxRandom.float() * _map.width;
			var cy = FlxRandom.float() * _map.height;

			var collectible:FlxSprite = new FlxSprite(cx, cy);
			if (!collectible.overlaps(_map) && !collectible.overlaps(_gemas)) { //tests if the items are in an available position
				collectible.loadGraphic("assets/gema.png");
				_gemas.add(collectible);
				j++;
			}
		}
	}
	
	private function makeEnemies():Void 
	{
		//makes the group for the enemies and add it to the game
		enemyGroup = new FlxGroup();
		add(enemyGroup);
		
		//makes enemies in random positions
		var enemy:Enemy;
		var enemySpawn:FlxPoint;
		var i:Int = 0;
		while (i < enemiesPerLevel) 
		{
			enemy = new Enemy();
			//similar logic of the player and items creation
			enemySpawn = availableTiles[Math.round(FlxRandom.float() * (availableTiles.length-1))];		
			enemy.x = enemySpawn.x;
			enemy.y = enemySpawn.y;
			
			//the random place must be in the right side of map and the enemy cant overlap player
			if (!enemy.overlaps(_player) && !(enemy.x < (_map.width/2))) { 
				enemy.setTarget(_player); //the enemy will chase the player around the map
				enemyGroup.add(enemy);
				i++;
			}
		}	
	}
	
	
	private function createScenario():Void
	{
		/**
		 * loading a map!
		 * The FlxTilemap class takes in a string of numbers and converts them into a map, you can either pass
		 * it a string or use the built in helper static functions in FlxTilemap to convert a bitmap/image into
		 * a csv; which is what I'm doing here. The second param to loadMap takes in a tilesheet to be used with
		 * the tilemap. The fourth and fifth is the width and height of a single tile in the tile sheet. FlxTilemap
		 * does an auto tiling for you if you want it. This is *OFF* by default and you have to set it by setting the
		 * map.auto to either FlxTilemap.AUTO(for platform friendly tiling) or FlxTilemap.ALT(for the alternate top down tiling)
		 */
				 
		var scenarioType:Int = 1;
		 
		//defines the type of scenario, 1=Dungeon, 2=Cave, 3=Maze
		 if (level <= 10)
		 {
			scenarioType = 1;
		 }		 
		 else if (level <= 20)
		 {
			scenarioType = 2;
		 }
		 else if (level <= 30)
		 {
			scenarioType = 3;
		 }
		 else
		 {
			var randomScenario:Float = Math.random();
						
			if (randomScenario < 0.3)
				scenarioType = 1;
			else if (randomScenario > 0.6)
				scenarioType = 2;
			else
				scenarioType = 3;
		 }
		 
		 switch (scenarioType)
		 {
			 case 1:
				 {
					var caveW:Int = 10 + Math.ceil(Math.sqrt(level) * 10);
					var caveH:Int = 5 + Math.ceil(Math.sqrt(level) * 10);
					var rooms:Int = 2 + Math.ceil(Math.sqrt(level));
		
					// Create the dungeons
					var dg:DungeonGenerator = new DungeonGenerator(caveW, caveH, rooms,true);

					// Generate the level and returns a matrix
					// 0 = empty, 1 = wall tile
					mapMatrix = dg.SendDG();

					// Converts the matrix into a string that is readable by FlxTileMap
					var dataStr:String = DungeonGenerator.convertMatrixToStr(mapMatrix);
		
					//BackDrop
					_floor = new FlxBackdrop("assets/wallback.png");
							
					// Loads tilemap of tilesize 16x16
					_map = new FlxTilemap();
					_map.loadMap(dataStr,"assets/wallset.png", 20, 20, FlxTilemap.AUTO);
				}
			
			case 2:
				 {
					var caveW:Int = 10 + Math.ceil(Math.sqrt(level) * 10);
					var caveH:Int = 5 + Math.ceil(Math.sqrt(level) * 10);
		 
					// Create cave of size 40x30 tiles
					var cave:RandomCave = new RandomCave(caveW, caveH);

					// Generate the level and returns a matrix
					// 0 = empty, 1 = wall tile
					mapMatrix = cave.generateCaveLevel();

					// Converts the matrix into a string that is readable by FlxTileMap
					var dataStr:String = RandomCave.convertMatrixToStr(mapMatrix);
			
					//BackDrop
					_floor = new FlxBackdrop("assets/caveback.png");
		
					// Loads tilemap of tilesize 16x16
					_map = new FlxTilemap();
					_map.loadMap(dataStr,"assets/caveset.png", 20, 20, FlxTilemap.AUTO);
				}
				
			case 3:
				 {
					var mazeW:Int = 10+ Math.ceil(Math.sqrt(level) * 10);
					var mazeH:Int = 5+ Math.ceil(Math.sqrt(level) * 10);
					// Create the Maze
					var mz:MazeGenerator = new MazeGenerator(mazeW, mazeH);

					// Generate the level and returns a matrix
					// 0 = empty, 1 = wall tile
					mapMatrix = mz.SendMaze();

					// Converts the matrix into a string that is readable by FlxTileMap
					var dataStr:String = MazeGenerator.convertMatrixToStr(mapMatrix);
			
					//BackDrop
					_floor = new FlxBackdrop("assets/mazeback.png");
		
					// Loads tilemap of tilesize 16x16
					_map = new FlxTilemap();
					_map.loadMap(dataStr, "assets/mazeset.png", 20, 20, FlxTilemap.AUTO);
				}
		 }
		 
		add(_floor);
		add(_map);
		_edge = new FlxSprite( _map.width,0, "assets/edge.png");
		add(_edge);
		 	
		availableTiles = _map.getTileCoords(0);
	}
	
	private function makeInterface():Void 
	{
		_infoScore = new FlxText(180, 215, 100);
		_infoScore.text = Std.string(Reg.score);
		_infoScore.setFormat(null, 10, 0xffffff, "right");
		_infoScore.scrollFactor.x = _infoScore.scrollFactor.y = 0; //to the text follow the camera
		add(_infoScore);
				
		_playerKills = new FlxText(180, 190, 100);
		_playerKills.text = Std.string(_kills +" / " + enemiesPerLevel);
		_playerKills.setFormat(null,10, 0xff0000, "right");
		_playerKills.scrollFactor.x = _playerKills.scrollFactor.y = 0;
		add(_playerKills);
	
		_warning = new FlxText(120,120, 100);
		_warning.text = Std.string(" ");
		_warning.setFormat(null, 12, 0xffffff, "center");
		_warning.scrollFactor.x = _warning.scrollFactor.y = 0;
		add(_warning);
		
		_mpBar = new FlxSprite(7,170);
		_mpBar.loadGraphic("assets/mpbar.png", true, true, 60, 60);
		_mpBar.addAnimation("stage1", [0]);
		_mpBar.addAnimation("stage2", [1]); 
		_mpBar.addAnimation("stage3", [2]); 
		_mpBar.addAnimation("stage4", [3]); 
		_mpBar.addAnimation("stage5", [4]);
		_mpBar.scrollFactor.x = _mpBar.scrollFactor.y = 0;
		add(_mpBar);
		
		_interface = new FlxSprite(0, 0, "assets/interface.png");
		_interface.scrollFactor.x = _interface.scrollFactor.y = 0;
		add(_interface);
		
		_info = new FlxText(15, 180, 50);
		_info.text = Std.string(level);
		_info.setFormat(null, 16, 0xffffff, "center");
		_info.scrollFactor.x = _info.scrollFactor.y = 0; //to the text follow the camera
		add(_info);	
	}
	
	/*
	 * Debug Functions 
	 * called when the debug buttons are pressed
	*/
	
	private function makeDebug():Void 
	{
		//Button to active hitboxes debug mode
		_debug = new FlxButton(10, 10, "BOXES", onStart);
		_debug.scrollFactor.x = _debug.scrollFactor.y = 0;
						
		//Button to automatically level transition 
		_debug2 = new FlxButton(120, 10, "Level Up", LevelHack );
		_debug3 = new FlxButton(230, 10, "Level Down", LevelHack2 );
		_debug2.scrollFactor.x = _debug2.scrollFactor.y = 0;
		_debug3.scrollFactor.x = _debug3.scrollFactor.y = 0;
			
		FlxG.mouse.show();
		add(_debug);
		add(_debug2);
		add(_debug3);
	}
	
	private function onStart():Void 
	{
		FlxG.visualDebug = !FlxG.visualDebug;
	}
	
	private function LevelHack():Void
	{
		FlxG.switchState(new Level(level + 1));
	}
	
	private function LevelHack2():Void
	{
		if (level >1)
			FlxG.switchState(new Level(level - 1));
	}
	
	/*
	 * Sound Functions 
	*/
	
	private function makeSong():Void
	{	
			//Rhythm
			var numrhythms:Int = Math.round(FlxRandom.float()*3 + 3);				
			var steps:Int = 0;
			var rhythms:Array<String> =  new Array<String>(); //array of rhythms converted to string
			var rhythm:Array<Array<Int>> =  new Array<Array<Int>>(); //a rhythm
			var test:Array<String> =  new Array<String>();
			var scale:String = 'cdefgab';
			var i:Int;
			for ( i in 0 ... (numrhythms)) {
				steps = 16;
				rhythm = Composer.makeRhythm(Math.round(FlxRandom.float()*(steps - 1)) + 1, steps); 
				//trace(Composer.rhythmToString(rhythm));				
				rhythms.push(Composer.rhythmToMML(rhythm, scale.charAt(Math.round(FlxRandom.float()*(scale.length - 1))), Math.round(FlxRandom.float()*(127) + 0)));				
				test.push(Composer.rhythmToString(rhythm));
			}
			var allrhythms:String = rhythms.join(" ");
			var harmony:String = Composer.makeHarmony(test, 4, Math.round(FlxRandom.float()*70+50),Math.round(FlxRandom.float()*4+2));
			var melody:String = Composer.makeMelody(test, 4, Math.round(FlxRandom.float()*70+50),Math.round(FlxRandom.float()*2+2));
			//trace(allrhythms);
			//trace(Composer.calcAccentInterval(test));
			//trace(harmony);
			//trace(melody);

			song = Main.driver.compile(allrhythms + harmony + melody); //compile all song
			Main.driver.play(song);						
	}
	
	/*
	 *Other functions 
	*/ 
	
	//Defines the player spawn point
	private function definePlayerSpawn():FlxPoint
	{
		//The spawn point is the first tile empty in the extreme left of map
		var y:Int = 1;
		var x:Int = 1;
		var search: Bool = true;
		var spawnPoint:FlxPoint = new FlxPoint(x,y);
		
		for (x in 0...(mapMatrix[y].length))
		{
			for (y in 0...(mapMatrix.length))
			{			
				if (mapMatrix[y][x] == 0 && search)
				{
					spawnPoint.x = x * 20;
					spawnPoint.y = y * 20;
					search = false;
				}
			}
		}
			
		return spawnPoint;
	}
	
	private function manaBarAnimation():Void
	{
		if (_player.mana == 0)
		{
			_mpBar.play("stage1");
		}		
		else if (_player.mana < 3)
		{
			_mpBar.play("stage2");
		}
		else if (_player.mana < 6)
		{
			_mpBar.play("stage3");
		}
		else if (_player.mana < 8)
		{
			_mpBar.play("stage4");
		}
		else
		{
			_mpBar.play("stage5");
		}
	}
	
	private function onTimer(timer:FlxTimer):Void
	{
		_player.kill();
		FlxG.fade(FlxColor.BLACK, 3, false, onFade);
	}
	
	private function onTimer2(timer:FlxTimer):Void
	{
		showWarning = false;
	}
	
	private function BackMenu():Void
	{
		Main.driver.pause();
		FlxG.switchState(new MenuMain());
	}
}