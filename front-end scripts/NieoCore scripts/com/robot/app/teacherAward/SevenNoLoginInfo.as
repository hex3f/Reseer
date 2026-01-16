package com.robot.app.teacherAward
{
   import flash.utils.IDataInput;
   
   public class SevenNoLoginInfo
   {
      
      private var isLogin:uint;
      
      public function SevenNoLoginInfo(param1:IDataInput)
      {
         super();
         this.isLogin = param1.readUnsignedInt();
      }
      
      public function get getStatus() : uint
      {
         return this.isLogin;
      }
   }
}

