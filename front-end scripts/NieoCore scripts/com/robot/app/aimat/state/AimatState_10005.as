package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import org.taomee.utils.DisplayUtil;
   
   public class AimatState_10005 implements IAimatState
   {
      
      private var _mc:MovieClip;
      
      private var _obj:DisplayObject;
      
      private var _count:int = 0;
      
      public function AimatState_10005()
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
         this._obj = BasePeoleModel(param1).skeleton.getSkeletonMC();
         var _loc3_:Rectangle = param1.hitRect;
         this._mc = AimatController.getResState(param2.id);
         this._mc.mouseEnabled = false;
         this._mc.mouseChildren = false;
         this._mc.x = param1.centerPoint.x - param1.sprite.x;
         this._mc.y = param1.centerPoint.y - param1.sprite.y;
         param1.sprite.addChild(this._mc);
         var _loc4_:ColorTransform = new ColorTransform();
         _loc4_.color = 16777215;
         if(param1 is BasePeoleModel)
         {
            this._obj.transform.colorTransform = _loc4_;
         }
      }
      
      public function destroy() : void
      {
         this._obj.transform.colorTransform = new ColorTransform();
         DisplayUtil.removeForParent(this._mc);
         this._mc = null;
         this._obj = null;
      }
   }
}

