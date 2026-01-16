package com.robot.petFightModule.ui.controlPanel
{
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   
   public class BaseControlPanel extends EventDispatcher implements IControlPanel
   {
      
      public static const PANEL_HEIGHT:uint = 155;
      
      protected var _panel:Sprite;
      
      public function BaseControlPanel()
      {
         super();
      }
      
      public function get panel() : Sprite
      {
         return this._panel;
      }
      
      public function destroy() : void
      {
         this._panel = null;
      }
   }
}

