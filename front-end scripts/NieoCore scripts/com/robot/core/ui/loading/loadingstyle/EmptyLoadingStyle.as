package com.robot.core.ui.loading.loadingstyle
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.EventDispatcher;
   
   public class EmptyLoadingStyle extends EventDispatcher implements ILoadingStyle
   {
      
      public function EmptyLoadingStyle()
      {
         super();
      }
      
      public function changePercent(param1:Number, param2:Number) : void
      {
      }
      
      public function close() : void
      {
      }
      
      public function show() : void
      {
      }
      
      public function destroy() : void
      {
      }
      
      public function setTitle(param1:String) : void
      {
      }
      
      public function setIsShowCloseBtn(param1:Boolean) : void
      {
      }
      
      public function getParentMC() : DisplayObjectContainer
      {
         return null;
      }
      
      public function getLoadingMC() : DisplayObject
      {
         return null;
      }
   }
}

