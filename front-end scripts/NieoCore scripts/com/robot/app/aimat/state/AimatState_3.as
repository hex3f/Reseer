package com.robot.app.aimat.state
{
   import com.robot.core.aimat.IAimatState;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.mode.ActionSpriteModel;
   import com.robot.core.mode.IAimatSprite;
   import com.robot.core.mode.PetModel;
   
   public class AimatState_3 implements IAimatState
   {
      
      private var _mc:PetModel;
      
      private var _count:int = 0;
      
      private var objs:IAimatSprite;
      
      private var petArr:Array = [164,77,27,62,108];
      
      public function AimatState_3()
      {
         super();
      }
      
      public function get isFinish() : Boolean
      {
         if(Boolean(this.objs))
         {
            this._mc.x = this.objs.sprite.x;
            this._mc.y = this.objs.sprite.y;
            this._mc.direction = this.objs.direction;
         }
         ++this._count;
         if(this._count >= 50)
         {
            return true;
         }
         return false;
      }
      
      public function execute(param1:IAimatSprite, param2:AimatInfo) : void
      {
         this.objs = param1;
         if(param1.sprite.visible == false)
         {
            return;
         }
         var _loc3_:ActionSpriteModel = param1.sprite as ActionSpriteModel;
         this._mc = new PetModel(_loc3_);
         var _loc4_:PetShowInfo = new PetShowInfo();
         var _loc5_:int = int(Math.random() * 5);
         _loc4_.petID = int(this.petArr[_loc5_]);
         this._mc.show(_loc4_);
         this._mc.x -= 40;
         this._mc.y -= 5;
         param1.sprite.visible = false;
      }
      
      public function destroy() : void
      {
         this.objs.sprite.visible = true;
         this._mc.destroy();
         this._mc = null;
      }
   }
}

