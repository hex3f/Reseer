package gs
{
   import flash.errors.*;
   import flash.utils.*;
   import gs.utils.tween.*;
   
   public class OverwriteManager
   {
      
      public static var mode:int;
      
      public static var enabled:Boolean;
      
      public static const version:Number = 3.12;
      
      public static const NONE:int = 0;
      
      public static const ALL:int = 1;
      
      public static const AUTO:int = 2;
      
      public static const CONCURRENT:int = 3;
      
      public function OverwriteManager()
      {
         super();
      }
      
      public static function killVars(param1:Object, param2:Object, param3:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc6_:TweenInfo = null;
         _loc4_ = param3.length - 1;
         while(_loc4_ > -1)
         {
            _loc6_ = param3[_loc4_];
            if(_loc6_.name in param1)
            {
               param3.splice(_loc4_,1);
            }
            else if(_loc6_.isPlugin && _loc6_.name == "_MULTIPLE_")
            {
               _loc6_.target.killProps(param1);
               if(_loc6_.target.overwriteProps.length == 0)
               {
                  param3.splice(_loc4_,1);
               }
            }
            _loc4_--;
         }
         for(_loc5_ in param1)
         {
            delete param2[_loc5_];
         }
      }
      
      public static function manageOverwrites(param1:TweenLite, param2:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:TweenLite = null;
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:TweenInfo = null;
         var _loc9_:Array = null;
         var _loc10_:Object = param1.vars;
         var _loc11_:int = _loc10_.overwrite == undefined ? mode : int(_loc10_.overwrite);
         if(_loc11_ < 2 || param2 == null)
         {
            return;
         }
         var _loc12_:Number = param1.startTime;
         var _loc13_:Array = [];
         var _loc14_:int = -1;
         _loc3_ = param2.length - 1;
         while(_loc3_ > -1)
         {
            _loc4_ = param2[_loc3_];
            if(_loc4_ == param1)
            {
               _loc14_ = _loc3_;
            }
            else if(_loc3_ < _loc14_ && _loc4_.startTime <= _loc12_ && _loc4_.startTime + _loc4_.duration * 1000 / _loc4_.combinedTimeScale > _loc12_)
            {
               _loc13_[_loc13_.length] = _loc4_;
            }
            _loc3_--;
         }
         if(_loc13_.length == 0 || param1.tweens.length == 0)
         {
            return;
         }
         if(_loc11_ == AUTO)
         {
            _loc5_ = param1.tweens;
            _loc6_ = {};
            _loc3_ = _loc5_.length - 1;
            while(_loc3_ > -1)
            {
               _loc8_ = _loc5_[_loc3_];
               if(_loc8_.isPlugin)
               {
                  if(_loc8_.name == "_MULTIPLE_")
                  {
                     _loc9_ = _loc8_.target.overwriteProps;
                     _loc7_ = _loc9_.length - 1;
                     while(_loc7_ > -1)
                     {
                        _loc6_[_loc9_[_loc7_]] = true;
                        _loc7_--;
                     }
                  }
                  else
                  {
                     _loc6_[_loc8_.name] = true;
                  }
                  _loc6_[_loc8_.target.propName] = true;
               }
               else
               {
                  _loc6_[_loc8_.name] = true;
               }
               _loc3_--;
            }
            _loc3_ = _loc13_.length - 1;
            while(_loc3_ > -1)
            {
               killVars(_loc6_,_loc13_[_loc3_].exposedVars,_loc13_[_loc3_].tweens);
               _loc3_--;
            }
         }
         else
         {
            _loc3_ = _loc13_.length - 1;
            while(_loc3_ > -1)
            {
               _loc13_[_loc3_].enabled = false;
               _loc3_--;
            }
         }
      }
      
      public static function init(param1:int = 2) : int
      {
         if(TweenLite.version < 10.09)
         {
         }
         TweenLite.overwriteManager = OverwriteManager;
         mode = param1;
         enabled = true;
         return mode;
      }
   }
}

