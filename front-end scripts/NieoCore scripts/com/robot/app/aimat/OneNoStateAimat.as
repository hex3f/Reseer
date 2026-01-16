package com.robot.app.aimat
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.event.AimatEvent;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import flash.display.MovieClip;
   import org.taomee.utils.DisplayUtil;
   
   public class OneNoStateAimat extends BaseAimat
   {
      
      private var _ui:MovieClip;
      
      public function OneNoStateAimat()
      {
         super();
      }
      
      override public function execute(param1:AimatInfo) : void
      {
         super.execute(param1);
         this._ui = AimatController.getResEffect(_info.id);
         this._ui.x = _info.startPos.x;
         this._ui.y = _info.startPos.y;
         this._ui.mouseEnabled = false;
         this._ui.mouseChildren = false;
         MapManager.currentMap.depthLevel.addChild(this._ui);
         this._ui.addFrameScript(this._ui.totalFrames - 1,this.onEnd);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(Boolean(this._ui))
         {
            this._ui.addFrameScript(this._ui.totalFrames - 1,null);
            DisplayUtil.removeForParent(this._ui);
            this._ui = null;
         }
      }
      
      private function onEnd() : void
      {
         this._ui.addFrameScript(this._ui.totalFrames - 1,null);
         AimatController.dispatchEvent(AimatEvent.PLAY_END,_info);
         DisplayUtil.removeForParent(this._ui);
         this._ui = null;
      }
   }
}

