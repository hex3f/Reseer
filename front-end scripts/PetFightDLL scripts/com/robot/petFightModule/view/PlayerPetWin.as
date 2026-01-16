package com.robot.petFightModule.view
{
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.filters.*;
   import org.taomee.utils.*;
   
   public class PlayerPetWin extends BaseFighterPetWin
   {
      
      private var isOpened:Boolean = false;
      
      public function PlayerPetWin()
      {
         super();
      }
      
      override protected function setPetMC(param1:MovieClip) : void
      {
         DisplayUtil.removeAllChild(petContainer);
         param1.x = BaseFighterPetWin.WIN_WIDTH / 2;
         param1.y = 135;
         param1.gotoAndStop(1);
         param1.filters = [filte];
         if(this.isOpened)
         {
            petContainer.addChild(param1);
         }
         this._petMC = param1;
         this.createOpenning();
      }
      
      private function showNormal() : void
      {
         if(!openningMovie)
         {
            openningMovie = new OpenningMovie_mc();
            openningMovie.x = 42;
            openningMovie.y = -13;
         }
         petContainer.addChild(openningMovie);
         openningMovie.addEventListener(Event.ENTER_FRAME,function():void
         {
            if(!openningMovie)
            {
               return;
            }
            if(openningMovie.currentFrame == 45)
            {
               petContainer.addChild(petMC);
               petContainer.addChild(openningMovie);
            }
            else if(openningMovie.currentFrame == 85)
            {
               openningMovie.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(openningMovie);
               openningMovie = null;
               dispatchEvent(new PetFightEvent(PetFightEvent.ON_OPENNING));
            }
         });
      }
      
      override protected function initContainerPos() : void
      {
         petContainer.x = 90;
         petContainer.y = 115;
      }
      
      private function createOpenning() : void
      {
         if(this.isOpened)
         {
            return;
         }
         this.isOpened = true;
         this.showNormal();
      }
   }
}

