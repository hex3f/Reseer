package com.robot.core.event
{
   import flash.events.Event;
   
   public class CutBmpEvent extends Event
   {
      
      public static const CUT_BMP_COMPLETE:String = "cutBmpComplete";
      
      private var _imgUrl:String;
      
      private var _toID:uint;
      
      public function CutBmpEvent(param1:String, param2:String, param3:uint = 0, param4:Boolean = false, param5:Boolean = false)
      {
         super(param1,param4,param5);
         this._imgUrl = param2;
         this._toID = param3;
      }
      
      public function get imgURL() : String
      {
         return this._imgUrl;
      }
      
      public function get toID() : uint
      {
         return this._toID;
      }
   }
}

