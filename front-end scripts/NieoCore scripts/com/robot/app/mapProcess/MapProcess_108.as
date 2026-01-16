package com.robot.app.mapProcess
{
   import com.robot.app.fightLevel.*;
   import com.robot.app.mapProcess.active.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.ui.*;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.*;
   import flash.utils.*;
   import org.taomee.manager.*;
   
   public class MapProcess_108 extends BaseMapProcess
   {
      
      private var timer:Timer;
      
      private var _townMc:MovieClip;
      
      private var _door1:DoorComponent;
      
      public function MapProcess_108()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.dd();
         this.timer = new Timer(9000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
         var _loc1_:DialogBox = new DialogBox();
         _loc1_.show("勇者之塔更新了，赛尔勇士们前进吧！",0,-85,conLevel["npc"]);
         this.configTown();
         this._door1 = new DoorComponent(new Point(120,370),150,100,conLevel,111);
      }
      
      private function configTown() : void
      {
         this._townMc = conLevel["townMc"];
         this._townMc["llmc"].visible = false;
         this._townMc.addEventListener(MouseEvent.MOUSE_OVER,this.onTownOverHandler);
         this._townMc.addEventListener(MouseEvent.MOUSE_OUT,this.onTownOutHandler);
         this._townMc["mc"]["mc"].gotoAndStop(1);
         conLevel["lightMc1"].buttonMode = true;
         conLevel["lightMc1"].addEventListener(MouseEvent.CLICK,this.onLightMc1Handler);
         conLevel["lightMc2"].buttonMode = true;
         conLevel["lightMc2"].addEventListener(MouseEvent.CLICK,this.onLightMc2Handler);
      }
      
      private function onTownOverHandler(param1:MouseEvent) : void
      {
         this._townMc["llmc"].visible = true;
         this._townMc["llmc"].gotoAndPlay(2);
      }
      
      private function onTownOutHandler(param1:MouseEvent) : void
      {
         this._townMc["llmc"].visible = false;
         this._townMc["llmc"].gotoAndStop(1);
      }
      
      private function onLightMc1Handler(param1:MouseEvent) : void
      {
         conLevel["lightMc1"].gotoAndStop(2);
         if(conLevel["lightMc2"].currentFrame == 2)
         {
            this.openDoor();
         }
      }
      
      private function onLightMc2Handler(param1:MouseEvent) : void
      {
         conLevel["lightMc2"].gotoAndStop(2);
         if(conLevel["lightMc1"].currentFrame == 2)
         {
            this.openDoor();
         }
      }
      
      private function openDoor() : void
      {
         ToolTipManager.remove(this._townMc);
         ToolTipManager.add(this._townMc,"勇者之塔神秘领域");
         this._townMc["mc"]["mc"].gotoAndPlay(1);
         this._townMc["mc"].gotoAndPlay(2);
         this._townMc.addEventListener(Event.ENTER_FRAME,this.onEnterHandler);
      }
      
      private function onEnterHandler(param1:Event) : void
      {
         if(this._townMc["mc"].currentFrame == this._townMc["mc"].totalFrames)
         {
            this._townMc["mc"]["mc"].gotoAndStop(1);
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:DialogBox = new DialogBox();
         _loc2_.show("要申请创建战队的赛尔们，请到我这里来!",0,-85,conLevel["npc"]);
      }
      
      override public function destroy() : void
      {
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.stop();
         this.timer = null;
         this._townMc.removeEventListener(MouseEvent.MOUSE_OVER,this.onTownOverHandler);
         this._townMc.removeEventListener(MouseEvent.MOUSE_OUT,this.onTownOutHandler);
         this._townMc.removeEventListener(Event.ENTER_FRAME,this.onEnterHandler);
         conLevel["lightMc1"].removeEventListener(MouseEvent.CLICK,this.onLightMc1Handler);
         conLevel["lightMc2"].removeEventListener(MouseEvent.CLICK,this.onLightMc2Handler);
         ToolTipManager.remove(this._townMc);
         this._townMc = null;
         this._door1.destroy();
         this._door1 = null;
      }
      
      public function fightTownHandler() : void
      {
         if(this._townMc["mc"].currentFrame != 1)
         {
            FightMHTController.check();
            return;
         }
         FightMHTController.checkIsFight(function(param1:Boolean):void
         {
            if(param1)
            {
               LevelManager.closeMouseEvent();
               FightLevelModel.setUp();
            }
            else
            {
               Alarm.show("    勇者之塔里的精灵非常强大，30级以上的精灵才能勉强过关，你可以先去教官办公室里的试炼之塔锻炼你的精灵哦。");
            }
         });
      }
      
      private function dd() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Array = PetManager.getBagMap();
         for(_loc1_ in _loc2_)
         {
         }
      }
   }
}

