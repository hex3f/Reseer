package org.taomee.algo
{
   import flash.geom.Point;
   
   public class AStar
   {
      
      private static var _instance:AStar;
      
      public static const aroundsData:Array = [new Point(1,0),new Point(0,1),new Point(-1,0),new Point(0,-1),new Point(1,1),new Point(-1,1),new Point(-1,-1),new Point(1,-1)];
      
      private var _fatherList:Array;
      
      private const NOTE_ID:int = 0;
      
      private var _noteMap:Array;
      
      private var _mapModel:IMapModel;
      
      private var _maxTry:int;
      
      private const NOTE_CLOSED:int = 2;
      
      private var _nodeList:Array;
      
      private var _openId:int;
      
      private var _openCount:int;
      
      private const COST_DIAGONAL:int = 14;
      
      private var _pathScoreList:Array;
      
      private var _openList:Array;
      
      private const COST_STRAIGHT:int = 10;
      
      private const NOTE_OPEN:int = 1;
      
      private var _movementCostList:Array;
      
      public function AStar()
      {
         super();
      }
      
      public static function find(param1:Point, param2:Point) : Array
      {
         return getInstance()._find(param1,param2);
      }
      
      private static function getInstance() : AStar
      {
         if(_instance == null)
         {
            _instance = new AStar();
         }
         return _instance;
      }
      
      public static function get maxTry() : int
      {
         return getInstance()._maxTry;
      }
      
      public static function init(param1:IMapModel, param2:int = 1000) : void
      {
         getInstance()._mapModel = param1;
         getInstance()._maxTry = param2;
      }
      
      private function isBlock(param1:Point) : Boolean
      {
         if(param1.x < 0 || param1.x >= this._mapModel.gridX || param1.y < 0 || param1.y >= this._mapModel.gridY)
         {
            return false;
         }
         return this._mapModel.data[param1.x][param1.y];
      }
      
      private function _find(param1:Point, param2:Point) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Point = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Array = null;
         var _loc9_:Point = null;
         if(this._mapModel == null)
         {
            return null;
         }
         param1 = this.transPoint(param1);
         var _loc10_:Point = this.transPoint(param2.clone());
         if(!this.isBlock(_loc10_))
         {
            return null;
         }
         this.initLists();
         this._openCount = 0;
         this._openId = -1;
         this.openNote(param1,0,0,0);
         var _loc11_:int = 0;
         while(this._openCount > 0)
         {
            if(++_loc11_ > this._maxTry)
            {
               this.destroyLists();
               return null;
            }
            _loc3_ = int(this._openList[0]);
            this.closeNote(_loc3_);
            _loc4_ = this._nodeList[_loc3_];
            if(_loc10_.equals(_loc4_))
            {
               return this.getPath(param1,_loc3_);
            }
            _loc8_ = this.getArounds(_loc4_);
            for each(_loc9_ in _loc8_)
            {
               _loc6_ = this._movementCostList[_loc3_] + (_loc9_.x == _loc4_.x || _loc9_.y == _loc4_.y ? this.COST_STRAIGHT : this.COST_DIAGONAL);
               _loc7_ = _loc6_ + (Math.abs(_loc10_.x - _loc9_.x) + Math.abs(_loc10_.y - _loc9_.y)) * this.COST_STRAIGHT;
               if(this.isOpen(_loc9_))
               {
                  _loc5_ = int(this._noteMap[_loc9_.y][_loc9_.x][this.NOTE_ID]);
                  if(_loc6_ < this._movementCostList[_loc5_])
                  {
                     this._movementCostList[_loc5_] = _loc6_;
                     this._pathScoreList[_loc5_] = _loc7_;
                     this._fatherList[_loc5_] = _loc3_;
                     this.aheadNote(this._openList.indexOf(_loc5_) + 1);
                  }
               }
               else
               {
                  this.openNote(_loc9_,_loc7_,_loc6_,_loc3_);
               }
            }
         }
         this.destroyLists();
         return null;
      }
      
      private function closeNote(param1:int) : void
      {
         --this._openCount;
         var _loc2_:Point = this._nodeList[param1];
         this._noteMap[_loc2_.y][_loc2_.x][this.NOTE_OPEN] = false;
         this._noteMap[_loc2_.y][_loc2_.x][this.NOTE_CLOSED] = true;
         if(this._openCount <= 0)
         {
            this._openCount = 0;
            this._openList = [];
            return;
         }
         this._openList[0] = this._openList.pop();
         this.backNote();
      }
      
      private function isOpen(param1:Point) : Boolean
      {
         if(this._noteMap[param1.y] == null)
         {
            return false;
         }
         if(this._noteMap[param1.y][param1.x] == null)
         {
            return false;
         }
         return this._noteMap[param1.y][param1.x][this.NOTE_OPEN];
      }
      
      private function getArounds(param1:Point) : Array
      {
         var _loc2_:Point = null;
         var _loc3_:Boolean = false;
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         var _loc6_:Boolean = this.isBlock(_loc2_);
         if(_loc6_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         var _loc7_:Boolean = this.isBlock(_loc2_);
         if(_loc7_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         var _loc8_:Boolean = this.isBlock(_loc2_);
         if(_loc8_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         var _loc9_:Boolean = this.isBlock(_loc2_);
         if(_loc9_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         _loc3_ = this.isBlock(_loc2_);
         if(_loc3_ && _loc6_ && _loc7_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         _loc3_ = this.isBlock(_loc2_);
         if(_loc3_ && _loc8_ && _loc7_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         _loc3_ = this.isBlock(_loc2_);
         if(_loc3_ && _loc8_ && _loc9_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         _loc2_ = param1.add(aroundsData[_loc5_]);
         _loc5_++;
         _loc3_ = this.isBlock(_loc2_);
         if(_loc3_ && _loc6_ && _loc9_ && !this.isClosed(_loc2_))
         {
            _loc4_.push(_loc2_);
         }
         return _loc4_;
      }
      
      private function aheadNote(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(param1 > 1)
         {
            _loc2_ = int(param1 / 2);
            if(this.getScore(param1) >= this.getScore(_loc2_))
            {
               break;
            }
            _loc3_ = int(this._openList[param1 - 1]);
            this._openList[param1 - 1] = this._openList[_loc2_ - 1];
            this._openList[_loc2_ - 1] = _loc3_;
            param1 = _loc2_;
         }
      }
      
      private function backNote() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 1;
         while(true)
         {
            _loc1_ = _loc3_;
            if(2 * _loc1_ <= this._openCount)
            {
               if(this.getScore(_loc3_) > this.getScore(2 * _loc1_))
               {
                  _loc3_ = 2 * _loc1_;
               }
               if(2 * _loc1_ + 1 <= this._openCount)
               {
                  if(this.getScore(_loc3_) > this.getScore(2 * _loc1_ + 1))
                  {
                     _loc3_ = 2 * _loc1_ + 1;
                  }
               }
            }
            if(_loc1_ == _loc3_)
            {
               break;
            }
            _loc2_ = int(this._openList[_loc1_ - 1]);
            this._openList[_loc1_ - 1] = this._openList[_loc3_ - 1];
            this._openList[_loc3_ - 1] = _loc2_;
         }
      }
      
      private function openNote(param1:Point, param2:int, param3:int, param4:int) : void
      {
         ++this._openCount;
         ++this._openId;
         if(this._noteMap[param1.y] == null)
         {
            this._noteMap[param1.y] = [];
         }
         this._noteMap[param1.y][param1.x] = [];
         this._noteMap[param1.y][param1.x][this.NOTE_OPEN] = true;
         this._noteMap[param1.y][param1.x][this.NOTE_ID] = this._openId;
         this._nodeList.push(param1);
         this._pathScoreList.push(param2);
         this._movementCostList.push(param3);
         this._fatherList.push(param4);
         this._openList.push(this._openId);
         this.aheadNote(this._openCount);
      }
      
      private function eachArray(param1:Point, param2:int, param3:Array) : void
      {
         param1.x *= this._mapModel.gridSize;
         param1.y *= this._mapModel.gridSize;
      }
      
      private function transPoint(param1:Point) : Point
      {
         param1.x = int(param1.x / this._mapModel.gridSize);
         param1.y = int(param1.y / this._mapModel.gridSize);
         return param1;
      }
      
      private function getPath(param1:Point, param2:int) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:Point = this._nodeList[param2];
         while(!param1.equals(_loc4_))
         {
            _loc3_.push(_loc4_);
            param2 = int(this._fatherList[param2]);
            _loc4_ = this._nodeList[param2];
         }
         _loc3_.push(param1);
         this.destroyLists();
         _loc3_.reverse();
         this.optimize(_loc3_);
         _loc3_.forEach(this.eachArray);
         return _loc3_;
      }
      
      private function getScore(param1:int) : int
      {
         return this._pathScoreList[this._openList[param1 - 1]];
      }
      
      private function initLists() : void
      {
         this._openList = [];
         this._nodeList = [];
         this._pathScoreList = [];
         this._movementCostList = [];
         this._fatherList = [];
         this._noteMap = [];
      }
      
      private function destroyLists() : void
      {
         this._openList = null;
         this._nodeList = null;
         this._pathScoreList = null;
         this._movementCostList = null;
         this._fatherList = null;
         this._noteMap = null;
      }
      
      private function isClosed(param1:Point) : Boolean
      {
         if(this._noteMap[param1.y] == null)
         {
            return false;
         }
         if(this._noteMap[param1.y][param1.x] == null)
         {
            return false;
         }
         return this._noteMap[param1.y][param1.x][this.NOTE_CLOSED];
      }
      
      private function optimize(param1:Array, param2:int = 0) : void
      {
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Point = null;
         if(param1 == null)
         {
            return;
         }
         var _loc9_:int = param1.length - 1;
         if(_loc9_ < 2)
         {
            return;
         }
         var _loc10_:Point = param1[param2];
         var _loc11_:Array = [];
         var _loc12_:int = _loc9_;
         while(_loc12_ > param2)
         {
            _loc3_ = param1[_loc12_];
            _loc4_ = Point.distance(_loc10_,_loc3_);
            _loc5_ = Math.atan2(_loc3_.y - _loc10_.y,_loc3_.x - _loc10_.x);
            _loc6_ = 1;
            while(_loc6_ < _loc4_)
            {
               _loc8_ = _loc10_.add(Point.polar(_loc6_,_loc5_));
               _loc8_.x = int(_loc8_.x);
               _loc8_.y = int(_loc8_.y);
               if(!Boolean(this._mapModel.data[_loc8_.x][_loc8_.y]))
               {
                  _loc11_ = [];
                  break;
               }
               _loc11_.push(_loc8_);
               _loc6_++;
            }
            _loc7_ = int(_loc11_.length);
            if(_loc7_ > 0)
            {
               param1.splice(param2 + 1,_loc12_ - param2 - 1);
               param2 += _loc7_ - 1;
               break;
            }
            _loc12_--;
         }
         if(param2 < _loc9_)
         {
            this.optimize(param1,++param2);
         }
      }
   }
}

