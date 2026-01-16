package com.robot.petFightModule.animatorCon
{
   import flash.events.Event;
   
   public class BaseAnimatorDecorator extends AbstractAnimatorCon
   {
      
      protected var animatorCon:AbstractAnimatorCon;
      
      public function BaseAnimatorDecorator(param1:AbstractAnimatorCon)
      {
         super();
         this.animatorCon = param1;
         this.animatorCon.addEventListener(BaseAnimatorCon.ON_MOVIE_OVER,this.onMovieOver);
         this.animatorCon.addEventListener(BaseAnimatorCon.ON_MOVIE_HIT,this.onMovieHit);
      }
      
      protected function effect() : void
      {
      }
      
      private function onMovieHit(param1:Event) : void
      {
         dispatchEvent(new Event(BaseAnimatorCon.ON_MOVIE_HIT));
      }
      
      private function onMovieOver(param1:Event) : void
      {
         this.effect();
         dispatchEvent(new Event(BaseAnimatorCon.ON_MOVIE_OVER));
      }
      
      override public function playMovie() : void
      {
         this.animatorCon.playMovie();
      }
   }
}

