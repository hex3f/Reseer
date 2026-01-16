package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_10015 implements IAimatState
   {
      
      private var _mc:MovieClip;
      
      private var _isFinish:Boolean;
      
      public function AimatState_10015()
      {
         super();
      }
      
      public function get isFinish() : Boolean
      {
         if(this._isFinish)
         {
            return true;
         }
         return false;
      }
      
      public function execute(param1:IAimatSprite, param2:AimatInfo) : void
      {
         var obj:IAimatSprite = param1;
         var info:AimatInfo = param2;
         this._mc = AimatController.getResState(info.id);
         this._mc.mouseEnabled = false;
         this._mc.mouseChildren = false;
         obj.sprite.addChild(this._mc);
         this._mc.addFrameScript(this._mc.totalFrames - 1,function():void
         {
            _mc.addFrameScript(_mc.totalFrames - 1,null);
            _isFinish = true;
         });
      }
      
      public function destroy() : void
      {
         this._mc.addFrameScript(this._mc.totalFrames - 1,null);
         DisplayUtil.removeForParent(this._mc);
         this._mc = null;
      }
   }
}

