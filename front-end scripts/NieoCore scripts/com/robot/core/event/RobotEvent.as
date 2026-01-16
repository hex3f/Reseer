package com.robot.core.event
{
   import flash.events.Event;
   
   public class RobotEvent extends Event
   {
      
      public static const EXIT_FRAME:String = "exitFrame";
      
      public static const FRAME_CONSTRUCTED:String = "frameConstructed";
      
      public static const LOGIN_SUCCESS:String = "loginSuccess";
      
      public static const BEAN_COMPLETE:String = "beanComplete";
      
      public static const CLOSE_LOADING:String = "closeLoading";
      
      public static const CREATED_ACTOR:String = "createdActor";
      
      public static const FILTER_SUPER_TEAM:String = "filterSuperTeam";
      
      public static const CREATED_MAP_USER:String = "createdMapUser";
      
      public static const LEAVE_ROOM:String = "leaveRoom";
      
      public static const ENTER_ROOM:String = "enterRoom";
      
      public static const GET_ROOM_ADDRES:String = "getRoomAddres";
      
      public static const OGRE_CLICK:String = "ogreClick";
      
      public static const CHANGE_DIRECTION:String = "changeDirection";
      
      public static const WALK_START:String = "walkStart";
      
      public static const WALK_END:String = "walkEnd";
      
      public static const WALK_ENTER_FRAME:String = "walkEnterFrame";
      
      public static const STORAGE_OPEN:String = "storageOpen";
      
      public static const STORAGE_CLOSE:String = "storageClose";
      
      public static const NO_PET_CAN_FIGHT:String = "noPetCanFight";
      
      public static const MESSAGE:String = "message";
      
      public static const ADD_FRIEND_MSG:String = "add_friend_msg";
      
      public static const ANSWER_FRIEND_MSG:String = "answer_friend_msg";
      
      public static const REMOVE_FRIEND_MSG:String = "remove_friend_msg";
      
      public static const ADD_TEAM_MSG:String = "add_team_msg";
      
      public static const CLOSE_FIGHT_WAIT:String = "closeFightWait";
      
      public static const CUT_BMP:String = "cutBmp";
      
      public static const DAILY_TASK_COMPLETE:String = "dailyTaskComplete";
      
      public static const NONO_SHORTCUT_HIDE:String = "nonoShortcutHide";
      
      public static const SPEEDUP_CHANGE:String = "speedupChange";
      
      public static const AUTO_FIGHT_CHANGE:String = "autoFightChange";
      
      public static const ENERGY_TIMES_CHANGE:String = "energyTimesChange";
      
      public static const STUDY_TIMES_CHANGE:String = "studyTimesChange";
      
      public static const ERROR_11027:String = "error11027";
      
      public static const ERROR_11028:String = "error11028";
      
      public static const ERROR_103303:String = "error103303";
      
      public static const TRANSFORM_START:String = "transformStart";
      
      public static const TRANSFORM_OVER:String = "transformOver";
      
      public static const MONEY_BUY:String = "moneybuy";
      
      public function RobotEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

