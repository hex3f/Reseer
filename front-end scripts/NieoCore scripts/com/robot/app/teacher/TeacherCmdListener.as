package com.robot.app.teacher
{
   import com.robot.core.CommandID;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.event.TeacherEvent;
   import com.robot.core.info.InformInfo;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.RelationManager;
   import com.robot.core.manager.bean.BaseBeanController;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Answer;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class TeacherCmdListener extends BaseBeanController
   {
      
      private static var currentID:uint;
      
      public function TeacherCmdListener()
      {
         super();
      }
      
      override public function start() : void
      {
         SocketConnection.addCmdListener(CommandID.ANSWER_ADD_TEACHER,this.onAnswerTeacher);
         SocketConnection.addCmdListener(CommandID.ANSWER_ADD_STUDENT,this.onAnswerStudent);
         SocketConnection.addCmdListener(CommandID.DELETE_STUDENT,this.onDelStudent);
         SocketConnection.addCmdListener(CommandID.DELETE_TEACHER,this.onDelTeacher);
         EventManager.addEventListener(TeacherEvent.REQUEST_ME_AS_STUDENT,this.addMeAsStudent);
         EventManager.addEventListener(TeacherEvent.REQUEST_ME_AS_TEACHER,this.addMeAsTeacher);
         EventManager.addEventListener(TeacherEvent.REQUEST_STUDENT_HANDLED,this.onStudentRequest);
         EventManager.addEventListener(TeacherEvent.REQUEST_TEACHER_HANDLED,this.onTeacherRequest);
         EventManager.addEventListener(TeacherEvent.DELETE_AS_TEACHER,this.onDelteAsTeacher);
         EventManager.addEventListener(TeacherEvent.DELETE_AS_STUDENT,this.onDelteAsStudent);
         EventManager.addEventListener(RobotEvent.CREATED_MAP_USER,this.onCreatedMapUser);
         finish();
      }
      
      private function addMeAsStudent(param1:TeacherEvent) : void
      {
         var info:InformInfo = null;
         var event:TeacherEvent = param1;
         info = null;
         info = event.info;
         Answer.show("<font color=\'#ff0000\'>" + info.nick + "(" + info.userID + ")</font>希望做你的<font color=\'#FF0000\'>教官</font>，你同意吗？",function():void
         {
            SocketConnection.send(CommandID.ANSWER_ADD_STUDENT,info.userID,1);
            currentID = info.userID;
         },function():void
         {
            SocketConnection.send(CommandID.ANSWER_ADD_STUDENT,info.userID,0);
         });
      }
      
      private function addMeAsTeacher(param1:TeacherEvent) : void
      {
         var info:InformInfo = null;
         var event:TeacherEvent = param1;
         info = null;
         info = event.info;
         Answer.show("<font color=\'#ff0000\'>" + info.nick + "(" + info.userID + ")</font>希望做你的<font color=\'#FF0000\'>学员</font>，你同意吗？",function():void
         {
            SocketConnection.send(CommandID.ANSWER_ADD_TEACHER,info.userID,1);
            currentID = info.userID;
         },function():void
         {
            SocketConnection.send(CommandID.ANSWER_ADD_TEACHER,info.userID,0);
         });
      }
      
      private function onAnswerTeacher(param1:SocketEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         if(_loc4_ == 1)
         {
            MainManager.actorInfo.studentID = currentID;
            Alarm.show("恭喜你，你现在有了一名学员，你要尽快帮助他熟悉赛尔号哦！");
            _loc2_ = new UserInfo();
            _loc2_.userID = currentID;
            RelationManager.addFriendInfo(_loc2_);
            RelationManager.upDateInfo(currentID);
            RelationManager.setOnLineFriend();
            TeacherSysManager.updateAfterAdd();
         }
      }
      
      private function onAnswerStudent(param1:SocketEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:ByteArray = param1.data as ByteArray;
         var _loc4_:uint = _loc3_.readUnsignedInt();
         if(_loc4_ == 1)
         {
            MainManager.actorInfo.teacherID = currentID;
            Alarm.show("恭喜你，你现在有了一名教官，有什么问题你可以向他咨询哦！");
            _loc2_ = new UserInfo();
            _loc2_.userID = currentID;
            RelationManager.addFriendInfo(_loc2_);
            RelationManager.upDateInfo(currentID);
            RelationManager.setOnLineFriend();
            TeacherSysManager.updateAfterAdd();
         }
      }
      
      private function onStudentRequest(param1:TeacherEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:InformInfo = param1.info;
         if(_loc3_.accept == 0)
         {
            Alarm.show("很遗憾，<font color=\'#ff0000\'>" + _loc3_.nick + "(" + _loc3_.userID + ")</font>现在还不想做你的学员！");
         }
         else
         {
            Alarm.show("恭喜你，对方同意了你的请求，已经是你的学员了！你要好好照顾他哦！");
            MainManager.actorInfo.studentID = _loc3_.userID;
            _loc2_ = new UserInfo();
            _loc2_.userID = _loc3_.userID;
            RelationManager.addFriendInfo(_loc2_);
            RelationManager.upDateInfo(_loc3_.userID);
            RelationManager.setOnLineFriend();
            TeacherSysManager.updateAfterAdd();
         }
      }
      
      private function onTeacherRequest(param1:TeacherEvent) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:InformInfo = param1.info;
         if(_loc3_.accept == 0)
         {
            Alarm.show("很遗憾，<font color=\'#ff0000\'>" + _loc3_.nick + "(" + _loc3_.userID + ")</font>现在还不想做你的教官！");
         }
         else
         {
            Alarm.show("恭喜你，对方同意了你的请求，已经是你的教官了！加油哦！");
            MainManager.actorInfo.teacherID = _loc3_.userID;
            _loc2_ = new UserInfo();
            _loc2_.userID = _loc3_.userID;
            RelationManager.addFriendInfo(_loc2_);
            RelationManager.upDateInfo(_loc3_.userID);
            RelationManager.setOnLineFriend();
            TeacherSysManager.updateAfterAdd();
         }
      }
      
      private function onDelStudent(param1:SocketEvent) : void
      {
         TeacherSysManager.updateAfterDel();
         Alarm.show("你已经和你的学员解除了关系！");
         RelationManager.upDateInfo(MainManager.actorInfo.studentID);
         MainManager.actorInfo.studentID = 0;
         RelationManager.setOnLineFriend();
      }
      
      private function onDelTeacher(param1:SocketEvent) : void
      {
         TeacherSysManager.updateAfterDel();
         Alarm.show("你已经和你的教官解除了关系！");
         RelationManager.upDateInfo(MainManager.actorInfo.teacherID);
         MainManager.actorInfo.teacherID = 0;
         RelationManager.setOnLineFriend();
      }
      
      private function onDelteAsTeacher(param1:TeacherEvent) : void
      {
         TeacherSysManager.updateAfterDel();
         var _loc2_:InformInfo = param1.info;
         if(_loc2_.accept == 2)
         {
            Alarm.show("你的学员<font color=\'#ff0000\'>" + _loc2_.nick + "(" + _loc2_.userID + ")</font>已经和你解除了关系！");
         }
         else if(_loc2_.accept == 3)
         {
            MainManager.actorInfo.graduationCount += 1;
            Alarm.show("恭喜你，你的学员<font color=\'#ff0000\'>" + _loc2_.nick + "(" + _loc2_.userID + ")</font>已经可以独挡一面了，你可以招收新的学员。");
         }
         MainManager.actorInfo.studentID = 0;
         RelationManager.upDateInfo(_loc2_.userID);
         RelationManager.setOnLineFriend();
      }
      
      private function onDelteAsStudent(param1:TeacherEvent) : void
      {
         TeacherSysManager.updateAfterDel();
         var _loc2_:InformInfo = param1.info;
         Alarm.show("你的教官<font color=\'#ff0000\'>" + _loc2_.nick + "(" + _loc2_.userID + ")</font>已经和你解除了关系！");
         MainManager.actorInfo.teacherID = 0;
         RelationManager.upDateInfo(_loc2_.userID);
         RelationManager.setOnLineFriend();
      }
      
      private function onCreatedMapUser(param1:RobotEvent) : void
      {
         TeacherSysManager.checkMapUser();
      }
   }
}

