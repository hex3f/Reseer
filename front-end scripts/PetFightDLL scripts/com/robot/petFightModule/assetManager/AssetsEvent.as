package com.robot.petFightModule.assetManager
{
   import flash.events.Event;
   
   public class AssetsEvent extends Event
   {
      
      public static const PROGRESS:String = "progress";
      
      public static const LOAD_ALL_ASSETS:String = "loadAllAssets";
      
      private var _percent:Number;
      
      public function AssetsEvent(param1:String, param2:Number = 100, param3:Boolean = false, param4:Boolean = false)
      {
         this._percent = param2;
         super(param1,param3,param4);
      }
      
      public function get percent() : Number
      {
         return this._percent;
      }
   }
}

