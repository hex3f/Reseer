package com.robot.app.mapProcess
{
   import com.robot.app.energy.utils.*;
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.spacesurvey.*;
   import com.robot.app.task.control.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.BossModel;
   import com.robot.core.mode.OgreModel;
   import com.robot.core.npc.*;
   import com.robot.core.ui.alert.Answer;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import org.taomee.manager.ToolTipManager;
   
   public class MapProcess_10 extends BaseMapProcess
   {
      
      private var pipi_npc:OgreModel;
      
      private var _pipi_mc:MovieClip;
      
      private var _pipi_pic:MovieClip;
      
      private var _bossMC:BossModel;
      
      public function MapProcess_10()
      {
         super();
      }
      
      override protected function init() : void
      {
         SpaceSurveyTool.getInstance().show("克洛斯星");
         this.initMiddleFestivalBoss();
         this._pipi_mc = topLevel["pipi_mc"];
         this._pipi_mc.gotoAndStop(1);
         this._pipi_mc.visible = false;
         if(TasksManager.getTaskStatus(TaskController_90.TASK_ID) == TasksManager.COMPLETE)
         {
            if(Boolean(NpcController.curNpc))
            {
               this.addEventNpc();
            }
            return;
         }
         this._pipi_pic = MapLibManager.getMovieClip("Pipipic");
         topLevel.addChild(this._pipi_pic);
         this._pipi_pic.x = 2000;
         this._pipi_pic.y = 97;
         TasksManager.getProStatusList(TaskController_90.TASK_ID,function(param1:Array):void
         {
            TaskController_90.initFun(delAdd,_pipi_mc,_pipi_pic);
            if(Boolean(param1[0]))
            {
               addEventNpc();
            }
         });
      }
      
      private function initMiddleFestivalBoss() : void
      {
         if(!this._bossMC)
         {
            this._bossMC = new BossModel(4150,0);
            this._bossMC.show(new Point(139,153),0);
            setTimeout(function():void
            {
               _bossMC.direction = "right";
            },300);
         }
         this._bossMC.mouseEnabled = true;
         this._bossMC.addEventListener(MouseEvent.CLICK,this.onBossClick);
         ToolTipManager.add(this._bossMC,"拂晓兔");
      }
      
      private function onBossClick(param1:MouseEvent) : void
      {
         var _loc2_:MouseEvent = param1;
         Answer.show("古今共明月，乡心两地同。此刻人间无聚散，天涯一杯中。\r兔兔来找你玩耍啦~(˶╹ꇴ╹˶)~",this.okHandler);
      }
      
      private function okHandler() : void
      {
         if(MainManager.actorInfo.mapID == 10)
         {
            FightInviteManager.fightWithBoss("拂晓兔");
         }
      }
      
      private function addEventNpc() : void
      {
         this._pipi_mc.addEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         if(Boolean(NpcController.curNpc))
         {
            this._pipi_mc.removeEventListener(Event.ENTER_FRAME,this.enterFrameHandler);
            NpcController.curNpc.npc.npc.visible = false;
         }
      }
      
      private function clickPIPIHandler(param1:MouseEvent) : void
      {
         TaskController_90.clickPIPI();
      }
      
      public function exploitOre() : void
      {
         EnergyController.exploit();
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
      }
      
      private function delAdd() : void
      {
      }
      
      override public function destroy() : void
      {
      }
   }
}

