package com.robot.core.manager.alert
{
   import flash.display.DisplayObjectContainer;
   
   public class AlertInfo
   {
      
      public var type:String = "";
      
      public var str:String = "";
      
      public var iconURL:String = "";
      
      public var parant:DisplayObjectContainer = null;
      
      public var applyFun:Function = null;
      
      public var cancelFun:Function = null;
      
      public var linkFun:Function = null;
      
      public var disMouse:Boolean = true;
      
      public var isGC:Boolean = true;
      
      public var isBreak:Boolean = false;
      
      public function AlertInfo()
      {
         super();
      }
   }
}

