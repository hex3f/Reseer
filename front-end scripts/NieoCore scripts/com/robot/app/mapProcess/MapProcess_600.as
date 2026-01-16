package com.robot.app.mapProcess
{
   import com.robot.app.fightLevel.FightPetBagController;
   import com.robot.app.freshFightLevel.FightLevelModel;
   import com.robot.app.freshFightLevel.FreshSuccessFightRequestInfo;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_600 extends BaseMapProcess
   {
      
      private var b1:Boolean = true;
      
      private var _allBossA:Array = [];
      
      private var _curIndex:uint = 0;
      
      private var _bossContainer:Sprite;
      
      private var _allPointA:Array = [new Point(410,296),new Point(490,296),new Point(570,296)];
      
      private var tt:uint;
      
      private var nextBossId:Array;
      
      public function MapProcess_600()
      {
         super();
      }
      
      override protected function init() : void
      {
         this.b1 = true;
         LevelManager.iconLevel.visible = false;
         ToolBarController.panel.hide();
         this.upDatahandler();
      }
      
      private function upDatahandler() : void
      {
         var _loc1_:* = 0;
         var _loc2_:String = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         if(FightLevelModel.getCurLevel > FightLevelModel.maxLevel)
         {
            _loc1_ = FightLevelModel.maxLevel;
         }
         else
         {
            _loc1_ = FightLevelModel.getCurLevel;
         }
         if(FightLevelModel.getCurLevel < 10)
         {
            conLevel["tens_mc"].gotoAndStop(2);
            conLevel["units_mc"].gotoAndStop(FightLevelModel.getCurLevel + 2);
         }
         else if(FightLevelModel.getCurLevel == 30)
         {
            conLevel["tens_mc"].gotoAndStop(5);
            conLevel["units_mc"].gotoAndStop(2);
         }
         else
         {
            _loc2_ = String(FightLevelModel.getCurLevel);
            _loc3_ = uint(_loc2_.slice(0,1));
            _loc4_ = uint(_loc2_.slice(1,2));
            conLevel["tens_mc"].gotoAndStop(_loc3_ + 2);
            conLevel["units_mc"].gotoAndStop(_loc4_ + 2);
         }
         ToolTipManager.add(conLevel["door_0"],"离开");
         ToolTipManager.add(conLevel["mosterMc"],"精灵背包");
         conLevel["mosterMc"].addEventListener(MouseEvent.CLICK,this.onMonsterHandler);
         this._allBossA = [];
         this._curIndex = 0;
         this.loadBoss(FightLevelModel.getBossId[0]);
      }
      
      private function onMonsterHandler(param1:MouseEvent) : void
      {
         FightPetBagController.show();
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         ToolTipManager.remove(conLevel["mosterMc"]);
         conLevel["mosterMc"].removeEventListener(MouseEvent.CLICK,this.onMonsterHandler);
         ToolTipManager.remove(conLevel["door_0"]);
         if(Boolean(this._allBossA))
         {
            _loc1_ = 0;
            while(_loc1_ < this._allBossA.length)
            {
               ToolTipManager.remove(this._allBossA[_loc1_]);
               DisplayUtil.removeForParent(this._allBossA[_loc1_]);
               this._allBossA[_loc1_] = null;
               _loc1_++;
            }
            this._allBossA = null;
         }
         if(Boolean(this._bossContainer))
         {
            this._bossContainer.removeEventListener(MouseEvent.CLICK,this.onFightBtnClickHandler);
            DisplayUtil.removeForParent(this._bossContainer);
            this._bossContainer = null;
         }
      }
      
      private function loadBoss(param1:uint) : void
      {
         var _loc2_:String = ClientConfig.getPetSwfPath(param1);
         ResourceManager.getResource(_loc2_,this.loadComHandler,"pet");
      }
      
      private function loadComHandler(param1:DisplayObject) : void
      {
         var mc:MovieClip = null;
         var dis:DisplayObject = param1;
         mc = null;
         mc = dis as MovieClip;
         if(Boolean(mc))
         {
            mc.gotoAndStop("down");
            mc.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = mc.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            this._allBossA.push(mc);
            if(this._allBossA.length < FightLevelModel.getBossId.length)
            {
               this.loadBoss(FightLevelModel.getBossId[this._allBossA.length]);
            }
            else
            {
               this.addAllBossToMap();
            }
         }
      }
      
      private function addAllBossToMap() : void
      {
         var _loc1_:Number = NaN;
         this._bossContainer = new Sprite();
         var _loc2_:int = 0;
         while(_loc2_ < this._allBossA.length)
         {
            this._bossContainer.addChild(this._allBossA[_loc2_] as MovieClip);
            _loc1_ = this._allBossA[_loc2_].width * 1.5;
            this._allBossA[_loc2_].width *= 1.6;
            this._allBossA[_loc2_].height *= 1.6;
            ToolTipManager.add(this._allBossA[_loc2_],PetXMLInfo.getName(FightLevelModel.getBossId[_loc2_]));
            _loc2_++;
         }
         if(this._allBossA.length == 1)
         {
            this._allBossA[0].x = this._allPointA[1].x;
            this._allBossA[0].y = this._allPointA[1].y;
            this._allBossA[0].scaleX *= 1.2;
            this._allBossA[0].scaleY *= 1.2;
         }
         MapManager.currentMap.depthLevel.addChild(this._bossContainer);
         this._bossContainer.buttonMode = true;
         this._bossContainer.addEventListener(MouseEvent.CLICK,this.onFightBtnClickHandler);
      }
      
      private function onFightBtnClickHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.buttonMode = false;
         param1.currentTarget.removeEventListener(MouseEvent.CLICK,this.onFightBtnClickHandler);
         this.tt = setTimeout(this.timeOutHandler,2000);
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,this.handle);
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_BOSS;
         SocketConnection.addCmdListener(CommandID.FRESH_START_FIGHT_LEVEL,this.onSuccessHandler);
         SocketConnection.send(CommandID.FRESH_START_FIGHT_LEVEL);
      }
      
      private function timeOutHandler() : void
      {
         clearTimeout(this.tt);
      }
      
      private function onSuccessHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.FRESH_START_FIGHT_LEVEL,this.onSuccessHandler);
         var _loc2_:FreshSuccessFightRequestInfo = param1.data as FreshSuccessFightRequestInfo;
         this.nextBossId = _loc2_.getBossId;
      }
      
      private function handle(param1:PetFightEvent) : void
      {
         var data:FightOverInfo = null;
         var cls:* = undefined;
         var e:PetFightEvent = param1;
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,this.handle);
         data = e.dataObj["data"];
         cls = getDefinitionByName("com.robot.petFightModule.PetFightEntry");
         if(Boolean(cls.fighterCon.isEscape))
         {
            this.b1 = true;
            return;
         }
         if(data.winnerID == MainManager.actorInfo.userID)
         {
            this.b1 = true;
            ++MainManager.actorInfo.curFreshStage;
            ++MainManager.actorInfo.maxFreshStage;
            if(MainManager.actorInfo.curFreshStage > FightLevelModel.maxLevel)
            {
               this.leaveFight();
            }
            else
            {
               FightLevelModel.setBossId = this.nextBossId;
               FightLevelModel.setCurLevel = MainManager.actorInfo.curFreshStage;
               if(MainManager.actorInfo.curFreshStage >= 10)
               {
                  if(TasksManager.getTaskStatus(89) == TasksManager.ALR_ACCEPT)
                  {
                     TasksManager.getProStatusList(89,function(param1:Array):void
                     {
                        if(Boolean(param1[0]) && !param1[1])
                        {
                           TasksManager.complete(89,1,null,true);
                        }
                     });
                  }
               }
               MapManager.changeMap(600);
            }
         }
         else
         {
            this.b1 = false;
            this.leaveFight();
         }
      }
      
      private function onLeaveFightHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.FRESH_LEAVE_FIGHT_LEVEL,this.onLeaveFightHandler);
         ToolBarController.panel.show();
         LevelManager.iconLevel.visible = true;
         if(this.b1 == false)
         {
            LevelManager.iconLevel.addChild(Alarm.show("很遗憾，刚才的战斗你没有获胜，你需要重新开始挑战，不要气馁，再接再厉。"));
         }
         else
         {
            this.b1 = false;
         }
      }
      
      public function leaveFight() : void
      {
         SocketConnection.addCmdListener(CommandID.FRESH_LEAVE_FIGHT_LEVEL,this.onLeaveFightHandler);
         SocketConnection.send(CommandID.FRESH_LEAVE_FIGHT_LEVEL);
      }
   }
}

