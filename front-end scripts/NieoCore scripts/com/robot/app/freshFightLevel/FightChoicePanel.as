package com.robot.app.freshFightLevel
{
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class FightChoicePanel
   {
      
      private var uiLoader:MCLoader;
      
      private var app:ApplicationDomain;
      
      private var panel:Sprite;
      
      private var b1:Boolean = false;
      
      private const urlStr:String = "resource/freshFightLevel/fightLevel.swf";
      
      private var currentBossId:Array;
      
      public function FightChoicePanel()
      {
         super();
      }
      
      public function show() : void
      {
         this.loaderUI(this.urlStr);
      }
      
      private function loaderUI(param1:String) : void
      {
         this.uiLoader = new MCLoader(param1,LevelManager.appLevel,1,"正在进入试炼之塔");
         this.uiLoader.addEventListener(MCLoadEvent.SUCCESS,this.onLoadUISuccessHandler);
         this.uiLoader.doLoad();
      }
      
      private function onLoadUISuccessHandler(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this.panel = new (this.app.getDefinition("UI_FightPanel") as Class)() as Sprite;
         LevelManager.appLevel.addChild(this.panel);
         DisplayUtil.align(this.panel,null,AlignType.MIDDLE_CENTER);
         if(MainManager.actorInfo.maxFreshStage == 0)
         {
            this.panel["goOnBtn"].visible = false;
            this.panel["choiceBtn"].visible = false;
         }
         if(MainManager.actorInfo.curFreshStage >= 1 && MainManager.actorInfo.maxFreshStage > 0)
         {
            this.panel["startFightBtn"].visible = false;
         }
         if(MainManager.actorInfo.curFreshStage > FightLevelModel.maxLevel)
         {
            this.panel["goOnBtn"].visible = false;
         }
         this.setLevel(MainManager.actorInfo.curFreshStage.toString());
         this.addEvent();
      }
      
      private function addEvent() : void
      {
         this.panel["bgMc"].buttonMode = true;
         this.panel["bgMc"].addEventListener(MouseEvent.MOUSE_DOWN,this.onBgDownHandler);
         this.panel["closeBtn"].addEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.panel["goOnBtn"].addEventListener(MouseEvent.CLICK,this.onGoonBtnClickHandler);
         this.panel["choiceBtn"].addEventListener(MouseEvent.CLICK,this.onChoiceClickHandler);
         this.panel["startFightBtn"].addEventListener(MouseEvent.CLICK,this.onStartFightClickHandler);
      }
      
      private function removeEvent() : void
      {
         this.panel["bgMc"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onBgDownHandler);
         this.panel["closeBtn"].removeEventListener(MouseEvent.CLICK,this.onCloseBtnClickHandler);
         this.panel["goOnBtn"].removeEventListener(MouseEvent.CLICK,this.onGoonBtnClickHandler);
         this.panel["choiceBtn"].removeEventListener(MouseEvent.CLICK,this.onChoiceClickHandler);
         this.panel["startFightBtn"].removeEventListener(MouseEvent.CLICK,this.onStartFightClickHandler);
      }
      
      private function onBgDownHandler(param1:MouseEvent) : void
      {
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
         this.panel.startDrag();
      }
      
      private function onUpHandler(param1:MouseEvent) : void
      {
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
         this.panel.stopDrag();
      }
      
      private function onCloseBtnClickHandler(param1:MouseEvent) : void
      {
         this.destroy();
      }
      
      private function onGoonBtnClickHandler(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.curFreshStage > FightLevelModel.maxLevel)
         {
            Alarm.show("你已经到达最高层,不能再挑战了");
            return;
         }
         this.choiceFight(0);
      }
      
      private function onChoiceClickHandler(param1:MouseEvent) : void
      {
         if(!this.b1)
         {
            FightListPanel.show(this.panel,new Point(this.panel.width,150),this.app,FightLevelModel.list);
            this.b1 = true;
         }
         else
         {
            FightListPanel.destroy();
            this.b1 = false;
         }
      }
      
      private function onStartFightClickHandler(param1:MouseEvent) : void
      {
         this.choiceFight(0);
      }
      
      public function choiceFight(param1:uint) : void
      {
         SocketConnection.addCmdListener(CommandID.FRESH_CHOICE_FIGHT_LEVEL,this.onChoiceSuccessHandler);
         SocketConnection.send(CommandID.FRESH_CHOICE_FIGHT_LEVEL,param1);
      }
      
      private function onChoiceSuccessHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.FRESH_CHOICE_FIGHT_LEVEL,this.onChoiceSuccessHandler);
         var _loc2_:FreshChoiceLevelRequestInfo = param1.data as FreshChoiceLevelRequestInfo;
         this.currentBossId = _loc2_.getBossId;
         this.destroy();
         FightLevelModel.setBossId = this.currentBossId;
         FightLevelModel.setCurLevel = _loc2_.getLevel;
         MainManager.actorInfo.curFreshStage = _loc2_.getLevel;
         MapManager.changeMap(600);
      }
      
      public function destroy() : void
      {
         this.removeEvent();
         if(this.b1)
         {
            this.b1 = false;
            FightListPanel.destroy();
         }
         DisplayUtil.removeForParent(this.panel);
         this.panel = null;
         LevelManager.openMouseEvent();
      }
      
      private function setLevel(param1:String) : void
      {
         this.panel["levelTxt"].text = param1;
      }
   }
}

