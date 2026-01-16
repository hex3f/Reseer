package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.*;
   import com.robot.app.sceneInteraction.*;
   import com.robot.core.*;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.*;
   import com.robot.core.npc.*;
   import flash.display.*;
   import flash.events.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class MapProcess_306 extends BaseMapProcess
   {
      
      private var btn_0:MovieClip;
      
      private var btn_1:MovieClip;
      
      private var btn_2:MovieClip;
      
      private var btnArr:Array = [];
      
      private var blockStone:MovieClip;
      
      private var blockRoad:MovieClip;
      
      private var xita:MovieClip;
      
      public function MapProcess_306()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:MovieClip = null;
         MazeController.setup();
         this.btn_0 = conLevel["btn_0"];
         this.btn_1 = conLevel["btn_1"];
         this.btn_2 = conLevel["btn_2"];
         this.btnArr = [this.btn_0,this.btn_1,this.btn_2];
         for each(_loc1_ in this.btnArr)
         {
            _loc1_.buttonMode = true;
            _loc1_.gotoAndStop(1);
            _loc1_.addEventListener(MouseEvent.CLICK,this.onClickBtn);
         }
         this.blockStone = conLevel["blockStone"];
         this.blockStone.mouseEnabled = false;
         this.xita = conLevel["xita"];
         this.xita.mouseEnabled = false;
         this.blockRoad = typeLevel["blockRoad"];
      }
      
      override public function destroy() : void
      {
         MazeController.destroy();
      }
      
      private function onClickBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc3_.currentFrame == 1)
         {
            _loc3_.gotoAndStop(2);
         }
         else
         {
            _loc3_.gotoAndStop(1);
         }
         if(this.btn_0.currentFrame == 2 && this.btn_1.currentFrame == 2 && this.btn_2.currentFrame == 2)
         {
            for each(_loc2_ in this.btnArr)
            {
               _loc2_.buttonMode = false;
               _loc2_.gotoAndStop(2);
               _loc2_.removeEventListener(MouseEvent.CLICK,this.onClickBtn);
            }
            this.blockStone.gotoAndPlay(2);
            DisplayUtil.removeForParent(this.blockRoad);
            this.blockRoad = null;
            MapManager.currentMap.makeMapArray();
            this.xita.buttonMode = true;
            this.xita.mouseEnabled = true;
         }
      }
      
      public function fightWithXita() : void
      {
         SocketConnection.addCmdListener(CommandID.TALK_COUNT,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.TALK_COUNT,arguments.callee);
            var _loc3_:MiningCountInfo = param1.data as MiningCountInfo;
            var _loc4_:uint = _loc3_.miningCount;
            if(_loc4_ == 0)
            {
               FightInviteManager.fightWithBoss("西塔");
            }
            else
            {
               NpcDialog.show(NPC.SEER,["已经达到捕捉上限了哟~"],["……"],null);
            }
         });
         SocketConnection.send(CommandID.TALK_COUNT,700014 - 500000);
      }
   }
}

