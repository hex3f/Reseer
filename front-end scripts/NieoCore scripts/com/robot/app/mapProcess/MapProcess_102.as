package com.robot.app.mapProcess
{
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.fightNote.petKing.PetKingWaitPanel;
   import com.robot.app.sceneInteraction.ArenaController;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.temp.SpaceStationBuyController;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.map.MapLibManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.BossModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.DialogBox;
   import com.robot.core.ui.alert.Answer;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import org.taomee.effect.ColorFilter;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_102 extends BaseMapProcess
   {
      
      private var justin:MovieClip;
      
      private var confirm:SimpleButton;
      
      private var closeBt:SimpleButton;
      
      private var justin2:MovieClip;
      
      private var confirm2:SimpleButton;
      
      private var closeBt2:SimpleButton;
      
      private var justin3:MovieClip;
      
      private var confirm3:SimpleButton;
      
      private var closeBt3:SimpleButton;
      
      private var waitPanel:MovieClip;
      
      private var closeButton:SimpleButton;
      
      private var grassMC:SimpleButton;
      
      private var fireMC:SimpleButton;
      
      private var waterMC:SimpleButton;
      
      private var mcPet:String;
      
      private var j_npc:MovieClip;
      
      private var pet_mc:MovieClip;
      
      private var timer:Timer;
      
      private var dialogNum:uint = 0;
      
      private var _bossMC:BossModel;
      
      public function MapProcess_102()
      {
         super();
      }
      
      override protected function init() : void
      {
         ToolTipManager.add(conLevel["enterFight"],"加入精灵王对战");
         ToolTipManager.add(conLevel["buyMC"],"精灵道具购买");
         ToolTipManager.add(conLevel["arenaTouchBtn_1"],"挑战擂台");
         ToolTipManager.add(conLevel["arenaTouchBtn_2"],"挑战擂台");
         ToolTipManager.add(conLevel["arenaTouchBtn_3"],"挑战擂台");
         ToolTipManager.add(conLevel["dou_mc"],"精灵大乱斗");
         ToolTipManager.add(conLevel["door_2"],"暗黑武斗场");
         ArenaController.getInstance().setup(conLevel.getChildByName("arenaMc") as MovieClip);
         this.j_npc = conLevel["npc"];
         this.j_npc.visible = true;
         this.pet_mc = conLevel["pet_mc"];
         this.pet_mc.visible = false;
         this.timer = new Timer(9000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.start();
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         var _loc2_:DialogBox = new DialogBox();
         _loc2_.show("使自己的训练精灵的技术更上一个境界吧。",0,-85,conLevel["npc"]);
      }
      
      public function hitNpc() : void
      {
         NpcDialog.show(NPC.JUSTIN,["勇敢的铁皮，追寻圣光之力，你为何而来？"],["为正义而战！","为变得更强","为保护他人","为宇宙荣耀"],[this.step1,this.step1,this.step1,this.step1]);
      }
      
      public function step1() : void
      {
         NpcDialog.show(NPC.JUSTIN,["若遇不可战胜之敌,你将如何？"],["信念重于胜负","直面强敌","暂避锋芒","守护到底"],[this.step2,this.step3,this.step2,this.step2]);
      }
      
      public function step2() : void
      {
         NpcDialog.show(NPC.JUSTIN,["你将如何裁决阴暗的灵魂？"],["彻底超度","禁锢封印","将心比心","光之惩戒"],[null]);
      }
      
      public function step3() : void
      {
         NpcDialog.show(NPC.JUSTIN,["你将如何裁决阴暗的灵魂？"],["彻底超度","禁锢封印","将心比心","光之惩戒"],[null,null,null,this.fight]);
      }
      
      public function fight() : void
      {
         Answer.show("英勇的小尼尔，请迎接挑战吧！");
         this.initYKLSBoss();
      }
      
      private function initYKLSBoss() : void
      {
         if(!this._bossMC)
         {
            this._bossMC = new BossModel(124,0);
            this._bossMC.show(new Point(354,438),0);
            setTimeout(function():void
            {
               _bossMC.direction = "right";
            },300);
         }
         this._bossMC.mouseEnabled = true;
         this._bossMC.addEventListener(MouseEvent.CLICK,this.onBossClick);
         ToolTipManager.add(this._bossMC,"英卡洛斯");
      }
      
      private function onBossClick(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.mapID == 102)
         {
            FightInviteManager.fightWithBoss("光之惩戒",0);
         }
      }
      
      override public function destroy() : void
      {
         ToolTipManager.remove(conLevel["enterFight"]);
         ToolTipManager.remove(conLevel["buyMC"]);
         ToolTipManager.remove(conLevel["arenaTouchBtn_1"]);
         ToolTipManager.remove(conLevel["arenaTouchBtn_2"]);
         ToolTipManager.remove(conLevel["arenaTouchBtn_3"]);
         ToolTipManager.remove(conLevel["door_2"]);
         ArenaController.getInstance().figth();
         if(Boolean(this.closeBt))
         {
            this.closeBt.removeEventListener(MouseEvent.CLICK,this.closeMC);
            this.closeBt = null;
         }
         if(Boolean(this.confirm))
         {
            this.confirm.removeEventListener(MouseEvent.CLICK,this.closeMC);
            this.confirm.removeEventListener(MouseEvent.CLICK,this.givePetScr);
            this.confirm = null;
         }
         this.justin = null;
         this.justin2 = null;
         this.justin3 = null;
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer.stop();
         this.timer = null;
      }
      
      public function onPetWarHandler() : void
      {
         PetKingWaitPanel.showPetWar();
      }
      
      private function onPetList(param1:PetEvent) : void
      {
         var i:int = 0;
         var e:PetEvent = param1;
         var cheak:Function = function(param1:int):void
         {
            if(param1 == 1 || param1 == 2 || param1 == 3)
            {
               grassMC.filters = [ColorFilter.setGrayscale()];
               grassMC.mouseEnabled = false;
            }
            else if(param1 == 7 || param1 == 8 || param1 == 9)
            {
               fireMC.filters = [ColorFilter.setGrayscale()];
               fireMC.mouseEnabled = false;
            }
            else if(param1 == 4 || param1 == 5 || param1 == 6)
            {
               waterMC.filters = [ColorFilter.setGrayscale()];
               waterMC.mouseEnabled = false;
            }
         };
         PetManager.removeEventListener(PetEvent.STORAGE_LIST,this.onPetList);
         this.waitPanel = MapLibManager.getMovieClip("GetPet");
         LevelManager.appLevel.addChild(this.waitPanel);
         DisplayUtil.align(this.waitPanel,null,AlignType.MIDDLE_CENTER);
         this.closeButton = this.waitPanel["closeBtn"];
         this.closeButton.addEventListener(MouseEvent.CLICK,this.closeMC);
         this.grassMC = this.waitPanel["grassMC"];
         this.waterMC = this.waitPanel["waterMC"];
         this.fireMC = this.waitPanel["fireMC"];
         this.grassMC.addEventListener(MouseEvent.CLICK,this.onGivePet);
         this.waterMC.addEventListener(MouseEvent.CLICK,this.onGivePet);
         this.fireMC.addEventListener(MouseEvent.CLICK,this.onGivePet);
         i = 1;
         while(i <= 9)
         {
            if(PetManager.containsBagForID(i))
            {
               cheak(i);
            }
            else if(PetManager.containsStorageForID(i))
            {
               cheak(i);
            }
            i++;
         }
      }
      
      public function enterFight() : void
      {
         PetKingWaitPanel.show();
      }
      
      public function HitJustin() : void
      {
         this.justin = MapLibManager.getMovieClip("JustinGivePet3");
         DisplayUtil.align(this.justin,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         this.confirm = this.justin["ConfirmBtn"];
         this.closeBt = this.justin["closeBtn"];
         this.closeBt.addEventListener(MouseEvent.CLICK,this.closeMC);
         if(MainManager.actorInfo.monKingWin >= 10)
         {
            SocketConnection.addCmdListener(CommandID.IS_COLLECT,function(param1:SocketEvent):void
            {
               SocketConnection.removeCmdListener(CommandID.IS_COLLECT,arguments.callee);
               var _loc3_:ByteArray = param1.data as ByteArray;
               var _loc4_:uint = _loc3_.readUnsignedInt();
               var _loc5_:Boolean = Boolean(_loc3_.readUnsignedInt());
               if(_loc5_)
               {
                  GetPetlog3();
               }
               else
               {
                  GetPetlog2();
               }
            });
            SocketConnection.send(CommandID.IS_COLLECT,301);
         }
         else
         {
            LevelManager.topLevel.addChild(this.justin);
            this.confirm.addEventListener(MouseEvent.CLICK,this.closeMC);
         }
      }
      
      public function GetPetlog2() : void
      {
         this.justin2 = MapLibManager.getMovieClip("JustinGivePet5");
         DisplayUtil.align(this.justin2,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         this.confirm2 = this.justin2["ConfirmBtn"];
         this.closeBt2 = this.justin2["closeBtn"];
         this.closeBt2.addEventListener(MouseEvent.CLICK,this.closeMC);
         this.confirm2.addEventListener(MouseEvent.CLICK,this.givePetScr);
         LevelManager.topLevel.addChild(this.justin2);
      }
      
      public function GetPetlog3() : void
      {
         this.justin3 = MapLibManager.getMovieClip("JustinGivePet4");
         DisplayUtil.align(this.justin3,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         this.confirm3 = this.justin3["ConfirmBtn"];
         this.closeBt3 = this.justin3["closeBtn"];
         this.closeBt3.addEventListener(MouseEvent.CLICK,this.closeMC);
         this.confirm3.addEventListener(MouseEvent.CLICK,this.closeMC);
         LevelManager.topLevel.addChild(this.justin3);
      }
      
      public function GetPetlog4() : void
      {
      }
      
      private function givePetScr(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.justin,false);
         DisplayUtil.removeForParent(this.justin2,false);
         LevelManager.openMouseEvent();
         PetManager.addEventListener(PetEvent.STORAGE_LIST,this.onPetList);
         PetManager.getStorageList();
      }
      
      private function closeMC(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.waitPanel,false);
         DisplayUtil.removeForParent(this.justin,false);
         DisplayUtil.removeForParent(this.justin2,false);
         DisplayUtil.removeForParent(this.justin3,false);
         LevelManager.openMouseEvent();
      }
      
      private function onGivePet(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         if(param1.currentTarget == this.grassMC)
         {
            _loc2_ = 1;
            this.mcPet = "布布种子精灵";
         }
         else if(param1.currentTarget == this.fireMC)
         {
            _loc2_ = 7;
            this.mcPet = "小火猴精灵";
         }
         else if(param1.currentTarget == this.waterMC)
         {
            _loc2_ = 4;
            this.mcPet = "伊优精灵";
         }
         SocketConnection.addCmdListener(CommandID.PET_COLLECT,this.onPrize);
         SocketConnection.send(CommandID.PET_COLLECT,301,_loc2_);
         var _loc3_:SimpleButton = param1.target as SimpleButton;
         DisplayUtil.removeForParent(this.waitPanel,false);
      }
      
      private function onPrize(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_COLLECT,this.onPrize);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         var _loc5_:String = PetXMLInfo.getName(_loc3_);
         if(PetManager.length < 6)
         {
            PetManager.setIn(_loc4_,1);
            PetInBagAlert.show(_loc3_,_loc5_ + "已经放入了你的精灵背包！");
         }
         else
         {
            PetManager.addStorage(_loc3_,_loc4_);
            PetInStorageAlert.show(_loc3_,_loc5_ + "已经放入了你的精灵仓库！");
         }
      }
      
      public function buyHandler() : void
      {
         SpaceStationBuyController.show();
      }
      
      public function onArenaHit() : void
      {
         ArenaController.getInstance().strat();
      }
      
      public function onEnterHandler() : void
      {
         if(MainManager.actorInfo.superNono)
         {
            if(Boolean(MainManager.actorModel.nono))
            {
               MapManager.changeMap(110);
            }
            else
            {
               NpcTipDialog.show("你必须带上超能NoNo才能进入暗黑武斗场哦！",null,NpcTipDialog.NONO);
            }
         }
         else if(Boolean(NonoManager.info.func[12]))
         {
            if(Boolean(MainManager.actorModel.nono))
            {
               MapManager.changeMap(110);
            }
            else
            {
               NpcTipDialog.show("你必须带上NoNo才能进入暗黑武斗场哦！",null,NpcTipDialog.NONO_2);
            }
         }
         else
         {
            NpcTipDialog.show("你必须给NoNo装载上反物质芯片才能进入暗黑武斗场哦！",null,NpcTipDialog.NONO_2);
         }
      }
   }
}

