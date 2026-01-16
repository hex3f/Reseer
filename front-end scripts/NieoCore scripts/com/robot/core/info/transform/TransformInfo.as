package com.robot.core.info.transform
{
   import flash.utils.IDataInput;
   
   public class TransformInfo
   {
      
      private var _userID:uint;
      
      private var _changeShape:uint;
      
      public function TransformInfo(param1:IDataInput)
      {
         super();
         this._userID = param1.readUnsignedInt();
         this._changeShape = param1.readUnsignedInt();
      }
      
      public function get isTransform() : Boolean
      {
         return this._changeShape != 0;
      }
      
      public function get suitID() : uint
      {
         return this._changeShape;
      }
      
      public function get userID() : uint
      {
         return this._userID;
      }
   }
}

