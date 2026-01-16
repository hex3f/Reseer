package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10005 extends BaseAimat
   {
      
      private var ui:MovieClip;
      
      private var ui2:MovieClip;
      
      public function Aimat_10005()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         this.ui = AimatController.getResEffect(_info.id);
         var _loc2_:Number = _info.endPos.x > _info.startPos.x ? 10 : -10;
         this.ui.x = _info.startPos.x + _loc2_;
         this.ui.y = _info.startPos.y - 8;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         MapManager.currentMap.depthLevel.addChild(this.ui);
         this.ui.addFrameScript(this.ui.totalFrames - 1,this.onEnd);
         this.ui.addFrameScript(this.ui.totalFrames / 2,this.onEnd2);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.ui))
         {
            this.ui.addFrameScript(this.ui.totalFrames / 2,null);
            this.onEnd();
         }
         if(Boolean(this.ui2))
         {
            this.ui2.addFrameScript(this.ui2.totalFrames - 1,null);
            DisplayUtil.removeForParent(this.ui2);
            this.ui2 = null;
         }
      }
      
      private function onEnd() : void
      {
         this.ui.addFrameScript(this.ui.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
      }
      
      private function onEnd2() : void
      {
         var _loc1_:Point = null;
         this.ui.addFrameScript(this.ui.totalFrames / 2,null);
         _loc1_ = Point.interpolate(_info.startPos,_info.endPos,0.4);
         this.ui2 = AimatController.getResEffect(_info.id,"02");
         this.ui2.x = _loc1_.x;
         this.ui2.y = _loc1_.y;
         this.ui2.mouseEnabled = false;
         this.ui2.mouseChildren = false;
         this.ui2.rotation = GeomUtil.pointAngle(_info.endPos,_info.startPos);
         MapManager.currentMap.depthLevel.addChild(this.ui2);
         this.ui2.addFrameScript(this.ui2.totalFrames - 1,this.onEnd3);
      }
      
      private function onEnd3() : void
      {
         this.ui2.addFrameScript(this.ui2.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui2);
         this.ui2 = null;
         AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
         var _loc1_:IAimatSprite = MapManager.getObjectPoint(_info.endPos,[IAimatSprite]) as IAimatSprite;
         if(Boolean(_loc1_))
         {
            _loc1_.aimatState(_info);
         }
      }
   }
}

