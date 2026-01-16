package com.robot.core.info.fightInfo
{
   import flash.utils.IDataInput;
   
   public class FighetUserInfo
   {
      
      private var _id:uint;
      
      private var _nickName:String;
      
      public function FighetUserInfo(param1:IDataInput)
      {
         super();
         this._id = param1.readUnsignedInt();
         this._nickName = param1.readUTFBytes(16);
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get nickName() : String
      {
         return this._nickName;
      }
   }
}

