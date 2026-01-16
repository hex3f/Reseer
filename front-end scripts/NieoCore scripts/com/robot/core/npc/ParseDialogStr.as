package com.robot.core.npc
{
   import org.taomee.ds.HashMap;
   
   public class ParseDialogStr
   {
      
      public static const SPLIT:String = "$$";
      
      private var array:Array = [];
      
      public var emotionMap:HashMap = new HashMap();
      
      private var tempStr:String;
      
      private var colorMap:HashMap = new HashMap();
      
      public function ParseDialogStr(param1:String)
      {
         super();
         this.spliceStr(param1);
      }
      
      private function spliceStr(param1:String) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:Number = 0;
         var _loc7_:String = null;
         var _loc8_:RegExp = null;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         while(_loc10_ < param1.length)
         {
            _loc2_ = param1.charAt(_loc10_);
            if(_loc2_ == "#")
            {
               _loc4_ = param1.charAt(_loc10_ - 1);
               _loc5_ = param1.charAt(_loc10_ + 1);
               _loc6_ = 0;
               if(_loc4_ != "$" && uint(_loc5_).toString() == _loc5_)
               {
                  this.array.push(param1.slice(0,_loc10_));
                  _loc7_ = param1.substr(_loc10_ + 1,1 + _loc6_);
                  while(uint(_loc7_) < 100 && uint(_loc7_).toString() == _loc7_ && _loc6_ < param1.length)
                  {
                     _loc6_++;
                     _loc7_ = param1.substr(_loc10_ + 1,1 + _loc6_);
                  }
                  this.tempStr = param1.substring(_loc10_ + 1 + _loc6_,param1.length);
                  this.emotionMap.add(this.array.length,uint(param1.slice(_loc10_ + 1,_loc10_ + 1 + _loc6_)));
                  this.spliceStr(this.tempStr);
                  return;
               }
            }
            _loc3_ = param1.substr(_loc10_,2);
            if(_loc3_ == "0x")
            {
               this.array.push(param1.slice(0,_loc10_));
               _loc8_ = /[a-z0-9A-Z]/;
               _loc9_ = 0;
               while(Boolean(_loc8_.test(param1.substr(_loc10_ + 2 + _loc9_,1))) && _loc9_ < 6)
               {
                  _loc9_++;
               }
               if(_loc9_ > 0)
               {
                  this.colorMap.add(this.array.length,param1.substr(_loc10_ + 2,_loc9_));
                  this.tempStr = param1.substring(_loc10_ + 2 + _loc9_,param1.length);
                  this.spliceStr(this.tempStr);
               }
               else
               {
                  this.array.push(_loc3_);
                  this.tempStr = param1.substring(_loc10_ + 2,param1.length);
                  this.spliceStr(this.tempStr);
               }
               return;
            }
            if(_loc10_ == param1.length - 1)
            {
               this.array.push(param1.slice());
               return;
            }
            _loc10_++;
         }
      }
      
      public function getColor(param1:uint) : String
      {
         if(!this.colorMap.containsKey(param1))
         {
            return "ffffff";
         }
         return this.colorMap.getValue(param1);
      }
      
      public function get strArray() : Array
      {
         return this.array;
      }
      
      public function get str() : String
      {
         return this.array.join(SPLIT);
      }
      
      public function getEmotionNum(param1:uint) : int
      {
         if(!this.emotionMap.containsKey(param1))
         {
            return -1;
         }
         return this.emotionMap.getValue(param1);
      }
   }
}

