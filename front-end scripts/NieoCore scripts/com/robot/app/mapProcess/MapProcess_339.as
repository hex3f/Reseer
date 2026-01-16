package com.robot.app.mapProcess
{
   import com.robot.app.task.control.TaskController_133;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.dayGift.DayGiftController;
   import com.robot.core.info.task.CateInfo;
   import com.robot.core.info.task.DayTalkInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.clearTimeout;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_339 extends BaseMapProcess
   {
      
      private var roadSwitchOpen:Boolean;
      
      private var switchMC:MovieClip;
      
      private var switchMCX:Number;
      
      private var switchMCY:Number;
      
      private var ballMC:MovieClip;
      
      private var ballMCX:Number;
      
      private var ballMCY:Number;
      
      private var powerarrowMC:MovieClip;
      
      private var powerarrowMCX:Number;
      
      private var powerarrowMCY:Number;
      
      private var powerMC:MovieClip;
      
      private var isInTask:Boolean;
      
      private const PATH:String = "com.robot.app.task.control";
      
      private var isClicked:Boolean;
      
      private var isMove:Boolean;
      
      private var count:uint = 0;
      
      private var isBallClicked:Boolean;
      
      private var isPowerMcClicked:Boolean;
      
      public function MapProcess_339()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.isInTask = false;
         depthLevel["seer_npc"].buttonMode = true;
         depthLevel["seer_npc"].addEventListener(MouseEvent.CLICK,this.onNpcClick);
         this.initTask133();
         this.switchMC = conLevel["switch_mc"];
         this.switchMC.buttonMode = true;
         this.switchMCX = this.switchMC.x;
         this.switchMCY = this.switchMC.y;
         ToolTipManager.add(this.switchMC,"机关开关");
         this.switchMC.addEventListener(MouseEvent.CLICK,this.onSwitchMCClickHandler);
         this.ballMC = conLevel["ball_mc"];
         conLevel["ball_effect"].visible = false;
         this.ballMC.buttonMode = true;
         this.ballMCX = this.ballMC.x;
         this.ballMCY = this.ballMC.y;
         ToolTipManager.add(this.ballMC,"彩色弹珠");
         this.powerarrowMC = conLevel["powerarrow_mc"];
         this.powerarrowMC.buttonMode = true;
         this.powerarrowMCX = this.powerarrowMC.x;
         this.powerarrowMCY = this.powerarrowMC.y;
         ToolTipManager.add(this.powerarrowMC,"力度条");
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMoveHandler);
         LevelManager.stage.addEventListener(MouseEvent.CLICK,this.onStageClickHandler);
         var _loc1_:Number = 0;
         while(_loc1_ < 3)
         {
            conLevel["arrow_" + _loc1_].buttonMode = true;
            conLevel["arrow_" + _loc1_].addEventListener(MouseEvent.CLICK,this.onArrowMCClickHandler);
            _loc1_++;
         }
      }
      
      override public function destroy() : void
      {
         ToolBarController.panel.visible = true;
         this.isBallClicked = false;
         this.isClicked = false;
         this.isPowerMcClicked = false;
         if(Boolean(this.switchMC))
         {
            this.switchMC.removeEventListener(MouseEvent.CLICK,this.onSwitchMCClickHandler);
         }
         if(Boolean(this.ballMC))
         {
            this.ballMC.removeEventListener(MouseEvent.CLICK,this.onBallClickHandler);
         }
         if(Boolean(this.powerarrowMC))
         {
            this.powerarrowMC.removeEventListener(MouseEvent.CLICK,this.onPowerMCClickHandler);
         }
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMoveHandler);
      }
      
      private function onNpcClick(param1:MouseEvent) : void
      {
         if(this.isInTask)
         {
            this.firstTask();
         }
         else
         {
            this.acceptTask133();
         }
      }
      
      private function onSwitchMCClickHandler(param1:MouseEvent) : void
      {
         this.isClicked = true;
         if(Boolean(this.switchMC))
         {
            this.switchMC.x = LevelManager.stage.mouseX;
            this.switchMC.y = LevelManager.stage.mouseY;
         }
      }
      
      private function onMoveHandler(param1:MouseEvent) : void
      {
         if(this.isClicked)
         {
            if(Boolean(this.switchMC))
            {
               this.isMove = true;
               this.switchMC.x = LevelManager.stage.mouseX;
               this.switchMC.y = LevelManager.stage.mouseY;
            }
         }
         if(this.isBallClicked)
         {
            if(Boolean(this.ballMC))
            {
               this.isMove = true;
               this.ballMC.x = LevelManager.stage.mouseX;
               this.ballMC.y = LevelManager.stage.mouseY;
            }
         }
         if(this.isPowerMcClicked)
         {
            if(Boolean(this.powerarrowMC))
            {
               this.isMove = true;
               this.powerarrowMC.x = LevelManager.stage.mouseX;
               this.powerarrowMC.y = LevelManager.stage.mouseY;
            }
         }
      }
      
      private function onArrowMCClickHandler(param1:MouseEvent) : void
      {
         var t:uint = 0;
         var t1:uint = 0;
         t = 0;
         t1 = 0;
         var e:MouseEvent = param1;
         var mc:MovieClip = e.currentTarget as MovieClip;
         switch(mc.name)
         {
            case "arrow_0":
            case "arrow_1":
               if(mc.currentFrame == mc.totalFrames)
               {
               }
               mc.gotoAndPlay(mc.currentFrame + 1);
               t = setTimeout(function():void
               {
                  clearTimeout(t);
                  getAward();
               },500);
               break;
            case "arrow_2":
               if(MainManager.actorInfo.superNono)
               {
                  if(Boolean(MainManager.actorModel.nono))
                  {
                     if(mc.currentFrame == mc.totalFrames)
                     {
                     }
                     mc.gotoAndPlay(mc.currentFrame + 1);
                     t1 = setTimeout(function():void
                     {
                        clearTimeout(t1);
                        getAward(true);
                     },500);
                  }
                  else
                  {
                     NpcDialog.show(NPC.SEER,["咦？这个箭头怎么这么奇怪？难道只有超能力才能打开它？"],["我这就去召唤我的" + NonoManager.info.nick],[function():void
                     {
                     }]);
                  }
               }
               else
               {
                  NpcDialog.show(NPC.SEER,["哇！！！这个箭头似乎有超能力！里面到底藏着什么？我想只要为NoNo注入超能力，它一定会有办法！"],["我这就去发明室为NoNo注入超能力！","我再到处看看吧！"],[function():void
                  {
                     MapManager.changeMap(107);
                  }]);
               }
         }
      }
      
      private function onStageClickHandler(param1:MouseEvent) : void
      {
         var t2:uint = 0;
         t2 = 0;
         var e:MouseEvent = param1;
         if(this.isClicked)
         {
            if(Boolean(this.switchMC))
            {
               if(this.switchMC.hitTestPoint(305,175))
               {
                  this.roadSwitchOpen = true;
                  this.switchMC.visible = false;
                  this.switchMC.removeEventListener(MouseEvent.CLICK,this.onSwitchMCClickHandler);
                  DisplayUtil.removeForParent(this.switchMC);
                  this.switchMC = null;
                  conLevel["switch_effect"].gotoAndPlay(2);
                  topLevel["roadarrow_mc"].gotoAndPlay(2);
                  t2 = setTimeout(function():void
                  {
                     clearTimeout(t2);
                     DisplayUtil.removeForParent(typeLevel["road_switch"]);
                     MapManager.currentMap.makeMapArray();
                     ballMC.addEventListener(MouseEvent.CLICK,onBallClickHandler);
                  },600);
                  this.isClicked = false;
               }
               else if(this.isMove)
               {
                  this.switchMC.x = this.switchMCX;
                  this.switchMC.y = this.switchMCY;
                  this.isClicked = false;
                  this.isMove = false;
               }
            }
         }
         if(this.isBallClicked)
         {
            if(Boolean(this.ballMC))
            {
               if(this.ballMC.hitTestPoint(385,415))
               {
                  this.ballMC.visible = false;
                  this.ballMC.removeEventListener(MouseEvent.CLICK,this.onBallClickHandler);
                  DisplayUtil.removeForParent(this.ballMC);
                  this.ballMC = null;
                  conLevel["ball_effect"].visible = true;
                  this.powerarrowMC.addEventListener(MouseEvent.CLICK,this.onPowerMCClickHandler);
                  this.isBallClicked = false;
               }
               else if(this.isMove)
               {
                  this.ballMC.x = this.ballMCX;
                  this.ballMC.y = this.ballMCY;
                  this.isBallClicked = false;
                  this.isMove = false;
               }
            }
         }
         if(this.isPowerMcClicked)
         {
            if(Boolean(this.powerarrowMC))
            {
               if(this.powerarrowMC.hitTestObject(conLevel["power_mc"]))
               {
                  this.powerarrowMC.visible = false;
                  this.powerarrowMC.removeEventListener(MouseEvent.CLICK,this.onPowerMCClickHandler);
                  DisplayUtil.removeForParent(this.powerarrowMC);
                  this.powerarrowMC = null;
                  AnimateManager.playMcAnimate(conLevel["power_mc"],2,"mc2",function():void
                  {
                     var t4:uint = 0;
                     t4 = 0;
                     conLevel["power_mc"].gotoAndStop(3);
                     t4 = setTimeout(function():void
                     {
                        powerMC = conLevel["power_mc"]["mc3"];
                        powerMC.buttonMode = true;
                        powerMC.addEventListener(MouseEvent.CLICK,onPowerClick);
                        isBallClicked = false;
                        clearTimeout(t4);
                     },300);
                  });
                  conLevel["power_mc"].gotoAndStop(2);
               }
               else if(this.isMove)
               {
                  this.powerarrowMC.x = this.powerarrowMCX;
                  this.powerarrowMC.y = this.powerarrowMCY;
                  this.isPowerMcClicked = false;
                  this.isMove = false;
               }
            }
         }
      }
      
      public function onBallClickHandler(param1:MouseEvent) : void
      {
         this.isBallClicked = true;
         this.isMove = false;
         if(Boolean(this.ballMC))
         {
            this.ballMC.x = LevelManager.stage.mouseX;
            this.ballMC.y = LevelManager.stage.mouseY;
         }
      }
      
      private function onPowerMCClickHandler(param1:MouseEvent) : void
      {
         this.isPowerMcClicked = true;
         this.isMove = false;
         if(Boolean(this.powerarrowMC))
         {
            this.powerarrowMC.x = LevelManager.stage.mouseX;
            this.powerarrowMC.y = LevelManager.stage.mouseY;
         }
      }
      
      private function onPowerClick(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this.powerMC.gotoAndStop(this.powerMC.currentFrame);
         if(this.powerMC.currentFrame >= 1 && this.powerMC.currentFrame < 6 || this.powerMC.currentFrame > 24 && this.powerMC.currentFrame <= 30)
         {
            AnimateManager.playMcAnimate(conLevel["ball_effect"],2,"mc2",function():void
            {
               conLevel["level1"].gotoAndStop(2);
               AnimateManager.playMcAnimate(conLevel["ball_effect"],3,"mc3",function():void
               {
                  powerMC.gotoAndPlay(2);
                  conLevel["level1"].gotoAndStop(1);
               });
            });
         }
         else if(this.powerMC.currentFrame >= 6 && this.powerMC.currentFrame <= 13 || this.powerMC.currentFrame > 17 && this.powerMC.currentFrame <= 24)
         {
            conLevel["level1"].gotoAndStop(3);
            AnimateManager.playMcAnimate(conLevel["ball_effect"],4,"mc4",function():void
            {
               conLevel["level2"].gotoAndStop(2);
               AnimateManager.playMcAnimate(conLevel["ball_effect"],5,"mc5",function():void
               {
                  powerMC.gotoAndPlay(2);
                  conLevel["level1"].gotoAndStop(1);
                  conLevel["level2"].gotoAndStop(1);
               });
            });
         }
         else
         {
            conLevel["level1"].gotoAndStop(3);
            conLevel["level2"].gotoAndStop(3);
            AnimateManager.playMcAnimate(conLevel["ball_effect"],6,"mc6",function():void
            {
               conLevel["award_effect"].gotoAndPlay(2);
               if(TasksManager.getTaskStatus(134) != TasksManager.COMPLETE)
               {
                  conLevel["monster_mc"].gotoAndPlay(2);
                  conLevel["monster_mc"].buttonMode = true;
                  conLevel["monster_mc"].addEventListener(MouseEvent.CLICK,onGetMonsterHandler);
               }
            });
         }
      }
      
      private function initTask133() : void
      {
         if(TasksManager.getTaskStatus(TaskController_133.TASK_ID) == TasksManager.UN_ACCEPT)
         {
            ToolBarController.panel.visible = false;
         }
         else if(TasksManager.getTaskStatus(TaskController_133.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_133.TASK_ID,function(param1:Array):void
            {
               if(!param1[0])
               {
                  isInTask = true;
               }
               else
               {
                  depthLevel["seer_npc"].visible = false;
               }
            });
         }
         else
         {
            depthLevel["seer_npc"].visible = false;
         }
      }
      
      private function acceptTask133() : void
      {
         NpcDialog.show(NPC.SEER,["咦？#7这个赛尔为什么这么奇怪呢？要不要上去问一下？"],["你……为什么……","我一会再来看看吧！"],[function():void
         {
            TasksManager.accept(TaskController_133.TASK_ID,function(param1:Boolean):void
            {
               var _loc2_:* = undefined;
               if(param1)
               {
                  TasksManager.setTaskStatus(TaskController_133.TASK_ID,TasksManager.ALR_ACCEPT);
                  _loc2_ = getDefinitionByName(PATH + "::TaskController_" + TaskController_133.TASK_ID);
                  _loc2_.start();
                  depthLevel["seer_npc"].removeEventListener(MouseEvent.CLICK,onNpcClick);
                  firstTask();
               }
               else
               {
                  Alarm.show("接受任务失败，请稍后再试！");
               }
            });
         }]);
      }
      
      private function getAwardOdds() : Boolean
      {
         var _loc1_:Number = 10 * Math.random();
         if(_loc1_ < 5)
         {
            return true;
         }
         return false;
      }
      
      private function getAward(param1:Boolean = false) : void
      {
         var _loc2_:Number = 0;
         if(param1)
         {
            if(this.getAwardOdds())
            {
               _loc2_ = 2059;
            }
            else
            {
               _loc2_ = 2060;
            }
         }
         else if(this.getAwardOdds())
         {
            _loc2_ = 24;
         }
         else
         {
            _loc2_ = 25;
         }
         var _loc3_:DayGiftController = new DayGiftController(_loc2_,5);
         _loc3_.addEventListener(DayGiftController.COUNT_SUCCESS,this.onCountSuccess);
         _loc3_.getCount();
      }
      
      private function onCountSuccess(param1:Event) : void
      {
         var event:Event = param1;
         var gift:DayGiftController = event.currentTarget as DayGiftController;
         gift.sendToServer(function(param1:DayTalkInfo):void
         {
            var _loc2_:CateInfo = null;
            var _loc3_:* = 0;
            var _loc4_:* = 0;
            for each(_loc2_ in param1.outList)
            {
               _loc3_ = uint(_loc2_.id);
               _loc4_ = uint(_loc2_.count);
               ItemInBagAlert.show(_loc3_,_loc4_ + "个<font color=\'#ff0000\'>" + ItemXMLInfo.getName(_loc3_) + "</font>已经放入你的储存箱中");
            }
         });
      }
      
      private function onGetMonsterHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         if(TasksManager.getTaskStatus(134) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(134,function(param1:Boolean):void
            {
               if(param1)
               {
                  TasksManager.complete(134,0);
               }
            });
         }
         conLevel["monster_mc"].removeEventListener(MouseEvent.CLICK,this.onGetMonsterHandler);
         conLevel["monster_mc"].gotoAndPlay(60);
      }
      
      private function firstTask() : void
      {
         NpcDialog.show(NPC.JELLYSEER,["我不记得我是谁了……你能够带我去其它星球上走走吗？"],["去充满音乐的艾迪星？"],[function():void
         {
            MapManager.changeMap(325);
         }]);
      }
   }
}

