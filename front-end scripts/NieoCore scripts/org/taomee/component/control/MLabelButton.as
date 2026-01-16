package org.taomee.component.control
{
   import flash.display.MovieClip;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class MLabelButton extends MButton
   {
      
      private var _outColor:uint = 52223;
      
      private var _bgPressAlpha:Number = 0;
      
      private var _bgPressColor:uint;
      
      private var _bgOverAlpha:Number = 0;
      
      private var _bgOverColor:uint;
      
      private var _underLine:Boolean = false;
      
      private var _overColor:uint = 16763904;
      
      private var _bgOutAlpha:Number = 0;
      
      private var _bgOutColor:uint;
      
      public function MLabelButton(param1:String = "Button")
      {
         super(param1);
         offSetY = 0;
      }
      
      override protected function press() : void
      {
         super.press();
         _label.textColor = this._overColor;
         this.drawPressBg();
      }
      
      private function drawPressBg() : void
      {
         bg.graphics.clear();
         bg.graphics.beginFill(this._bgPressColor,this._bgPressAlpha);
         bg.graphics.drawRect(0,0,1,1);
         bg.graphics.endFill();
      }
      
      override protected function release() : void
      {
         super.release();
         _label.textColor = this._overColor;
         this.drawOverBg();
      }
      
      private function drawOutBg() : void
      {
         bg.graphics.clear();
         bg.graphics.beginFill(this._bgOutColor,this._bgOutAlpha);
         bg.graphics.drawRect(0,0,1,1);
         bg.graphics.endFill();
      }
      
      public function setBgColors(param1:uint, param2:uint, param3:uint, param4:Number = 0.5, param5:Number = 0.5, param6:Number = 0.5) : void
      {
         this._bgOverColor = param1;
         this._bgOutColor = param2;
         this._bgPressColor = param3;
         this._bgOverAlpha = param4;
         this._bgOutAlpha = param5;
         this._bgPressAlpha = param6;
         this.drawOutBg();
      }
      
      public function set underLine(param1:Boolean) : void
      {
         this._underLine = param1;
         var _loc2_:TextFormat = _label.textFormat;
         _loc2_.underline = param1;
         _label.textField.setTextFormat(_loc2_);
      }
      
      override protected function mouseOver() : void
      {
         super.mouseOver();
         _label.textColor = this._overColor;
         this.drawOverBg();
      }
      
      private function drawOverBg() : void
      {
         bg.graphics.clear();
         bg.graphics.beginFill(this._bgOverColor,this._bgOverAlpha);
         bg.graphics.drawRect(0,0,1,1);
         bg.graphics.endFill();
      }
      
      public function set overColor(param1:uint) : void
      {
         this._overColor = param1;
      }
      
      override protected function releaseOutside() : void
      {
         super.releaseOutside();
         _label.textColor = this._outColor;
         this.drawOutBg();
      }
      
      override protected function mouseOut() : void
      {
         super.mouseOut();
         _label.textColor = this._outColor;
         this.drawOutBg();
      }
      
      public function set outColor(param1:uint) : void
      {
         this._outColor = param1;
         label.textColor = this._outColor;
      }
      
      override protected function initUI() : void
      {
         bg = new MovieClip();
         bg.mouseEnabled = false;
         this.drawOutBg();
         addChild(bg);
         _label.align = TextFormatAlign.LEFT;
         addChild(_label);
         width = label.width;
         height = label.height;
         label.textColor = this._outColor;
      }
   }
}

