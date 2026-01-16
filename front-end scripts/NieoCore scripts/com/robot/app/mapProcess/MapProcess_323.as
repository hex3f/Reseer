package com.robot.app.mapProcess
{
   import com.robot.app.task.control.*;
   import com.robot.core.animate.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_323 extends BaseMapProcess
   {
      
      private var qishiMC:MovieClip;
      
      private var qishiMovie:MovieClip;
      
      private var dululu:MovieClip;
      
      private var kuangshiMC:MovieClip;
      
      public function MapProcess_323()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.qishiMC = conLevel["qishiMC"];
         this.dululu = conLevel["dululuMC"];
         this.dululu.visible = false;
         this.kuangshiMC = animatorLevel["kuangshiMC"];
         this.kuangshiMC.gotoAndStop(1);
         this.kuangshiMC.visible = false;
         this.qishiMovie = animatorLevel["qishiMovie"];
         if(TasksManager.getTaskStatus(95) == TasksManager.COMPLETE)
         {
            DisplayUtil.removeForParent(this.qishiMC);
            DisplayUtil.removeForParent(this.dululu);
            DisplayUtil.removeForParent(this.kuangshiMC);
            DisplayUtil.removeForParent(this.qishiMovie);
            return;
         }
         if(TasksManager.getTaskStatus(95) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(95,this.taskStatus);
         }
      }
      
      override public function destroy() : void
      {
      }
      
      public function changeMapOne() : void
      {
         if(TasksManager.getTaskStatus(95) == TasksManager.COMPLETE)
         {
            MapManager.changeMap(322);
            return;
         }
         MapManager.changeLocalMap(322);
      }
      
      public function changeMapTwo() : void
      {
         if(TasksManager.getTaskStatus(95) == TasksManager.COMPLETE)
         {
            MapManager.changeMap(324);
            return;
         }
         MapManager.changeLocalMap(324);
      }
      
      private function taskStatus(param1:Array) : void
      {
         var arr:Array = param1;
         if(Boolean(arr[2]) && !arr[3])
         {
            this.qishiMovie.gotoAndStop(2);
            NpcDialog.show(NPC.QISHI,["你……*（%*#摩……*……（儿？鼻&%**%（@子#%……@！@"],["完了！难道他们要攻击我们？"],[function():void
            {
               NpcDialog.show(NPC.LAMU,["喂！大铁皮！他们是说你们是不是摩尔，为什么没有红鼻子！！如果不是摩尔的居民，请迅速离开这里！骑士可是我们这里最庄严的勇士哦！"],["大鼻子？红鼻子？"],[function():void
               {
                  NpcDialog.show(NPC.SEER,["不是吧！我们到哪里去搞红鼻子？有了！我就找个地方采摘一点红色的东西，随便先装在脸上？"],["嘿嘿！我果然聪明！这就行动！"],[function():void
                  {
                     TasksManager.complete(95,3,null,true);
                     TaskController_95.isShow = true;
                  }]);
               }]);
            }]);
         }
         if(Boolean(arr[4]) && !arr[5])
         {
            this.qishiMovie.gotoAndStop(1);
            this.qishiMC.buttonMode = true;
            this.qishiMC.addEventListener(MouseEvent.CLICK,this.onClickQishi);
         }
         if(Boolean(arr[5]) && !arr[6])
         {
            DisplayUtil.removeForParent(this.qishiMovie);
            this.dululu.visible = true;
            this.dululu.buttonMode = true;
            this.dululu.addEventListener(MouseEvent.CLICK,this.onFightDululu);
         }
         if(Boolean(arr[6]))
         {
            DisplayUtil.removeForParent(this.qishiMovie);
         }
      }
      
      private function onClickQishi(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         this.qishiMC.buttonMode = false;
         this.qishiMC.removeEventListener(MouseEvent.CLICK,this.onClickQishi);
         this.dululu.visible = true;
         AnimateManager.playMcAnimate(this.qishiMovie,3,"mc3",function():void
         {
            DisplayUtil.removeForParent(qishiMovie);
            NpcDialog.show(NPC.SEER,["有惊无险！吓死我了！哎呀！矿石！我忘记找矿石了……追踪器明明就说矿石在这里啊！会是在那里呢？"],["不会是给地上那些小煤球吃了吧？"],[function():void
            {
               NpcDialog.show(NPC.LAMU,["那个不是煤球！是嘟噜噜啦！不过你说的不是没道理哦！要不我们去看看？"],["那个小家伙叫嘟噜噜？长得到很可爱啊！"],[function():void
               {
                  TasksManager.complete(95,5,null,true);
                  dululu.buttonMode = true;
                  dululu.addEventListener(MouseEvent.CLICK,onFightDululu);
               }]);
            }]);
         });
      }
      
      private function onFightDululu(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         this.dululu.buttonMode = false;
         this.dululu.removeEventListener(MouseEvent.CLICK,this.onFightDululu);
         this.kuangshiMC.visible = true;
         this.dululu.removeEventListener(MouseEvent.CLICK,this.onFightDululu);
         DisplayUtil.removeForParent(this.dululu);
         AnimateManager.playMcAnimate(this.kuangshiMC,0,"",function():void
         {
            NpcDialog.show(NPC.SEER,["哇！还真的有矿石啊！大铁皮！你那个什么追踪器的要不也借给我耍耍？我感觉很高科技啊！#6"],["快去给那个叫大卫的吧！"],[function():void
            {
               DisplayUtil.removeForParent(kuangshiMC);
               MapManager.changeLocalMap(322);
               TaskController_95.get_kuangshi = true;
            }]);
         });
      }
      
      private function onFightDululuClose(param1:PetFightEvent) : void
      {
         var fightData:FightOverInfo = null;
         var evt:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,this.onFightDululuClose);
         fightData = evt.dataObj["data"];
         if(fightData.winnerID == MainManager.actorID)
         {
            this.kuangshiMC.visible = true;
            this.dululu.removeEventListener(MouseEvent.CLICK,this.onFightDululu);
            DisplayUtil.removeForParent(this.dululu);
            AnimateManager.playMcAnimate(this.kuangshiMC,0,"",function():void
            {
               NpcDialog.show(NPC.SEER,["哇！还真的有矿石啊！大铁皮！你那个什么追踪器的要不也借给我耍耍？我感觉很高科技啊！#6"],["快去给那个叫大卫的吧！"],[function():void
               {
                  DisplayUtil.removeForParent(kuangshiMC);
                  MapManager.changeLocalMap(322);
                  TaskController_95.get_kuangshi = true;
               }]);
            });
         }
         else
         {
            this.dululu.visible = true;
            this.dululu.buttonMode = true;
            this.dululu.addEventListener(MouseEvent.CLICK,this.onFightDululu);
         }
      }
   }
}

