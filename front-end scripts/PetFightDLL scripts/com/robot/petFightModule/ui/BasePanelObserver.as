package com.robot.petFightModule.ui
{
   import flash.display.Sprite;
   
   public class BasePanelObserver extends Sprite
   {
      
      protected var subject:FightToolSubject;
      
      public function BasePanelObserver(param1:FightToolSubject)
      {
         super();
         this.subject = param1;
         this.subject.registe(this);
      }
      
      public function destroy() : void
      {
         this.subject = null;
      }
   }
}

