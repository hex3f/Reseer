package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_10006 implements IAimatState
   {
      
      private var _tid:uint;
      
      private var _mc:MovieClip;
      
      private var _count:int = 0;
      
      public function AimatState_10006()
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
         this._mc = AimatController.getResState(param2.id);
         this._mc.mouseEnabled = false;
         this._mc.y = -param1.hitRect.height / 2;
         param1.sprite.addChild(this._mc);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this._mc);
         this._mc = null;
      }
   }
}

