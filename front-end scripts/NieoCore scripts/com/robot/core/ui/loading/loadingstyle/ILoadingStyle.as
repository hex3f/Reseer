package com.robot.core.ui.loading.loadingstyle
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.IEventDispatcher;
   
   public interface ILoadingStyle extends IEventDispatcher
   {
      
      function changePercent(param1:Number, param2:Number) : void;
      
      function destroy() : void;
      
      function show() : void;
      
      function close() : void;
      
      function setTitle(param1:String) : void;
      
      function setIsShowCloseBtn(param1:Boolean) : void;
      
      function getParentMC() : DisplayObjectContainer;
      
      function getLoadingMC() : DisplayObject;
   }
}

