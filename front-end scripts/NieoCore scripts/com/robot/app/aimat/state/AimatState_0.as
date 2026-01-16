package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_0 implements IAimatState
   {
      
      private var _ui:MovieClip;
      
      private var _count:int = 0;
      
      public function AimatState_0()
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
         var _loc3_:Rectangle = null;
         _loc3_ = param1.hitRect;
         this._ui = AimatController.getResState(param2.id);
         this._ui.mouseEnabled = false;
         this._ui.mouseChildren = false;
         this._ui.x = _loc3_.width / 2 - Math.random() * _loc3_.width + param1.centerPoint.x - param1.sprite.x;
         this._ui.y = -Math.random() * _loc3_.height + param1.centerPoint.y - param1.sprite.y;
         param1.sprite.addChild(this._ui);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this._ui);
         this._ui = null;
      }
   }
}

