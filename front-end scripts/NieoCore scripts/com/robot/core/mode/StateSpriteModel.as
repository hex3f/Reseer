package com.robot.core.mode
{
   import com.robot.core.aimat.AimatStateManamer;
   import com.robot.core.info.AimatInfo;
   
   public class StateSpriteModel extends SpriteModel implements IAimatSprite
   {
      
      protected var _aimatStateManager:AimatStateManamer;
      
      public function StateSpriteModel()
      {
         super();
         this._aimatStateManager = new AimatStateManamer(this);
      }
      
      public function get aimatStateManager() : AimatStateManamer
      {
         return this._aimatStateManager;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this._aimatStateManager.destroy();
         this._aimatStateManager = null;
      }
      
      public function aimatState(param1:AimatInfo) : void
      {
         if(Boolean(this._aimatStateManager))
         {
            this._aimatStateManager.execute(param1);
         }
      }
   }
}

