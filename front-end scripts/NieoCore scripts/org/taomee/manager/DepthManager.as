package org.taomee.manager
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.Dictionary;
   
   public class DepthManager
   {
      
      private static var managers:Dictionary;
      
      private var depths:Dictionary;
      
      public function DepthManager()
      {
         super();
         this.depths = new Dictionary(true);
      }
      
      public static function swapDepth(param1:DisplayObject, param2:Number) : int
      {
         return getManager(param1.parent).swapChildDepth(param1,param2);
      }
      
      public static function swapDepthAll(param1:DisplayObjectContainer) : void
      {
         var dm:DepthManager = null;
         var doc:DisplayObjectContainer = param1;
         dm = null;
         var child:DisplayObject = null;
         var i:int = 0;
         dm = getManager(doc);
         var len:int = doc.numChildren;
         var arr:Array = [];
         i = 0;
         while(i < len)
         {
            child = doc.getChildAt(i);
            arr.push(child);
            i++;
         }
         arr.sortOn("y",Array.NUMERIC);
         arr.forEach(function(param1:DisplayObject, param2:int, param3:Array):void
         {
            doc.setChildIndex(param1,param2);
            dm.setDepth(param1,param1.y);
         });
         arr = null;
      }
      
      public static function clearAll() : void
      {
         managers = null;
      }
      
      public static function getManager(param1:DisplayObjectContainer) : DepthManager
      {
         if(!managers)
         {
            managers = new Dictionary(true);
         }
         var _loc2_:DepthManager = managers[param1];
         if(!_loc2_)
         {
            _loc2_ = new DepthManager();
            managers[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public static function bringToBottom(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1.parent;
         if(_loc2_ == null)
         {
            return;
         }
         if(_loc2_.getChildIndex(param1) != 0)
         {
            _loc2_.setChildIndex(param1,0);
         }
      }
      
      public static function clear(param1:DisplayObjectContainer) : void
      {
         delete managers[param1];
      }
      
      public static function bringToTop(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObjectContainer = param1.parent;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.addChild(param1);
      }
      
      public function setDepth(param1:DisplayObject, param2:Number) : void
      {
         this.depths[param1] = param2;
      }
      
      private function countDepth(param1:DisplayObject, param2:int, param3:Number = 0) : Number
      {
         if(this.depths[param1] == null)
         {
            if(param2 == 0)
            {
               return 0;
            }
            return this.countDepth(param1.parent.getChildAt(param2 - 1),param2 - 1,param3 + 1);
         }
         return this.depths[param1] + param3;
      }
      
      public function swapChildDepth(param1:DisplayObject, param2:Number) : int
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:DisplayObjectContainer = param1.parent;
         if(_loc5_ == null)
         {
            throw new Error("child is not in a container!!");
         }
         var _loc6_:int = _loc5_.getChildIndex(param1);
         var _loc7_:Number = this.getDepth(param1);
         if(param2 == _loc7_)
         {
            this.setDepth(param1,param2);
            return _loc6_;
         }
         var _loc8_:int = _loc5_.numChildren;
         if(_loc8_ < 2)
         {
            this.setDepth(param1,param2);
            return _loc6_;
         }
         if(param2 < this.getDepth(_loc5_.getChildAt(0)))
         {
            _loc5_.setChildIndex(param1,0);
            this.setDepth(param1,param2);
            return 0;
         }
         if(param2 >= this.getDepth(_loc5_.getChildAt(_loc8_ - 1)))
         {
            _loc5_.setChildIndex(param1,_loc8_ - 1);
            this.setDepth(param1,param2);
            return _loc8_ - 1;
         }
         var _loc9_:int = 0;
         var _loc10_:int = _loc8_ - 1;
         if(param2 > _loc7_)
         {
            _loc9_ = _loc6_;
            _loc10_ = _loc8_ - 1;
         }
         else
         {
            _loc9_ = 0;
            _loc10_ = _loc6_;
         }
         while(_loc10_ > _loc9_ + 1)
         {
            _loc3_ = _loc9_ + (_loc10_ - _loc9_) / 2;
            _loc4_ = this.getDepth(_loc5_.getChildAt(_loc3_));
            if(_loc4_ > param2)
            {
               _loc10_ = _loc3_;
            }
            else
            {
               if(_loc4_ >= param2)
               {
                  _loc5_.setChildIndex(param1,_loc3_);
                  this.setDepth(param1,param2);
                  return _loc3_;
               }
               _loc9_ = _loc3_;
            }
         }
         var _loc11_:Number = this.getDepth(_loc5_.getChildAt(_loc9_));
         var _loc12_:Number = this.getDepth(_loc5_.getChildAt(_loc10_));
         var _loc13_:int = 0;
         if(param2 >= _loc12_)
         {
            if(_loc6_ <= _loc10_)
            {
               _loc13_ = Math.min(_loc10_,_loc8_ - 1);
            }
            else
            {
               _loc13_ = Math.min(_loc10_ + 1,_loc8_ - 1);
            }
         }
         else if(param2 < _loc11_)
         {
            if(_loc6_ < _loc9_)
            {
               _loc13_ = Math.max(_loc9_ - 1,0);
            }
            else
            {
               _loc13_ = _loc9_;
            }
         }
         else if(_loc6_ <= _loc9_)
         {
            _loc13_ = _loc9_;
         }
         else
         {
            _loc13_ = Math.min(_loc9_ + 1,_loc8_ - 1);
         }
         _loc5_.setChildIndex(param1,_loc13_);
         this.setDepth(param1,param2);
         return _loc13_;
      }
      
      public function getDepth(param1:DisplayObject) : Number
      {
         if(this.depths[param1] == null)
         {
            return this.countDepth(param1,param1.parent.getChildIndex(param1),0);
         }
         return this.depths[param1];
      }
   }
}

