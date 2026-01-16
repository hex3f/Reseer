package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class SuperNonoShieldInfo
   {
      
      private var _uid:uint;
      
      private var _leftTime:uint;
      
      public function SuperNonoShieldInfo(param1:IDataInput)
      {
         super();
         this._uid = param1.readUnsignedInt();
         this._leftTime = param1.readUnsignedInt();
      }
      
      public function get uid() : uint
      {
         return this._uid;
      }
      
      public function get leftTime() : uint
      {
         return this._leftTime;
      }
   }
}

