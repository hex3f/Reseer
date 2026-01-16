package com.robot.core.manager.bean
{
   import flash.events.Event;
   import org.taomee.manager.EventManager;
   
   public class BaseBeanController
   {
      
      public function BaseBeanController()
      {
         super();
      }
      
      public function start() : void
      {
      }
      
      protected function finish() : void
      {
         EventManager.dispatchEvent(new Event(BeanManager.BEAN_FINISH));
      }
   }
}

