package com.robot.core.info.pet
{
   import flash.utils.IDataInput;
   
   public class ExeingPetInfo
   {
      
      public var _flag:uint;
      
      public var _remainDay:uint;
      
      public var _course:uint;
      
      public var _capTm:Number;
      
      public var _petId:uint;
      
      public function ExeingPetInfo(param1:IDataInput = null)
      {
         super();
         if(Boolean(param1))
         {
            this._flag = param1.readUnsignedInt();
            this._capTm = param1.readUnsignedInt();
            this._petId = param1.readUnsignedInt();
            this._remainDay = param1.readUnsignedInt() / 3600;
            this._course = param1.readUnsignedInt();
         }
      }
   }
}

