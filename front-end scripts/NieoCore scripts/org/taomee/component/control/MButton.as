package org.taomee.component.control
{
   import com.robot.core.manager.AssetsManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextFormatAlign;
   import org.taomee.component.UIComponent;
   import org.taomee.component.event.ButtonEvent;
   import org.taomee.component.manager.MComponentManager;
   
   [Event(name="onRollOut",type="org.taomee.component.event.ButtonEvent")]
   [Event(name="onRollOver",type="org.taomee.component.event.ButtonEvent")]
   [Event(name="press",type="org.taomee.component.event.ButtonEvent")]
   [Event(name="release",type="org.taomee.component.event.ButtonEvent")]
   [Event(name="releaseOutside",type="org.taomee.component.event.ButtonEvent")]
   public class MButton extends UIComponent
   {
      
      protected var bg:MovieClip;
      
      protected var offSetY:uint = 1;
      
      private var defaultFilterColor:uint = 676248;
      
      private var oldY:Number;
      
      protected var isDown:Boolean = false;
      
      private var bgClass:Class = AssetsManager.getClass("org.taomee.component.control.MButton_bgClass");
      
      protected var _label:MLabel;
      
      private var defaultTxtColor:uint = 16777215;
      
      public function MButton(param1:String = "Button")
      {
         super();
         this.mouseChildren = false;
         this._label = new MLabel(param1);
         this._label.mouseEnabled = this._label.mouseChildren = false;
         this.initUI();
         this.initHandler();
      }
      
      protected function press() : void
      {
         this._label.y = this.oldY;
         this.bg.gotoAndStop(3);
         dispatchEvent(new ButtonEvent(ButtonEvent.PRESS));
      }
      
      protected function release() : void
      {
         this._label.y = this.oldY - this.offSetY;
         this.bg.gotoAndStop(2);
         dispatchEvent(new ButtonEvent(ButtonEvent.RELEASE));
      }
      
      private function downHandler(param1:MouseEvent) : void
      {
         this.isDown = true;
         this.press();
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         this.label.width = param1;
         this.bg.width = param1;
      }
      
      override public function set height(param1:Number) : void
      {
         super.height = param1;
         this.label.y = (height - this.label.height) / 2;
         this.bg.height = param1;
         this.oldY = this.label.y;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         if(this.isDown)
         {
            this.press();
         }
         else
         {
            this.mouseOver();
         }
      }
      
      protected function mouseOver() : void
      {
         this._label.y = this.oldY - this.offSetY;
         this.bg.gotoAndStop(2);
         dispatchEvent(new ButtonEvent(ButtonEvent.ON_ROLL_OVER));
      }
      
      public function set text(param1:String) : void
      {
         this._label.text = param1;
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         if(this.isDown)
         {
            this.mouseOver();
         }
         else
         {
            this.mouseOut();
         }
      }
      
      protected function releaseOutside() : void
      {
         this._label.y = this.oldY;
         this.bg.gotoAndStop(1);
         dispatchEvent(new ButtonEvent(ButtonEvent.RELEASE_OUTSIDE));
      }
      
      private function stageUpHandler(param1:MouseEvent) : void
      {
         if(this.isDown)
         {
            this.releaseOutside();
         }
         this.isDown = false;
      }
      
      private function initHandler() : void
      {
         this.addEventListener(MouseEvent.MOUSE_OVER,this.overHandler);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.outHandler);
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.downHandler);
         this.addEventListener(MouseEvent.MOUSE_UP,this.upHandler);
         MComponentManager.stage.addEventListener(MouseEvent.MOUSE_UP,this.stageUpHandler);
      }
      
      protected function mouseOut() : void
      {
         this._label.y = this.oldY;
         this.bg.gotoAndStop(1);
         dispatchEvent(new ButtonEvent(ButtonEvent.ON_ROLL_OUT));
      }
      
      protected function initUI() : void
      {
         this.bg = new this.bgClass();
         this.bg.gotoAndStop(1);
         addChild(this.bg);
         this._label.blod = true;
         this._label.align = TextFormatAlign.CENTER;
         this.label.textField.filters = [new GlowFilter(this.defaultFilterColor,0.8,4,4,10)];
         addChild(this._label);
         this.width = 65;
         this.height = 30;
         if(this._label.width > 45)
         {
            this.width = this._label.width + 20;
         }
         if(this._label.height > 26)
         {
            this.height = this._label.height + 4;
         }
         this.label.textColor = this.defaultTxtColor;
      }
      
      private function upHandler(param1:MouseEvent) : void
      {
         if(this.isDown)
         {
            this.release();
         }
         this.isDown = false;
      }
      
      public function get label() : MLabel
      {
         return this._label;
      }
   }
}

