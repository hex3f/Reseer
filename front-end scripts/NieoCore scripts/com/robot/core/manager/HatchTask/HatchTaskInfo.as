package com.robot.core.manager.HatchTask
{
   public class HatchTaskInfo
   {
      
      public var outType:uint;
      
      public var isComplete:Boolean = false;
      
      public var type:uint;
      
      public var obtainTime:uint;
      
      public var statusList:Array;
      
      public var itemID:uint;
      
      public var callback:Function;
      
      public function HatchTaskInfo(param1:uint, param2:uint, param3:Array, param4:Function = null)
      {
         super();
         this.obtainTime = param1;
         this.itemID = param2;
         this.statusList = param3;
         this.callback = param4;
      }
   }
}

