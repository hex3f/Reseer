package com.robot.petFightModule
{
   import com.robot.app.automaticFight.*;
   import com.robot.core.*;
   import com.robot.core.event.*;
   import com.robot.core.info.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.info.fightInfo.attack.AttackValue;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.pet.petWar.*;
   import com.robot.core.ui.alert.*;
   import com.robot.petFightModule.assetManager.*;
   import com.robot.petFightModule.control.*;
   import com.robot.petFightModule.loadUI.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.SharedObject;
   import flash.utils.*;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PetFightEntry
   {
      
      public static var fighterCon:PetFightController;
      
      public static var isAutoSelectPet:Boolean;
      
      private static var sound:Sound;
      
      private static var loadingMC:Sprite;
      
      private static var overData:FightOverInfo;
      
      public static var currentPetCatchTime:uint;
      
      private static var assetLoading:AssetsLoadManager;
      
      private static var soundChannel:SoundChannel;
      
      private static var _info:FightStartInfo;
      
      private static var _emotionMc:MovieClip;
      
      private static var _emotionShowTime:uint;
      
      private static var _statusMc:MovieClip;
      
      private static var _statusShowTime:uint;
      
      public static var isCanAuto:Boolean = false;
      
      public static var _petInfoMap:HashMap = new HashMap();
      
      public static var so:SharedObject = SOManager.getUserSO(SOManager.LOCAL_CONFIG);
      
      private static var _effectName:Array = ["伤害有所提升","受到伤害下降","技能命中自身几率下降","免疫异常状态","免疫能力下降","每回合恢复一定体力值","自身攻击速度提升","致命一击率提升","免疫物理攻击","免疫特殊攻击","随着体力下降，自身攻击提升","随着体力下降，自身特攻提升","随着体力下降，自身防御提升","随着体力下降，自身特防提升","招式无限","反弹一部分伤害","反馈自身的能力下降","所有技能都可以消除强化","双方都会流失体力","每次攻击都会吸取一定生命值"];
      
      private static var SPBOSS:Object = {
         261:zslmboss_sound,
         70:zslmboss_sound,
         393:zslmboss_sound,
         347:zslmboss_sound,
         432:zslmboss_sound,
         125:zslmboss_sound,
         124:zslmboss_sound
      };
      
      private static var enemyBossPetId:uint = 0;
      
      private static var isOutFinish:Boolean = false;
      
      public function PetFightEntry()
      {
         super();
      }
      
      private static function comHandler(param1:Event) : void
      {
         var e:Event = param1;
         if(loadingMC is PetWarLoadingUI)
         {
            (loadingMC as PetWarLoadingUI).removeEventListener(Event.COMPLETE,comHandler);
         }
         else if(loadingMC is FightLoadingView)
         {
            SocketConnection.send(CommandID.READY_TO_FIGHT);
         }
         setTimeout(function():void
         {
            SocketConnection.send(CommandID.READY_TO_FIGHT);
         },4000);
      }
      
      private static function onStartFight(param1:PetFightEvent) : void
      {
         var _loc2_:FightStartInfo = null;
         LevelManager.fightLevel.addChild(fighterCon.mainPanel);
         SoundManager.stopSound();
         setTimeout(function():void
         {
            var _loc1_:uint = FighterModeFactory.enemyMode.petID;
            var _loc2_:Class = SPBOSS[_loc1_] as Class;
            if(SoundManager.isPlay_b)
            {
               if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS && Boolean(_loc2_))
               {
                  sound = new _loc2_();
               }
               else if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS)
               {
                  sound = new boss_sound();
               }
               else if(PetFightModel.status == PetFightModel.FIGHT_WITH_PLAYER)
               {
                  sound = new Top_sound();
               }
               else
               {
                  sound = new FightBg_Sound();
               }
               soundChannel = sound.play(0,9999999);
            }
         },1);
         DisplayUtil.removeForParent(loadingMC);
         loadingMC = null;
         _loc2_ = param1.dataObj as FightStartInfo;
         isCanAuto = _loc2_.isCanAuto;
         if(isCanAuto && Boolean(AutomaticFightManager.isStart))
         {
            AutomaticFightManager.showFightTips();
         }
         fighterCon.setup(_loc2_);
         UserManager.clear();
         TaomeeManager.fightSpeed = 3;
         TaomeeManager.stage.frameRate = 24 * TaomeeManager.fightSpeed;
      }
      
      private static function init() : void
      {
         SocketConnection.addCmdListener(CommandID.READY_TO_FIGHT,onReadyToFight);
         SocketConnection.addCmdListener(CommandID.LOAD_PERCENT,onPercent);
         fighterCon = new PetFightController();
         fighterCon.addEventListener(PetFightEvent.START_FIGHT,onStartFight);
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
      }
      
      public static function clear(param1:FightOverInfo, param2:Boolean = false) : void
      {
         var _loc3_:Bitmap = null;
         TaomeeManager.stage.frameRate = 24;
         var _loc4_:String = null;
         var _loc5_:FightOverInfo = param1;
         var _loc6_:Boolean = param2;
         var _loc7_:BitmapData = new BitmapData(960,560,false);
         _loc7_.draw(MainManager.getStage());
         _loc3_ = new Bitmap(_loc7_);
         LevelManager.fightLevel.addChild(_loc3_);
         if(fighterCon.isEscape)
         {
            _loc4_ = "恭喜你，逃跑成功！";
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(fighterCon.isOvertime)
         {
            assetLoading.removeEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
            assetLoading.removeEventListener(AssetsEvent.PROGRESS,onProgress);
            try
            {
               assetLoading.destroy();
            }
            catch(e:Error)
            {
            }
            if(_loc5_.winnerID == MainManager.actorID)
            {
               _loc4_ = "对方操作超时，你在这场战斗中获得了胜利！";
            }
            else
            {
               _loc4_ = "你操作超时了，战斗结束！";
            }
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(fighterCon.isDraw)
         {
            _loc4_ = "这场战斗双方打成平手！^_^";
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(fighterCon.isSysError)
         {
            _loc4_ = "很抱歉，系统出错，本次战斗结束";
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(fighterCon.isPlayerLost)
         {
            _loc4_ = "对方中途退出，你在这场战斗中获得了胜利！";
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(fighterCon.isNpcEscape)
         {
            _loc4_ = "很可惜，这只精灵逃跑了！";
            showNormalTip(_loc3_,_loc4_);
            return;
         }
         if(_loc6_)
         {
            _loc3_.parent.removeChild(_loc3_);
            _loc3_ = null;
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_PROP,_loc3_));
            destroy();
            return;
         }
         if(_loc5_.winnerID == MainManager.actorID)
         {
            FightOverPanel.showWin(_loc3_,overData);
         }
         else
         {
            FightOverPanel.showLost(_loc3_,overData);
         }
         destroy();
      }
      
      private static function onPercent(param1:SocketEvent) : void
      {
         var _loc2_:FightLoadPercentInfo = param1.data as FightLoadPercentInfo;
         if(_loc2_.id != MainManager.actorID)
         {
            if(Boolean(loadingMC) && PetFightModel.mode != PetFightModel.PET_MELEE && loadingMC is FightLoadingView)
            {
               (loadingMC as FightLoadingView).setOtherPro(_loc2_.percent);
            }
         }
      }
      
      private static function onReadyToFight(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         if(PetFightModel.mode != PetFightModel.PET_MELEE)
         {
            (loadingMC as FightLoadingView).ok(_loc3_);
         }
      }
      
      private static function onProgress(param1:AssetsEvent) : void
      {
         if(PetFightModel.mode != PetFightModel.PET_MELEE)
         {
            (loadingMC as FightLoadingView).setMyPro(param1.percent);
         }
      }
      
      public static function showEmotion(param1:AttackValue) : void
      {
         if(param1.userID == MainManager.actorID)
         {
            if(param1.atkTimes == 0)
            {
               removeEmotionFromStage();
               _emotionMc = new playerEmotion_1();
               addEmotionToStage();
            }
            if(param1.remainHP / FighterModeFactory.playerMode.maxHP < 0.1)
            {
               removeEmotionFromStage();
               _emotionMc = new playerEmotion_2();
               addEmotionToStage();
            }
            if(param1.isCrit)
            {
               removeEmotionFromStage();
               _emotionMc = new playerEmotion_3();
               addEmotionToStage();
            }
         }
         else
         {
            if(param1.atkTimes == 0)
            {
               removeEmotionFromStage();
               _emotionMc = new emenyEmotion_1();
               addEmotionToStage();
            }
            if(param1.remainHP / FighterModeFactory.enemyMode.maxHP < 0.1)
            {
               removeEmotionFromStage();
               _emotionMc = new emenyEmotion_2();
               addEmotionToStage();
            }
            if(param1.isCrit)
            {
               removeEmotionFromStage();
               _emotionMc = new emenyEmotion_3();
               addEmotionToStage();
            }
         }
      }
      
      private static function addEmotionToStage() : void
      {
         var _loc1_:Point = null;
         if(Boolean(_emotionMc))
         {
            _emotionMc.mouseChildren = false;
            _emotionMc.mouseEnabled = false;
            _loc1_ = _emotionMc.localToGlobal(new Point(115,120));
            _emotionMc.x = _loc1_.x;
            _emotionMc.y = _loc1_.y;
            LevelManager.fightLevel.addChild(_emotionMc);
            _emotionShowTime = setTimeout(removeEmotionFromStage,2000);
         }
      }
      
      private static function removeEmotionFromStage() : void
      {
         if(Boolean(_emotionMc))
         {
            clearTimeout(_emotionShowTime);
            DisplayUtil.removeForParent(_emotionMc);
            _emotionMc = null;
         }
      }
      
      private static function onCloseFight(param1:PetFightEvent) : void
      {
         var data:FightOverInfo = null;
         data = null;
         data = null;
         data = null;
         var event:PetFightEvent = param1;
         data = event.dataObj["data"];
         overData = data;
         setTimeout(function():void
         {
            clear(data);
         },1000);
      }
      
      private static function destroy() : void
      {
         RemainHpManager.clear();
         if(Boolean(soundChannel))
         {
            soundChannel.stop();
         }
         PetFightModel.enemyName = "";
         SocketConnection.removeCmdListener(CommandID.READY_TO_FIGHT,onReadyToFight);
         SocketConnection.removeCmdListener(CommandID.LOAD_PERCENT,onPercent);
         fighterCon.removeEventListener(PetFightEvent.START_FIGHT,onStartFight);
         fighterCon.destroy();
         fighterCon = null;
         EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,onCloseFight);
         LevelManager.openMouseEvent();
         SoundManager.playSound();
         if(Boolean(loadingMC))
         {
            if(loadingMC is FightLoadingView)
            {
               (loadingMC as FightLoadingView).destroy();
            }
            loadingMC.parent.removeChild(loadingMC);
            loadingMC = null;
         }
         LevelManager.showOrRemoveMapLevelandToolslevel(true,true);
         LevelManager.showAll(LevelManager.toolsLevel,LevelManager.iconLevel);
      }
      
      private static function onLoadAll(param1:Event) : void
      {
         assetLoading.removeEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
         assetLoading.removeEventListener(AssetsEvent.PROGRESS,onProgress);
         assetLoading.destroy();
         if(PetFightModel.mode == PetFightModel.PET_MELEE)
         {
            (loadingMC as PetWarLoadingUI).startLoad();
            (loadingMC as PetWarLoadingUI).addEventListener(Event.COMPLETE,comHandler);
         }
         else if(PetFightModel.mode != PetFightModel.PET_MELEE && PetFightModel.mode != PetFightModel.FIGHT_WITH_PLAYER)
         {
            (loadingMC as FightLoadingView).setMyPro(100);
            (loadingMC as FightLoadingView).ok(MainManager.actorID);
            SocketConnection.send(CommandID.READY_TO_FIGHT);
         }
         else
         {
            (loadingMC as FightLoadingView).setMyPro(100);
            (loadingMC as FightLoadingView).ok(MainManager.actorID);
            setTimeout(function():void
            {
               SocketConnection.send(CommandID.READY_TO_FIGHT);
            },800);
         }
      }
      
      public static function setup(param1:Array, param2:Array, param3:Array, param4:HashMap) : void
      {
         _petInfoMap = param4;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:FighetUserInfo = null;
         LevelManager.hideAll(LevelManager.toolsLevel,LevelManager.iconLevel);
         LevelManager.showOrRemoveMapLevelandToolslevel(false,true);
         if(PetFightModel.status == PetFightModel.FIGHT_WITH_BOSS)
         {
            sound = new boss_sound();
         }
         else
         {
            sound = new FightBg_Sound();
         }
         init();
         assetLoading = new AssetsLoadManager();
         for each(_loc5_ in param2)
         {
            assetLoading.addPetID(_loc5_);
         }
         for each(_loc6_ in param3)
         {
            assetLoading.addSkillID(_loc6_);
         }
         if(!loadingMC)
         {
            if(PetFightModel.mode != PetFightModel.PET_MELEE)
            {
               loadingMC = new FightLoadingView(param1);
            }
            else
            {
               loadingMC = new PetWarLoadingUI(PetWarController.allPetIdA);
            }
         }
         LevelManager.root.addChild(loadingMC);
         assetLoading.addEventListener(AssetsEvent.LOAD_ALL_ASSETS,onLoadAll);
         assetLoading.addEventListener(AssetsEvent.PROGRESS,onProgress);
         assetLoading.loadAssets();
      }
      
      private static function showNormalTip(param1:Bitmap, param2:String) : void
      {
         var bmp:Bitmap = null;
         bmp = null;
         var sprite:Sprite = null;
         bmp = null;
         bmp = param1;
         var str:String = param2;
         if(AutomaticFightManager.isStart)
         {
            AutomaticFightManager.fightOver(bmp);
            destroy();
            return;
         }
         sprite = Alarm.show(str,function():void
         {
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.ALARM_CLICK,overData));
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_PROP,bmp));
         });
         MainManager.getStage().addChild(sprite);
         destroy();
      }
   }
}

