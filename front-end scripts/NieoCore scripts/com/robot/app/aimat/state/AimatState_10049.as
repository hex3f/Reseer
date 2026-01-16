package com.robot.app.aimat.state
{
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.DisplayObject;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.taomee.effect.ColorFilter;
   
   public class AimatState_10049 implements IAimatState
   {
      
      private var _time:Timer;
      
      private var _obj:DisplayObject;
      
      private var _count:int = 0;
      
      public function AimatState_10049()
      {
         super();
      }
      
      public function get isFinish() : Boolean
      {
         ++this._count;
         if(this._count >= 50)
         {
            return true;
         }
         return false;
      }
      
      public function execute(param1:IAimatSprite, param2:AimatInfo) : void
      {
         if(param1 is BasePeoleModel)
         {
            this._obj = BasePeoleModel(param1).skeleton.getBodyMC();
         }
         else
         {
            this._obj = param1.sprite;
         }
         this._time = new Timer(100);
         this._time.addEventListener(TimerEvent.TIMER,this.onTimer);
         this._time.start();
      }
      
      public function destroy() : void
      {
         if(this._time.running)
         {
            this._time.stop();
         }
         this._time.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this._time = null;
         this._obj.filters = [];
         this._obj = null;
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         if(this._time.currentCount % 2 == 0)
         {
            this._obj.filters = [ColorFilter.setBrightness(30)];
         }
         else
         {
            this._obj.filters = [ColorFilter.setInvert(),ColorFilter.setBrightness(30)];
         }
      }
   }
}

