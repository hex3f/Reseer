package com.robot.app.experienceShared
{
   import flash.utils.IDataInput;
   
   public class ExperienceSharedInfo
   {
      
      private var fraction:uint = 0;
      
      public function ExperienceSharedInfo(param1:IDataInput)
      {
         super();
         this.fraction = param1.readUnsignedInt();
      }
      
      public function get getFraction() : uint
      {
         return this.fraction;
      }
   }
}

