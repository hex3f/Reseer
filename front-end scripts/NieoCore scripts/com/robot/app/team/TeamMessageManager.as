package com.robot.app.team
{
   import com.robot.app.user.UserInfoController;
   import com.robot.core.CommandID;
   import com.robot.core.info.team.TeamInformInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Answer;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.Sprite;
   import flash.events.TextEvent;
   
   public class TeamMessageManager
   {
      
      public function TeamMessageManager()
      {
         super();
      }
      
      public static function show(param1:TeamInformInfo) : void
      {
         var info:TeamInformInfo = param1;
         var sprite:Sprite = null;
         var type:uint = uint(info.type);
         switch(type)
         {
            case CommandID.TEAM_ANSWER:
               if(info.data1 == 0)
               {
                  Alarm.show("很遗憾，你申请加入战队的申请被拒绝了");
                  break;
               }
               Alarm.show("你的申请已经通过，恭喜你成功加入战队");
               MainManager.actorInfo.teamInfo.id = info.data2;
               MainManager.actorInfo.teamInfo.priv = 5;
               break;
            case CommandID.TEAM_CHANGE_ADMIN:
               Alarm.show("你的级别被调整为：" + TextFormatUtil.getRedTxt(TeamController.ADMIN_STR[info.data1]));
               MainManager.actorInfo.teamInfo.priv = info.data1;
               break;
            case CommandID.TEAM_DELET_MEMBER:
               Alarm.show("你已经被移出战队了");
               MainManager.actorInfo.teamInfo.id = 0;
               break;
            case CommandID.TEAM_INVITE_TO_JOIN:
               sprite = Answer.show(TextFormatUtil.getEventTxt(info.nick + "(" + info.userID + ")",info.userID.toString()) + "邀请你加入他的战队，你愿意吗？",function():void
               {
                  TeamController.join(info.data2);
               });
               sprite.addEventListener(TextEvent.LINK,function(param1:TextEvent):void
               {
                  UserInfoController.show(uint(param1.text));
                  LevelManager.topLevel.addChild(UserInfoController.panel);
               });
         }
      }
   }
}

