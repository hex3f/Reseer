package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_10004 implements IAimatState
   {
      
      private var _mc:MovieClip;
      
      private var _count:int = 0;
      
      public function AimatState_10004()
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
         var _loc3_:Rectangle = param1.hitRect;
         this._mc = AimatController.getResState(param2.id);
         this._mc.mouseEnabled = false;
         this._mc.mouseChildren = false;
         this._mc.x = param1.centerPoint.x - param1.sprite.x;
         this._mc.y = param1.centerPoint.y - param1.sprite.y;
         param1.sprite.addChild(this._mc);
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this._mc);
         this._mc = null;
      }
   }
}

