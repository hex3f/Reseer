package com.robot.app.aimat.state
{
   import com.robot.core.aimat.AimatController;
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.manager.MapManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.IAimatSprite;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.MovieClipUtil;
   
   public class AimatState_10037 implements IAimatState
   {
      
      private var _maoyan:MovieClip;
      
      private var _obj:IAimatSprite;
      
      private var _count:int = 0;
      
      public function AimatState_10037()
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
         var _loc3_:MovieClip = null;
         this._obj = param1;
         var _loc4_:Array = [0.6,1.2,0.1,0,-263,0.6,1.2,0.16,0,-263,0.6,1.2,0.16,0,-263,0,0,0,1,0];
         if(param1.sprite is BasePeoleModel)
         {
            _loc3_ = BasePeoleModel(param1.sprite).skeleton.getSkeletonMC();
            _loc3_.filters = [new ColorMatrixFilter(_loc4_)];
            this._maoyan = AimatController.getResState(param2.id);
            this._maoyan.mouseEnabled = false;
            this._maoyan.y = -param1.hitRect.height;
            param1.sprite.addChildAt(this._maoyan,0);
         }
         else
         {
            param1.sprite.filters = [new ColorMatrixFilter(_loc4_)];
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = null;
         if(this._obj is BasePeoleModel)
         {
            if(Boolean(this._maoyan))
            {
               DisplayUtil.removeForParent(this._maoyan);
               this._maoyan = null;
            }
            BasePeoleModel(this._obj).skeleton.getSkeletonMC().filters = [];
            _loc1_ = AimatController.getResState(1000102);
            _loc1_.x = this._obj.sprite.x;
            _loc1_.y = this._obj.sprite.y;
            MovieClipUtil.playEndAndRemove(_loc1_);
            MapManager.currentMap.depthLevel.addChild(_loc1_);
         }
         else
         {
            this._obj.sprite.filters = [];
         }
         this._obj = null;
      }
   }
}

