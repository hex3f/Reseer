package com.robot.app.teacherAward
{
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.utils.IDataInput;
   
   public class TeacherAwardInfo
   {
      
      private var info_a:Array;
      
      public function TeacherAwardInfo(param1:IDataInput)
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         super();
         this.info_a = new Array();
         var _loc4_:uint = param1.readUnsignedInt();
         MainManager.actorInfo.graduationCount = _loc4_;
         var _loc5_:uint = param1.readUnsignedInt();
         if(_loc5_ > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc5_)
            {
               _loc3_ = param1.readUnsignedInt();
               this.info_a.push(_loc3_);
               _loc2_++;
            }
         }
         else if(_loc4_ == 0)
         {
            Alarm.show("你还没有培养出一个赛尔精英,加油");
         }
         else
         {
            Alarm.show("你已经培养了 " + _loc4_ + " 个精英赛尔");
         }
      }
      
      public function get getInfo() : Array
      {
         return this.info_a;
      }
   }
}

