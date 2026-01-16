package com.robot.app.npc.npcClass
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.BossModel;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.INpc;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.npc.NpcInfo;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import org.taomee.manager.ToolTipManager;
   
   public class NpcClass_100 implements INpc
   {
      
      private var _curNpcModel:NpcModel;
      
      private var _bossMC:BossModel;
      
      public function NpcClass_100(param1:NpcInfo, param2:DisplayObject)
      {
         super();
         this._curNpcModel = new NpcModel(param1,param2 as Sprite);
         this._curNpcModel.addEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
         this._curNpcModel.visible = true;
      }
      
      private function onClickNpc(param1:NpcEvent) : void
      {
         var _loc2_:NpcEvent = param1;
         this._curNpcModel.refreshTask();
         NpcDialog.show(100,["王的力量不会排斥黑暗，你确定要进入黑暗之中寻找王的力量吗？"],["我准备好了","我还没想好"],[this.fightEntry]);
      }
      
      private function fightEntry() : void
      {
         NpcDialog.show(100,["深渊的大门已经锁上，我还记得前三位\'OOO\',后四位你来决定吧！"],["OOoO","oOoO","oOOo","OoOO"],[this.fight,null,null,null]);
      }
      
      private function fight() : void
      {
         this.initSGLSBoss();
      }
      
      private function initSGLSBoss() : void
      {
         if(!this._bossMC)
         {
            this._bossMC = new BossModel(125,0);
            this._bossMC.show(new Point(705,300),0);
            setTimeout(function():void
            {
               _bossMC.direction = "left";
            },300);
         }
         this._bossMC.mouseEnabled = true;
         this._bossMC.addEventListener(MouseEvent.CLICK,this.onBossClick);
         ToolTipManager.add(this._bossMC,"萨格罗斯");
      }
      
      private function onBossClick(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.mapID == 9)
         {
            FightInviteManager.fightWithBoss("萨格罗斯",0);
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._curNpcModel))
         {
            this._curNpcModel.destroy();
            this._curNpcModel.removeEventListener(NpcEvent.NPC_CLICK,this.onClickNpc);
            this._curNpcModel = null;
         }
      }
      
      public function get npc() : NpcModel
      {
         return this._curNpcModel;
      }
   }
}

