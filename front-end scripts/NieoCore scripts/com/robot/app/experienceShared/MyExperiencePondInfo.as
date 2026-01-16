package com.robot.app.experienceShared
{
   import flash.utils.IDataInput;
   
   public class MyExperiencePondInfo
   {
      
      private var myExp:uint = 0;
      
      public function MyExperiencePondInfo(param1:IDataInput)
      {
         super();
         this.myExp = param1.readUnsignedInt();
      }
      
      public function get getMyExp() : uint
      {
         return this.myExp;
      }
   }
}

