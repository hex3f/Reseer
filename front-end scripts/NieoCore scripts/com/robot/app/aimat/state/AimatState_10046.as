package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_10046 implements IAimatState
   {
      
      private var _ui:MovieClip;
      
      public function AimatState_10046()
      {
         super();
      }
      
      public function get isFinish() : Boolean
      {
         if(this._ui.currentFrame == this._ui.totalFrames - 1)
         {
            return true;
         }
         return false;
      }
      
      public function execute(param1:IAimatSprite, param2:AimatInfo) : void
      {
         var _loc3_:Rectangle = param1.hitRect;
         this._ui = AimatController.getResState(param2.id);
         this._ui.mouseEnabled = false;
         this._ui.mouseChildren = false;
         param1.sprite.addChild(this._ui);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this._ui);
         this._ui = null;
      }
   }
}

