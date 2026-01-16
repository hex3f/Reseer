package com.robot.app.fightNote
{
   import com.robot.app.automaticFight.AutomaticFightManager;
   import com.robot.app.info.fightInvite.InviteNoteInfo;
   import com.robot.app.protectSys.KillPluginSys;
   import com.robot.app.user.UserInfoController;
   import com.robot.core.CommandID;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Answer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.utils.setTimeout;
   
   public class FightInviteManager
   {
      
      private static var iconMC:MovieClip;
      
      private static var array:Array = [];
      
      private static var fightSwitch:Boolean = true;
      
      private static var NUM:Number = 0.03;
      
      public static var isKillBigPetB:Boolean = false;
      
      public static var isKillBigPetB0:Boolean = false;
      
      public static var isKillBigPetB1:Boolean = false;
      
      public function FightInviteManager()
      {
         super();
      }
      
      public static function fightWithPlayer(param1:UserInfo) : void
      {
         if(PetManager.length == 0)
         {
            Alarm.show("你没有带赛尔精灵，不能战斗!");
            return;
         }
         var _loc2_:PetInfo = PetManager.getPetInfo(PetManager.defaultTime);
         if(_loc2_ == null)
         {
            Alarm.show("你没有可出战的精灵！");
            return;
         }
         FightWaitPanel.selectMode(param1);
      }
      
      public static function fightWithNpc(param1:uint) : void
      {
         if(!fightSwitch)
         {
            return;
         }
         if(Math.random() < NUM && !AutomaticFightManager.isStart)
         {
            KillPluginSys.start();
            return;
         }
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_NPC;
         PetFightModel.enemyName = "野外精灵";
         SocketConnection.send(CommandID.FIGHT_NPC_MONSTER,param1);
         fightSwitch = false;
         changeSwitch();
      }
      
      public static function fightWithBoss(param1:String, param2:uint = 0, param3:Boolean = false) : void
      {
         if(!fightSwitch)
         {
            return;
         }
         if(Math.random() < NUM && !AutomaticFightManager.isStart && !param3)
         {
            KillPluginSys.start();
            return;
         }
         PetFightModel.enemyName = param1;
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_BOSS;
         SocketConnection.send(CommandID.CHALLENGE_BOSS,param2);
         fightSwitch = false;
         changeSwitch();
      }
      
      public static function fightWithSpecial() : void
      {
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         PetFightModel.status = PetFightModel.FIGHT_WITH_NPC;
         PetFightModel.enemyName = "稀有精灵";
         SocketConnection.send(CommandID.FIGHT_SPECIAL_PET);
      }
      
      private static function changeSwitch() : void
      {
         setTimeout(function():void
         {
            fightSwitch = true;
         },1000);
      }
      
      public static function add(param1:InviteNoteInfo) : void
      {
         array.push(param1);
         checkLength();
      }
      
      private static function next() : InviteNoteInfo
      {
         var _loc1_:InviteNoteInfo = array.shift() as InviteNoteInfo;
         checkLength();
         return _loc1_;
      }
      
      private static function checkLength() : void
      {
         if(!iconMC)
         {
            iconMC = UIManager.getMovieClip("FightInvite_Icon");
            iconMC.buttonMode = true;
            iconMC.x = 320;
            iconMC.y = 20;
            iconMC.addEventListener(MouseEvent.CLICK,showInviteAnswer);
         }
         if(array.length > 0)
         {
            LevelManager.iconLevel.addChild(iconMC);
         }
         else
         {
            iconMC.parent.removeChild(iconMC);
         }
      }
      
      private static function showInviteAnswer(param1:MouseEvent) : void
      {
         var sprite:Sprite = null;
         var data:InviteNoteInfo = null;
         var type:uint = 0;
         var event:MouseEvent = param1;
         data = null;
         type = 0;
         var str:String = null;
         var acceptInvite:Function = null;
         var rejectInvite:Function = null;
         acceptInvite = function():void
         {
            if(PetManager.length == 0)
            {
               Alarm.show("你还没有带上赛尔精灵，不能接受对战");
               return;
            }
            PetFightModel.mode = type;
            PetFightModel.enemyName = data.nickName;
            PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
            SocketConnection.send(CommandID.HANDLE_FIGHT_INVITE,data.userID,1,type);
         };
         rejectInvite = function():void
         {
            SocketConnection.send(CommandID.HANDLE_FIGHT_INVITE,data.userID,0,type);
         };
         data = next();
         type = data.mode;
         if(type == PetFightModel.SINGLE_MODE)
         {
            str = "精灵单挑";
         }
         else
         {
            str = "多精灵对战";
         }
         sprite = Answer.show("<a href=\'event:\'><font color=\'#ff0000\'>" + data.nickName + "(" + data.userID + ")</font></a> 邀请你进行赛尔精灵对战，你愿意接受吗？\r\r<font color=\'#ff0000\'>对战模式：" + str + "</font>",acceptInvite,rejectInvite);
         sprite.addEventListener(TextEvent.LINK,function():void
         {
            UserInfoController.show(data.userID);
            LevelManager.topLevel.addChild(UserInfoController.panel);
         });
      }
   }
}

