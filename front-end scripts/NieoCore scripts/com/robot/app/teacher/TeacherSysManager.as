package com.robot.app.teacher
{
   import com.robot.app.teacherAward.SevenNoLoginInfo;
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.PeopleModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Answer;
   import flash.display.Sprite;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.ArrayUtil;
   import org.taomee.utils.DisplayUtil;
   
   public class TeacherSysManager
   {
      
      private static var sprite:Sprite;
      
      public function TeacherSysManager()
      {
         super();
      }
      
      public static function hideSendTip() : void
      {
         DisplayUtil.removeForParent(sprite);
         sprite = null;
      }
      
      public static function addTeacher(param1:uint) : void
      {
         sprite = Alarm.show("申请已发送，请耐心等待对方的答复！");
         SocketConnection.send(CommandID.REQUEST_ADD_TEACHER,param1);
      }
      
      public static function addStudent(param1:uint) : void
      {
         sprite = Alarm.show("申请已发送，请耐心等待对方的答复！");
         SocketConnection.send(CommandID.REQUEST_ADD_STUDENT,param1);
      }
      
      public static function delTeacher() : void
      {
         Answer.show("你确定要和你的教官解除关系吗？",function():void
         {
            SocketConnection.send(CommandID.DELETE_TEACHER);
         });
      }
      
      public static function delStudent() : void
      {
         SocketConnection.send(CommandID.SEVENNOLOGIN_COMPLETE);
         SocketConnection.addCmdListener(CommandID.SEVENNOLOGIN_COMPLETE,onCompleteHandler);
      }
      
      private static function onCompleteHandler(param1:SocketEvent) : void
      {
         var data:SevenNoLoginInfo = null;
         var e:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.SEVENNOLOGIN_COMPLETE,onCompleteHandler);
         data = e.data as SevenNoLoginInfo;
         if(data.getStatus == 0)
         {
            Answer.show("你确定要和你的学员解除关系吗？教官主动解除需要<font color=\'#ff0000\'>支付200赛尔豆</font>哦！",function():void
            {
               SocketConnection.send(CommandID.DELETE_STUDENT);
               if(MainManager.actorInfo.coins > 200)
               {
                  MainManager.actorInfo.coins -= 200;
               }
               else
               {
                  MainManager.actorInfo.coins = 0;
               }
            });
            return;
         }
         if(data.getStatus == 1)
         {
            Answer.show("由于你的学员连续7天没登陆飞船，你可以免费解除关系。",function():void
            {
               SocketConnection.send(CommandID.DELETE_STUDENT);
            });
         }
      }
      
      public static function checkMapUser() : void
      {
         var _loc1_:PeopleModel = null;
         var _loc2_:BasePeoleModel = null;
         var _loc3_:Array = UserManager.getUserModelList();
         var _loc4_:Array = [];
         for each(_loc1_ in _loc3_)
         {
            _loc4_.push(_loc1_.info.userID);
         }
         for each(_loc1_ in _loc3_)
         {
            if(ArrayUtil.arrayContainsValue(_loc4_,_loc1_.info.teacherID))
            {
               _loc2_ = UserManager.getUserModel(_loc1_.info.teacherID);
               _loc2_.addProtectMC();
               _loc1_.addProtectMC();
            }
            else if(ArrayUtil.arrayContainsValue(_loc4_,_loc1_.info.studentID))
            {
               _loc2_ = UserManager.getUserModel(_loc1_.info.studentID);
               _loc2_.addProtectMC();
               _loc1_.addProtectMC();
            }
            if(_loc1_.info.teacherID == MainManager.actorID || _loc1_.info.studentID == MainManager.actorID)
            {
               MainManager.actorModel.addProtectMC();
               _loc1_.addProtectMC();
            }
         }
      }
      
      public static function updateAfterDel() : void
      {
         var _loc1_:BasePeoleModel = null;
         var _loc2_:* = 0;
         var _loc3_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = uint(_loc1_.info.userID);
            if(_loc2_ == MainManager.actorInfo.teacherID || _loc2_ == MainManager.actorInfo.studentID)
            {
               _loc1_.delProtectMC();
            }
         }
         MainManager.actorModel.delProtectMC();
      }
      
      public static function updateAfterAdd() : void
      {
         var _loc1_:BasePeoleModel = null;
         var _loc2_:* = 0;
         var _loc3_:Array = UserManager.getUserModelList();
         for each(_loc1_ in _loc3_)
         {
            _loc2_ = uint(_loc1_.info.userID);
            if(_loc2_ == MainManager.actorInfo.teacherID || _loc2_ == MainManager.actorInfo.studentID)
            {
               MainManager.actorModel.addProtectMC();
               _loc1_.addProtectMC();
            }
         }
      }
   }
}

