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

import org.flixel.util.FlxRandom;

/**
 * ...
 * @author Kael Fraga
 */
class RandomCave
{
	private var _numTilesCols:Int; 
	private var _numTilesRows:Int; 
	private var _walk:Bool = true; //control variable
	
	/**
	 * 
	 * @param	nCols	Number of columns in the cave tilemap
	 * @param	nRows	Number of rows in the cave tilemap
	 */
	public function new(nCols:Int = 10, nRows:Int = 10) 
	{
		_numTilesCols = nCols;
		_numTilesRows = nRows;
	}
	
	/**
	 * @param 	mat    A matrix of data
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
	
	/**
	 * 
	 * @param	rows 	Number of rows for the matrix
	 * @param	cols	Number of cols for the matrix
	 * 
	 * @return Spits out a matrix that is cols x rows, one initiated
	 */
	private function genInitMatrix(rows:Int, cols:Int):Array<Array<Int>>
	{
		// Build array of 1s, means a map full of walls
		var mat:Array<Array<Int>> = new Array<Array<Int>>();
		for (y in 0...(rows))
		{
			mat.push(new Array<Int>());
			for (x in 0...(cols)) 
			{
				mat[y].push(1);
			}
		}
		
		return mat;
	}
	
	/**
	 * 
	 * @param	inMat	The inicial data matrix 
	*/	
	private function runRandomWalk(inMat:Array<Array<Int>>):Void
	{
		var startPoint:Int = Math.ceil(FlxRandom.float() * (_numTilesRows - 2)); //a random position on second column in mat
		var X:Int = 1; //X is the column
		var Y:Int = startPoint; //Y is the row
		var direction:Int; //is the direction the algorithm will "walk" and "dig" the cave space
		inMat[Y][X] = 0; //the first position "digged"
	
		do{ //makes a loop until the algorithm walking from one side to the other of the map
			direction = Math.ceil(FlxRandom.float() * 4); //the direction is random
			if (direction==1){ //up
				if (Y > 1){
					Y--;
					inMat[Y][X] = 0;
				}
			}
			else if (direction==2){ //down
				if (Y < _numTilesRows-2){
					Y++;
					inMat[Y][X] = 0;
				}
			}
			else if (direction==3){ //left
				if (X > 1){
					X--;
					inMat[Y][X] = 0;
				}
			}
			else if (direction==4){ //right
				if (X < _numTilesCols-1){
					X++;
					inMat[Y][X] = 0;
				}
			}

		}while( X < _numTilesCols-1);
	}
	
	/**
	 * 
	 * @return Returns a matrix of a cave!
	 */
	public function generateCaveLevel():Array<Array<Int>>
	{
		var mat:Array<Array<Int>> = genInitMatrix(_numTilesRows, _numTilesCols);
		
		runRandomWalk(mat);
		
		return mat;
	}
}