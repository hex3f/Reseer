package com.robot.app.mapProcess
{
   import com.robot.app.buyItem.*;
   import com.robot.app.experienceShared.*;
   import com.robot.app.task.SeerInstructor.*;
   import com.robot.app.task.books.*;
   import com.robot.app.task.control.*;
   import com.robot.app.team.*;
   import com.robot.core.config.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.teamPK.*;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.net.SharedObject;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_101 extends BaseMapProcess
   {
      
      private var bookBtn:MovieClip;
      
      private var _so:SharedObject;
      
      private var blueBtn:SimpleButton;
      
      private var redBtn:SimpleButton;
      
      private var lightMC:MovieClip;
      
      private var teamPanel:MovieClip;
      
      private var _armExgApp:AppModel;
      
      private var _armExSo:SharedObject;
      
      private var _tipMc:MovieClip;
      
      private var _armBookPanel:AppModel;
      
      private var panel:AppModel;
      
      public function MapProcess_101()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.blueBtn = conLevel["blueBtn"];
         this.lightMC = conLevel["light"];
         this.lightMC.visible = false;
         if(TasksManager.getTaskStatus(89) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(89,function(param1:Array):void
            {
               if(!param1[0] || param1[0] && !param1[1])
               {
                  lightMC.visible = true;
               }
            });
         }
         this.blueBtn.addEventListener(MouseEvent.CLICK,this.clickBlueBtn);
         this.redBtn = conLevel["redBtn"];
         this.redBtn.addEventListener(MouseEvent.CLICK,this.clickRedBtn);
         ToolTipManager.add(this.blueBtn,"领取保卫战装备");
         ToolTipManager.add(this.redBtn,"领取保卫战装备");
         this.bookBtn = conLevel["bookBtn"];
         this.bookBtn.addEventListener(MouseEvent.CLICK,this.showBook);
         ToolTipManager.add(this.bookBtn,"教官手册");
         this.redBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         this.blueBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         conLevel["clothMc"].addEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         this.redBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         this.blueBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         conLevel["clothMc"].addEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         ToolTipManager.add(conLevel["pond_mc"],"经验累积器");
         this._so = SOManager.getUserSO(SOManager.ARMBOOK_READED);
         if(!this._so.data.hasOwnProperty("isShow"))
         {
            this._so.data["isShow"] = false;
            SOManager.flush(this._so);
         }
         else if(this._so.data["isShow"] == true)
         {
            conLevel["armBookBtn"]["mc"].gotoAndStop(1);
            conLevel["armBookBtn"]["mc"].visible = false;
         }
         conLevel["armBookBtn"].buttonMode = true;
         ToolTipManager.add(conLevel["armBookBtn"],"要塞保卫战手册");
         conLevel["armBookBtn"].addEventListener(MouseEvent.CLICK,this.onArmBookHandler);
         this._armExSo = SOManager.getUserSO(SOManager.ARM_EXCHANGEBOOK_READED);
         if(!this._armExSo.data.hasOwnProperty("isShow"))
         {
            this._armExSo.data["isShow"] = false;
            SOManager.flush(this._armExSo);
         }
         else if(this._armExSo.data["isShow"] == true)
         {
            conLevel["armExchangeMc"]["mc"].gotoAndStop(1);
            conLevel["armExchangeMc"]["mc"].visible = false;
         }
         conLevel["armExchangeMc"].buttonMode = true;
         ToolTipManager.add(conLevel["armExchangeMc"],"战队徽章兑换手册");
         conLevel["armExchangeMc"].addEventListener(MouseEvent.CLICK,this.onArmExcBookHandler);
         NpcTaskManager.addTaskListener(50002,this.onInstructorHandler);
         NpcTaskManager.addTaskListener(89,this.testsHander);
      }
      
      public function hitNpc() : void
      {
         var closeBtn:SimpleButton = null;
         var joinTeam:SimpleButton = null;
         var createTeam:SimpleButton = null;
         if(!this.teamPanel)
         {
            this.teamPanel = MapLibManager.getMovieClip("ui_createTeam");
            closeBtn = this.teamPanel["closeBtn"];
            joinTeam = this.teamPanel["joinTeam"];
            createTeam = this.teamPanel["createTeam"];
            closeBtn.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               DisplayUtil.removeForParent(teamPanel);
            });
            joinTeam.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               if(MainManager.actorInfo.teamInfo.id == 0)
               {
                  TeamController.searchTeam();
               }
               else
               {
                  Alarm.show("你已经加入了一个战队，如果想要创建一个战队的话，要先退出之前的战队哦！");
               }
               DisplayUtil.removeForParent(teamPanel);
            });
            createTeam.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               TeamController.create();
               DisplayUtil.removeForParent(teamPanel);
            });
         }
         DisplayUtil.align(this.teamPanel,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(this.teamPanel);
      }
      
      private function testsHander(param1:Event) : void
      {
         var _loc2_:uint = uint(MainManager.actorInfo.curFreshStage);
         var _loc3_:uint = Math.max(MainManager.actorInfo.curFreshStage,MainManager.actorInfo.maxFreshStage);
         if(_loc3_ >= 10)
         {
            NpcTaskManager.removeTaskListener(89,this.testsHander);
            if(TasksManager.getTaskStatus(89) == TasksManager.ALR_ACCEPT)
            {
               this.com1(true);
            }
            else if(TasksManager.getTaskStatus(89) == TasksManager.UN_ACCEPT)
            {
               TasksManager.accept(89,this.com1);
            }
            return;
         }
         if(TasksManager.getTaskStatus(89) == TasksManager.UN_ACCEPT)
         {
            TaskController_89.task89Hander(this.lightMC);
         }
      }
      
      private function com1(param1:Boolean) : void
      {
         var b1:Boolean = param1;
         if(b1)
         {
            TasksManager.complete(89,0,function(param1:Boolean):void
            {
               var b1:Boolean = param1;
               if(b1)
               {
                  TasksManager.complete(89,1,function(param1:Boolean):void
                  {
                     if(param1)
                     {
                        TasksManager.complete(89,2);
                     }
                  });
               }
            });
         }
      }
      
      private function onOverHnalder(param1:MouseEvent) : void
      {
         conLevel["clothMc"].gotoAndStop(2);
      }
      
      private function onOutHnalder(param1:MouseEvent) : void
      {
         conLevel["clothMc"].gotoAndStop(1);
      }
      
      private function onArmExcBookHandler(param1:MouseEvent) : void
      {
         this._armExSo.data["isShow"] = true;
         SOManager.flush(this._armExSo);
         conLevel["armExchangeMc"]["mc"].gotoAndStop(1);
         conLevel["armExchangeMc"]["mc"].visible = false;
         if(this._armExgApp == null)
         {
            this._armExgApp = new AppModel(ClientConfig.getBookModule("TeamBadgeExchangePanel"),"正在打开");
            this._armExgApp.setup();
         }
         this._armExgApp.show();
      }
      
      private function clickBlueBtn(param1:MouseEvent) : void
      {
         ItemAction.buyMultiItem(4,"蓝宝石套装",100233,100234,100235,100236);
      }
      
      private function clickRedBtn(param1:MouseEvent) : void
      {
         if(Boolean(MainManager.actorInfo.vip))
         {
            ItemAction.buyMultiItem(4,"红宝石套装",100747,100748,100749,100750);
         }
         else
         {
            Alarm.show("你还没有开通超能NoNo，不能领取红宝石套装");
         }
      }
      
      private function onInstructorHandler(param1:Event) : void
      {
         this.showTask();
      }
      
      override public function destroy() : void
      {
         NpcTaskManager.removeTaskListener(89,this.testsHander);
         if(Boolean(this.panel))
         {
            this.panel.destroy();
            this.panel = null;
         }
         NpcTaskManager.removeTaskListener(50002,this.onInstructorHandler);
         ToolTipManager.remove(this.bookBtn);
         this.bookBtn.removeEventListener(MouseEvent.CLICK,this.showBook);
         this.bookBtn = null;
         ToolTipManager.remove(conLevel["pond_mc"]);
         if(Boolean(this._tipMc))
         {
            this.onTipClickHandler(null);
         }
         if(Boolean(this._armBookPanel))
         {
            this._armBookPanel.destroy();
            this._armBookPanel = null;
         }
         ToolTipManager.remove(conLevel["armBookBtn"]);
         conLevel["armBookBtn"].removeEventListener(MouseEvent.CLICK,this.onArmBookHandler);
         this._so = null;
         if(Boolean(this._armExgApp))
         {
            this._armExgApp.destroy();
            this._armExgApp = null;
         }
         this._armExSo = null;
         ToolTipManager.remove(this.blueBtn);
         ToolTipManager.remove(this.redBtn);
         this.blueBtn.removeEventListener(MouseEvent.CLICK,this.clickBlueBtn);
         this.redBtn.removeEventListener(MouseEvent.CLICK,this.clickRedBtn);
         this.redBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         this.blueBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         conLevel["clothMc"].removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHnalder);
         this.redBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         this.blueBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         conLevel["clothMc"].removeEventListener(MouseEvent.MOUSE_OUT,this.onOutHnalder);
         this.redBtn = null;
         this.blueBtn = null;
      }
      
      public function pkSign() : void
      {
         TeamPKManager.register();
      }
      
      public function trialsFunc() : void
      {
         TaskController_89.oneStage(this.lightMC);
      }
      
      private function showBook(param1:MouseEvent) : void
      {
         InstructorBook.loadPanel();
      }
      
      public function showTask() : void
      {
         InstructorDialog.show();
      }
      
      public function showTip() : void
      {
         ExperienceSharedModel.check();
      }
      
      private function onEnterHandler(param1:Event) : void
      {
         if(conLevel["diskMc"].currentFrame == conLevel["diskMc"].totalFrames)
         {
            conLevel["diskMc"].removeEventListener(Event.ENTER_FRAME,this.onEnterHandler);
            TasksManager.setProStatus(29,1,true);
            conLevel["diskMc"].gotoAndStop(1);
            this._tipMc = MapLibManager.getMovieClip("ShawnTip_MC");
            this._tipMc["txt"].text = "B002";
            this._tipMc["nameTxt"].text = MainManager.actorInfo.nick;
            this._tipMc["msgTxt"].text = "\n    一个学员同时能够有几个教官？";
            this._tipMc["closeBtn"].addEventListener(MouseEvent.CLICK,this.onTipClickHandler);
            LevelManager.appLevel.addChild(this._tipMc);
            DisplayUtil.align(this._tipMc,null,AlignType.MIDDLE_CENTER);
         }
      }
      
      private function onTipClickHandler(param1:MouseEvent) : void
      {
         this._tipMc["closeBtn"].removeEventListener(MouseEvent.CLICK,this.onTipClickHandler);
         DisplayUtil.removeForParent(this._tipMc);
         this._tipMc = null;
      }
      
      private function onArmBookHandler(param1:MouseEvent) : void
      {
         this._so.data["isShow"] = true;
         SOManager.flush(this._so);
         conLevel["armBookBtn"]["mc"].gotoAndStop(1);
         conLevel["armBookBtn"]["mc"].visible = false;
         if(!this._armBookPanel)
         {
            this._armBookPanel = new AppModel(ClientConfig.getBookModule("ArmWarBookPanel"),"正在打开");
            this._armBookPanel.setup();
         }
         this._armBookPanel.show();
      }
      
      public function showChartsList() : void
      {
         if(this.panel == null)
         {
            this.panel = ModuleManager.getModule(ClientConfig.getAppModule("TeamChartsPanel"),"正在打开战队排行榜");
            this.panel.setup();
         }
         this.panel.show();
      }
   }
}

