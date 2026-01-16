package com.robot.core.event
{
   import flash.events.Event;
   
   public class MailEvent extends Event
   {
      
      public static const MAIL_LIST:String = "mailList";
      
      public static const MAIL_DELETE:String = "mailDelete";
      
      public static const MAIL_CLEAR:String = "mailClear";
      
      public static const MAIL_SEND:String = "mailSend";
      
      public function MailEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}

