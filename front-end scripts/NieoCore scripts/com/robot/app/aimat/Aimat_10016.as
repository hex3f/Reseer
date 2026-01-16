package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.GeomUtil;
   
   public class Aimat_10016 extends BaseAimat
   {
      
      private var ui:MovieClip;
      
      public function Aimat_10016()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         this.ui = AimatController.getResEffect(_info.id);
         this.ui.x = _info.startPos.x;
         this.ui.y = _info.startPos.y;
         this.ui.mouseEnabled = false;
         this.ui.mouseChildren = false;
         this.ui.rotation = GeomUtil.pointAngle(_info.endPos,_info.startPos);
         MapManager.currentMap.depthLevel.addChild(this.ui);
         this.ui.addFrameScript(this.ui.totalFrames - 1,this.onEnd);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this.ui))
         {
            this.ui.addFrameScript(this.ui.totalFrames - 1,null);
            DisplayUtil.removeForParent(this.ui);
            this.ui = null;
         }
      }
      
      private function onEnd() : void
      {
         this.ui.addFrameScript(this.ui.totalFrames - 1,null);
         DisplayUtil.removeForParent(this.ui);
         this.ui = null;
         AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
         var _loc1_:IAimatSprite = MapManager.getObjectPoint(_info.endPos,[IAimatSprite]) as IAimatSprite;
         if(Boolean(_loc1_))
         {
            _loc1_.aimatState(_info);
         }
      }
   }
}

