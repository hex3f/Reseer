package com.robot.core.ui.alert
{
   import com.robot.core.manager.alert.AlertInfo;
   import flash.display.Sprite;
   import flash.events.IEventDispatcher;
   
   public interface IAlert extends IEventDispatcher
   {
      
      function get info() : AlertInfo;
      
      function get content() : Sprite;
      
      function show() : void;
      
      function hide() : void;
      
      function destroy() : void;
   }
}

