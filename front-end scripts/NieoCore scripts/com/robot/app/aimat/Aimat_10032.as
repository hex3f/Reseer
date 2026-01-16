package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10032 extends BaseAimat
   {
      
      private var speedPos:Point;
      
      private var ui:MovieClip;
      
      private var ui2:MovieClip;
      
      private var _speed:Number = 36;
      
      public function Aimat_10032()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         if(Math.abs(Point.distance(_info.startPos,_info.endPos)) < this._speed / 2)
         {
            return;
         }
         this.speedPos = GeomUtil.angleSpeed(_info.endPos,_info.startPos);
         _info.startPos.x += this.speedPos.x * 40;
         _info.startPos.y += this.speedPos.y * 40;
         this.ui = AimatController.getResEffect(_info.id);
         this.ui.x = _info.startPos.x;
         this.ui.y = _info.startPos.y;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         this.ui.rotation = GeomUtil.pointAngle(_info.endPos,_info.startPos);
         MapManager.currentMap.depthLevel.addChild(this.ui);
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
         this.speedPos = null;
         if(Boolean(this.ui2))
         {
            this.onEnd();
         }
      }
      
      private function onEnter(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:DisplayObject = null;
         if(Math.abs(this.ui.x - _info.endPos.x) < this._speed / 2 && Math.abs(this.ui.y - _info.endPos.y) < this._speed / 2)
         {
            this.ui.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
            DisplayUtil.removeForParent(this.ui);
            this.ui = null;
            this.ui2 = AimatController.getResState(_info.id);
            this.ui2.x = _info.endPos.x;
            this.ui2.y = _info.endPos.y;
            this.ui2.mouseEnabled = false;
            this.ui2.mouseChildren = false;
            if(_info.endPos.x > _info.startPos.x)
            {
               this.ui2.scaleX = 1;
            }
            else
            {
               this.ui2.scaleX = -1;
            }
            this.ui2.addFrameScript(this.ui2.totalFrames - 1,this.onEnd);
            MapManager.currentMap.depthLevel.addChild(this.ui2);
            _loc2_ = MapManager.getObjectsPointRect(_info.endPos,30,[IAimatSprite]);
            for each(_loc3_ in _loc2_)
            {
               if(_loc3_ is IAimatSprite)
               {
                  IAimatSprite(_loc3_).aimatState(_info);
               }
            }
            return;
         }
         this.ui.x += this.speedPos.x;
         this.ui.y += this.speedPos.y;
      }
      
      private function onEnd() : void
      {
         this.ui2.addFrameScript(this.ui2.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui2);
         this.ui2 = null;
      }
   }
}

