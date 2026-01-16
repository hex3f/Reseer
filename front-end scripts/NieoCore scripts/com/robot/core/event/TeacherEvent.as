package com.robot.core.event
{
   import com.robot.core.info.InformInfo;
   import flash.events.Event;
   
   public class TeacherEvent extends Event
   {
      
      public static const REQUEST_ME_AS_TEACHER:String = "requestMeAsTeacher";
      
      public static const REQUEST_TEACHER_HANDLED:String = "requestTeacherHandled";
      
      public static const REQUEST_ME_AS_STUDENT:String = "requestMeAsStudent";
      
      public static const REQUEST_STUDENT_HANDLED:String = "requestStudentHandled";
      
      public static const DELETE_AS_TEACHER:String = "deleteAsTeacher";
      
      public static const DELETE_AS_STUDENT:String = "deleteAsStudent";
      
      private var _info:InformInfo;
      
      public function TeacherEvent(param1:String, param2:InformInfo, param3:Boolean = false, param4:Boolean = false)
      {
         super(param1,param3,param4);
         this._info = param2;
      }
      
      public function get info() : InformInfo
      {
         return this._info;
      }
   }
}

