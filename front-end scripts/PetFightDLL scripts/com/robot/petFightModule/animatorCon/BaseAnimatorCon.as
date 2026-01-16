package com.robot.petFightModule.animatorCon
{
   import com.robot.core.config.xml.*;
   import flash.display.MovieClip;
   import flash.events.*;
   import org.taomee.utils.*;
   
   public class BaseAnimatorCon extends AbstractAnimatorCon
   {
      
      public static var ON_MOVIE_OVER:String = "onMovieOver";
      
      public static var ON_MOVIE_HIT:String = "onMovieHit";
      
      private var skillMC:MovieClip;
      
      private var skillID:int;
      
      public function BaseAnimatorCon(param1:int, param2:MovieClip)
      {
         super();
         this.skillID = param1;
         this.skillMC = param2;
      }
      
      override public function getDescription() : String
      {
         return SkillXMLInfo.getName(this.skillID);
      }
      
      override public function destroy() : void
      {
         DisplayUtil.removeForParent(this.skillMC);
         this.skillMC.removeEventListener(Event.ENTER_FRAME,this.check);
         this.skillMC = null;
      }
      
      override public function playMovie() : void
      {
         this.skillMC.gotoAndPlay(2);
         this.skillMC.addEventListener(Event.ENTER_FRAME,this.check);
      }
      
      private function check(param1:Event) : void
      {
         if(this.skillMC.hit == 1)
         {
            dispatchEvent(new Event(ON_MOVIE_HIT));
            this.skillMC.hit = 0;
         }
         if(this.skillMC.isEnd == 1)
         {
            this.skillMC.removeEventListener(Event.ENTER_FRAME,this.check);
            this.skillMC.isEnd = 0;
            dispatchEvent(new Event(ON_MOVIE_OVER));
         }
      }
   }
}

