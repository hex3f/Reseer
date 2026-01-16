package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10015 extends BaseAimat
   {
      
      private var speedPos:Point;
      
      private var ui:MovieClip;
      
      private var _speed:Number = 36;
      
      public function Aimat_10015()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         if(param1.speed > 0)
         {
            this._speed = param1.speed;
         }
         this.ui = AimatController.getResEffect(_info.id);
         this.ui.x = _info.startPos.x;
         this.ui.y = _info.startPos.y;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         this.ui.rotation = GeomUtil.pointAngle(_info.endPos,_info.startPos);
         MapManager.currentMap.depthLevel.addChild(this.ui);
         this.speedPos = GeomUtil.angleSpeed(_info.endPos,_info.startPos);
         this.speedPos.x *= this._speed;
         this.speedPos.y *= this._speed;
         this.ui.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.ui))
         {
            this.ui.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            DisplayUtil.removeForParent(this.ui);
            this.ui = null;
         }
      }
      
      private function onEnter(param1:Event) : void
      {
         var _loc2_:IAimatSprite = null;
         if(Math.abs(this.ui.x - _info.endPos.x) < this._speed / 2 && Math.abs(this.ui.y - _info.endPos.y) < this._speed / 2)
         {
            this.ui.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
            DisplayUtil.removeForParent(this.ui);
            this.ui = null;
            _loc2_ = MapManager.getObjectPoint(_info.endPos,[IAimatSprite]) as IAimatSprite;
            if(Boolean(_loc2_))
            {
               _loc2_.aimatState(_info);
            }
            return;
         }
         this.ui.x += this.speedPos.x;
         this.ui.y += this.speedPos.y;
      }
   }
}

