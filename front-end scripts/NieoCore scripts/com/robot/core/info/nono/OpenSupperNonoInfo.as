package com.robot.core.info.nono
{
   import flash.utils.IDataInput;
   
   public class OpenSupperNonoInfo
   {
      
      private var _success:Number;
      
      public function OpenSupperNonoInfo(param1:IDataInput)
      {
         super();
         this._success = param1.readUnsignedInt();
      }
      
      public function get success() : Number
      {
         return this._success;
      }
   }
}

