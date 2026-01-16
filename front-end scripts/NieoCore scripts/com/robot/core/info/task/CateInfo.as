package com.robot.core.info.task
{
   import flash.utils.IDataInput;
   
   public class CateInfo
   {
      
      private var _id:uint;
      
      private var _count:uint;
      
      public function CateInfo(param1:IDataInput)
      {
         super();
         this._id = param1.readUnsignedInt();
         this._count = param1.readUnsignedInt();
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      public function get count() : uint
      {
         return this._count;
      }
   }
}

