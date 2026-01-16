package com.robot.app.npc.npcClass
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.config.UpdateConfig;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class NpcClass_10 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      private var greenArray:Array = [];
      
      private var green_index:uint = 0;
      
      public function NpcClass_10(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this.greenArray = UpdateConfig.greenArray.slice();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         (param2 as Sprite).addEventListener(MouseEvent.CLICK,this.onClickHandler);
      }
      
      private function onClickHandler(param1:MouseEvent = null) : void
      {
         var event:MouseEvent = param1;
         if(this.green_index == this.greenArray.length)
         {
            this.green_index = 0;
            return;
         }
         NpcTipDialog.show(this.greenArray[this.green_index],this.onClickHandler,NpcTipDialog.DINGDING,-60,function():void
         {
            green_index = 0;
         });
         ++this.green_index;
      }
      
      public function destroy() : void
      {
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

