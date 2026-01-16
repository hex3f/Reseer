package com.robot.app.emotion
{
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public class EmotionListItem extends Sprite
   {
      
      public var id:int;
      
      private var _bgMc:MovieClip;
      
      private var _eMc:MovieClip;
      
      public function EmotionListItem(param1:int)
      {
         super();
         this.id = param1;
         mouseChildren = false;
         buttonMode = true;
         this._bgMc = UIManager.getMovieClip("EmotionMC");
         this._bgMc.gotoAndStop(1);
         addChild(this._bgMc);
         this._eMc = UIManager.getMovieClip("e" + this.id.toString());
         this._eMc.x = this._bgMc.width / 2;
         this._eMc.y = this._bgMc.height / 2;
         this._eMc.gotoAndStop(1);
         addChild(this._eMc);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
      }
      
      public function onOver(param1:MouseEvent) : void
      {
         this._bgMc.gotoAndStop(2);
         this._eMc.play();
      }
      
      public function onOut(param1:MouseEvent) : void
      {
         this._bgMc.gotoAndStop(1);
         this._eMc.gotoAndStop(1);
      }
   }
}

