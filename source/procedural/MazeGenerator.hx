/*
Copyright (c) 2013 Kael Fraga

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package procedural;

import org.flixel.util.FlxPoint;
import org.flixel.util.FlxRandom;

/**
 * ...
 * @author Kael Fraga
 */
class MazeGenerator
{
	private var MapWidth:Int;
	private var MapHeight:Int;
	private var _Map:Array<Array<Int>>;
	private var column:Int;
	private	var row:Int;
	
	/**
	 * 
	 * @param	nCols	Number of columns in the map tilemap
	 * @param	nRows	Number of rows in the map tilemap
	 */	
	public function new(nCols:Int = 10, nRows:Int = 10) 
	{
		MapWidth = nCols;
		MapHeight = nRows;
	}
	
	/**
	 * @param 	mat		A matrix of data
	 * 
	 * @return 	A string that is usuable for FlxTileMap.loadMap(...)
	 */
	static public function convertMatrixToStr(mat:Array<Array<Int>>):String
	{
		var mapString:String = "";
		
		for (y in 0...(mat.length))
		{
			for (x in 0...(mat[y].length))
			{
				mapString += Std.string(mat[y][x]);
				if (x < mat[y].length - 1) {
					mapString += ",";
				}
			}
			
			mapString += "\n";
		}
		
		return mapString;
	}	
	
	/*
		Initializes the map matrix full of walls
	*/	
	private function InitMatrix(rows:Int, cols:Int):Void
	{
		_Map = new Array<Array<Int>>();
		for (y in 0...(rows))
		{
			_Map.push(new Array<Int>());
			for (x in 0...(cols)) 
			{
				_Map[y].push(1);
			}
		}
	}	
	
	/**
	 * Sorts the array of directions
	*/
	private function mySort(x:Int, y:Int):Int {	
		var r:Float = FlxRandom.float();
		if (r < 1 / 3) return -1;
		else if (r < 2 / 3) return 0;
		else return 1;
	}
	
	/**
	 * Depth-first search (DFS) is an algorithm for traversing or searching 
	 * tree or graph data structures. One starts at the root (selecting 
	 * some arbitrary node as the root in the case of a graph) and explores 
	 * as far as possible along each branch before backtracking. (Wikipedia)
	 * 
	 * @param	x	The X position to DFS go
	 * @param	y	The Y position to DFS go
	 * @param	w   The direction that DFS will "run"
	*/
	private function runDFS(x:Int,y:Int,w:Int):Void
	{
		if (!IsWall(x, y, w))
		{
			_Map[y][x] = 0;
					
			var directions:Array<Int> = [1, 2, 3, 4];
			directions.sort(mySort);
			
			for (i in 0 ... 4)
			{
				if (directions[i] == 1) runDFS(x, y - 1, 1);
				if (directions[i] == 2) runDFS(x, y + 1, 2);
				if (directions[i] == 3) runDFS(x + 1, y, 3);
				if (directions[i] == 4) runDFS(x - 1, y, 4);
			}
		}		
	}

	/**
	 * Checks whether the DFS can keep running in that way
	 * @param	x	The actual X position of DFS
	 * @param	y	The actual Y position of DFS
	 * @param	w   The actual direction of DFS
	*/
	private function IsWall(x:Int,y:Int,w:Int):Bool
	{
		if( IsOutOfBounds(x,y) )
		{
			return true;
		}
		/*
		* 	Checks whether the analyzed position has already been traversed 
		* 	or is a neighbor that has already been traversed
		*/
		else if( (_Map[y+1][x]==0) && ( w !=1 ))
		{
			return true;
		}
		else if( (_Map[y-1][x]==0) && ( w !=2 ))
		{
			return true;
		}
		else if( (_Map[y][x-1]==0) && ( w !=3 ))
		{
			return true;
		}
		else if( (_Map[y][x+1]==0) && ( w !=4 ))
		{
			return true;
		}
		else if( _Map[y][x]==1 )
		{
			return false;
		}
	 	
		return false;
	}
	
	/**
	 * Checks whether the analyzed position is outside the map bounds
	 * @param	x	The actual X position of DFS
	 * @param	y	The actual Y position of DFS
	*/
	private function IsOutOfBounds(x:Int,y:Int):Bool
	{
		if( x<1 || y<1 )
		{
			return true;
		}
		else if( x>MapWidth-2 || y>MapHeight-2 )
		{
			return true;
		}
		return false;
	}
		
	/**
	 * Creates the exit hall
	*/
	private function MakeExit():Void
	{
		//The exit hall is a random tile in the extreme right of map connected to a maze hall
		var y:Int = Math.ceil(FlxRandom.float() * (MapHeight - 4)+1);
		var x:Int = MapWidth;
		var dig:Bool = true;		
		
		do 
		{ 	
			x--;
				
			if (_Map[y][x] == 0)
				dig = false;
			
			_Map[y][x] = 0;
		} 
		while (dig);			
	}
	
	/**
	 * @return 	The finished map to the level
	*/
	public function SendMaze():Array<Array<Int>>
	{
		InitMatrix(MapHeight, MapWidth);
		
		var x:Int = 1;
		var y:Int = Math.ceil(FlxRandom.float() * (MapHeight - 4)+1);
		var w:Int = 0;
		
		//w is the direction of the WAY
		/*
		 0 = start
		 1 = up
		 2 = down
		 3 = right
		 4 = left
		 */
		 
		runDFS(x, y, w);
		
		MakeExit();
		
		return _Map;
	}
}