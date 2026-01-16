package com.robot.core.info
{
   import flash.utils.IDataInput;
   
   public class NonoImplementsToolResquestInfo
   {
      
      private var _id:uint;
      
      private var _itemId:uint;
      
      private var _power:uint;
      
      private var _ai:uint;
      
      private var _mate:uint;
      
      private var _iq:uint;
      
      public function NonoImplementsToolResquestInfo(param1:IDataInput)
      {
         super();
         this._id = param1.readUnsignedInt();
         this._itemId = param1.readUnsignedInt();
         this._power = param1.readUnsignedInt() / 1000;
         this._ai = param1.readUnsignedShort();
         this._mate = param1.readUnsignedInt() / 1000;
         this._iq = param1.readUnsignedInt();
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get itemId() : uint
      {
         return this._itemId;
      }
      
      public function get power() : uint
      {
         return this._power;
      }
      
      public function get ai() : uint
      {
         return this._ai;
      }
      
      public function get mate() : uint
      {
         return this._mate;
      }
      
      public function get iq() : uint
      {
         return this._iq;
      }
   }
}

