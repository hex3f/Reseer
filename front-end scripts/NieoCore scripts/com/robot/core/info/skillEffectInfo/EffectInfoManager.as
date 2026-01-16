package com.robot.core.info.skillEffectInfo
{
   import flash.utils.getDefinitionByName;
   import org.taomee.ds.HashMap;
   
   public class EffectInfoManager
   {
      
      private static var hashMap:HashMap = new HashMap();
      
      public function EffectInfoManager()
      {
         super();
      }
      
      public static function getArgsNum(param1:uint) : uint
      {
         return getEffect(param1).argsNum;
      }
      
      public static function getInfo(param1:uint, param2:Array) : String
      {
         return getEffect(param1).getInfo(param2);
      }
      
      private static function getEffect(param1:uint) : AbstractEffectInfo
      {
         var _loc2_:AbstractEffectInfo = null;
         var _loc3_:* = undefined;
         if(hashMap.getValue(param1))
         {
            _loc2_ = hashMap.getValue(param1);
         }
         else
         {
            _loc3_ = getDefinitionByName("com.robot.core.info.skillEffectInfo.Effect_" + param1);
            _loc2_ = new _loc3_() as AbstractEffectInfo;
            hashMap.add(param1,_loc2_);
         }
         return _loc2_;
      }
   }
}

