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
   
   public class Aimat_10046 extends BaseAimat
   {
      
      private var speedPos:Point;
      
      private var ui:MovieClip;
      
      private var _speed:Number = 36;
      
      private var ice_mc:MovieClip;
      
      public function Aimat_10046()
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
         this.ice_mc = this.ui["ice_mc"];
         this.ice_mc.addFrameScript(this.ice_mc.totalFrames - 1,this.onEnter);
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
      }
      
      private function onEnter() : void
      {
         var _loc1_:DisplayObject = null;
         this.ice_mc.addFrameScript(this.ice_mc.totalFrames - 1,null);
         this.ice_mc.gotoAndStop(1);
         AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
         var _loc2_:Array = MapManager.getObjectsPointRect(_info.endPos,30,[IAimatSprite]);
         for each(_loc1_ in _loc2_)
         {
            if(_loc1_ is IAimatSprite)
            {
               IAimatSprite(_loc1_).aimatState(_info);
            }
         }
      }
   }
}

