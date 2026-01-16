package com.robot.app.bag
{
   import flash.events.Event;
   
   public class BagTypeEvent extends Event
   {
      
      public static const SELECT:String = "bagSelect";
      
      private var _showType:int;
      
      private var _suitID:uint;
      
      public function BagTypeEvent(param1:String, param2:int, param3:uint = 0)
      {
         super(param1);
         this._showType = param2;
         this._suitID = param3;
      }
      
      public function get showType() : int
      {
         return this._showType;
      }
      
      public function get suitID() : int
      {
         return this._suitID;
      }
   }
}

