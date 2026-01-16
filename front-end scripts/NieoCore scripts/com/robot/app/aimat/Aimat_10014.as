package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10014 extends BaseAimat
   {
      
      private var amc:Shape = new Shape();
      
      private var isP:Boolean = false;
      
      private var movPos:Point;
      
      private var speedPos:Point;
      
      private var color:uint = 16444291;
      
      private var ui:MovieClip;
      
      private var _speed:Number = 50;
      
      public function Aimat_10014()
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
         this.ui.addFrameScript(this.ui.totalFrames - 1,this.onEnd);
         if(Point.distance(_info.startPos,_info.endPos) < this._speed / 2)
         {
            return;
         }
         this.speedPos = GeomUtil.angleSpeed(_info.startPos,_info.endPos);
         this.speedPos.x *= this._speed;
         this.speedPos.y *= this._speed;
         this.amc = new Shape();
         this.amc.filters = [new GlowFilter(this.color)];
         MapManager.currentMap.depthLevel.addChild(this.amc);
         this.movPos = _info.startPos.clone();
         this.amc.addEventListener(Event.ENTER_FRAME,this.onEnter);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.ui))
         {
            this.onEnd();
         }
         if(Boolean(this.amc))
         {
            this.amc.removeEventListener(Event.ENTER_FRAME,this.onEnter);
            DisplayUtil.removeForParent(this.amc);
            this.amc = null;
         }
         this.movPos = null;
         this.speedPos = null;
      }
      
      private function onEnter(param1:Event) : void
      {
         var _loc3_:IAimatSprite = null;
         this.amc.graphics.clear();
         if(Point.distance(this.movPos,_info.endPos) < this._speed / 2)
         {
            if(this.isP)
            {
               this.amc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(this.amc);
               this.amc = null;
               return;
            }
            this.isP = true;
            this.movPos = _info.startPos.clone();
            AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
            _loc3_ = MapManager.getObjectPoint(_info.endPos,[IAimatSprite]) as IAimatSprite;
            if(Boolean(_loc3_))
            {
               _loc3_.aimatState(_info);
            }
         }
         this.amc.graphics.lineStyle(3,this.color);
         if(this.isP)
         {
            this.amc.graphics.moveTo(_info.endPos.x,_info.endPos.y);
            this.amc.graphics.lineTo(this.movPos.x,this.movPos.y);
         }
         else
         {
            this.amc.graphics.moveTo(_info.startPos.x,_info.startPos.y);
            this.amc.graphics.lineTo(this.movPos.x,this.movPos.y);
         }
         this.movPos = this.movPos.subtract(this.speedPos);
      }
      
      private function onEnd() : void
      {
         this.ui.addFrameScript(this.ui.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
      }
   }
}

