package org.taomee.data
{
   import flash.events.Event;
   
   public class DataChangeEvent extends Event
   {
      
      public static const DATA_CHANGE:String = "dataChange";
      
      public static const PRE_DATA_CHANGE:String = "preDataChange";
      
      protected var _items:Array;
      
      protected var _changeType:String;
      
      protected var _startIndex:uint;
      
      protected var _endIndex:uint;
      
      public function DataChangeEvent(param1:String, param2:String, param3:Array, param4:int = -1, param5:int = -1)
      {
         super(param1);
         this._changeType = param2;
         this._startIndex = param4;
         this._items = param3;
         this._endIndex = param5 == -1 ? this._startIndex : uint(param5);
      }
      
      public function get items() : Array
      {
         return this._items;
      }
      
      public function get changeType() : String
      {
         return this._changeType;
      }
      
      public function get startIndex() : uint
      {
         return this._startIndex;
      }
      
      public function get endIndex() : uint
      {
         return this._endIndex;
      }
      
      override public function toString() : String
      {
         return formatToString("DataChangeEvent","type","changeType","startIndex","endIndex","bubbles","cancelable");
      }
      
      override public function clone() : Event
      {
         return new DataChangeEvent(type,this._changeType,this._items,this._startIndex,this._endIndex);
      }
   }
}

