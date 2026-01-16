package com.robot.core.effect
{
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class GlowTween
   {
      
      private var _target:InteractiveObject;
      
      private var _color:uint;
      
      private var _toggle:Boolean;
      
      private var _blur:Number;
      
      public function GlowTween(param1:InteractiveObject, param2:uint = 16777215, param3:Boolean = false)
      {
         super();
         this._target = param1;
         this._color = param2;
         this._toggle = true;
         this._blur = 2;
         if(param3)
         {
            this.startGlowHandler();
         }
         else
         {
            param1.addEventListener(MouseEvent.ROLL_OVER,this.startGlowHandler);
            param1.addEventListener(MouseEvent.ROLL_OUT,this.stopGlowHandler);
         }
      }
      
      public function remove() : void
      {
         this._target.removeEventListener(MouseEvent.ROLL_OVER,this.startGlowHandler);
         this._target.removeEventListener(MouseEvent.ROLL_OUT,this.stopGlowHandler);
         this._target.removeEventListener(Event.ENTER_FRAME,this.blinkHandler);
         this._target.filters = null;
         this._target = null;
      }
      
      public function startGlowHandler(param1:MouseEvent = null) : void
      {
         this._target.addEventListener(Event.ENTER_FRAME,this.blinkHandler,false,0,true);
      }
      
      public function stopGlowHandler(param1:MouseEvent = null) : void
      {
         this._target.removeEventListener(Event.ENTER_FRAME,this.blinkHandler);
         this._target.filters = null;
      }
      
      private function blinkHandler(param1:Event) : void
      {
         if(this._blur >= 30)
         {
            this._toggle = false;
         }
         else if(this._blur <= 2)
         {
            this._toggle = true;
         }
         if(this._toggle)
         {
            ++this._blur;
         }
         else
         {
            --this._blur;
         }
         var _loc2_:GlowFilter = new GlowFilter(this._color,1,this._blur,this._blur,2,2);
         this._target.filters = [_loc2_];
      }
   }
}

