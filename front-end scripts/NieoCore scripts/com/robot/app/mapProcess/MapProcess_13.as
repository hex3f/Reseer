package com.robot.app.mapProcess
{
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.MovieClip;
   
   public class MapProcess_13 extends BaseMapProcess
   {
      
      private var _plMc:MovieClip;
      
      public function MapProcess_13()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._plMc = conLevel["plMc"];
         this._plMc.mouseChildren = false;
         this._plMc.mouseEnabled = false;
         var _loc1_:int = 1;
         while(_loc1_ < 7)
         {
            this.conLevel["g" + _loc1_ + "Mc"].gotoAndStop(1);
            _loc1_++;
         }
      }
      
      override public function destroy() : void
      {
         this._plMc = null;
      }
   }
}

