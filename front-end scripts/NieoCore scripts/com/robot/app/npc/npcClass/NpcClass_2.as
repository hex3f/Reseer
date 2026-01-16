package com.robot.app.npc.npcClass
{
   import com.robot.app.task.noviceGuide.XixiDialog;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class NpcClass_2 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      public function NpcClass_2(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
      }
      
      private function onClickNpc(param1:NpcEvent) : void
      {
         this._curNpcModel.refreshTask();
         XixiDialog.show(param1.taskID);
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.removeEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
            this._curNpcModel.destroy();
            this._curNpcModel = null;
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

