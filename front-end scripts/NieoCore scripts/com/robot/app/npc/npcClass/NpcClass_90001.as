package com.robot.app.npc.npcClass
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class NpcClass_90001 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      public function NpcClass_90001(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
         this._curNpcModel.visible = true;
      }
      
      private function onClickNpc(param1:NpcEvent) : void
      {
         var e:NpcEvent = param1;
         this._curNpcModel.refreshTask();
         NpcDialog.show(20,["曾仰望星空，曾遨游天外，跌跌撞撞跑向人间，却从未走散那个少年"],["稚趣初萌","旧径重溯","心游万仞","离开"],[function():void
         {
            FightInviteManager.fightWithBoss("稚趣初萌",10);
         },function():void
         {
            FightInviteManager.fightWithBoss("旧径重溯",11);
         },function():void
         {
            FightInviteManager.fightWithBoss("心游万仞",12);
         },null]);
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

