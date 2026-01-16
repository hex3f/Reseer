package com.robot.core.mode
{
   import com.robot.core.aimat.AimatStateManamer;
   import com.robot.core.info.AimatInfo;
   import com.robot.core.ui.DialogBox;
   
   public class BobyModel extends ActionSpriteModel implements IAimatSprite
   {
      
      public static const expList:Array = ["#0","#1","#2","#3","#4","#5","#6","#7","#8","#9","#10","#11","#12","#13","#14","#15","#16","#17","#18","#19","#20","#21","#22"];
      
      protected var _aimatStateManager:AimatStateManamer;
      
      protected var _dialogBox:DialogBox;
      
      public function BobyModel()
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
         if(Boolean(this._aimatStateManager))
         {
            this._aimatStateManager.destroy();
         }
         this._aimatStateManager = null;
         if(Boolean(this._dialogBox))
         {
            this._dialogBox.destroy();
            this._dialogBox = null;
         }
      }
      
      public function aimatState(param1:AimatInfo) : void
      {
         if(Boolean(this._aimatStateManager))
         {
            this._aimatStateManager.execute(param1);
         }
      }
      
      public function showBox(param1:String, param2:Number = 0) : void
      {
         if(Boolean(this._dialogBox))
         {
            this._dialogBox.destroy();
            this._dialogBox = null;
         }
         this._dialogBox = new DialogBox();
         this._dialogBox.name = "dialogBox";
         this._dialogBox.show(param1,0,-height + param2,this);
      }
   }
}

