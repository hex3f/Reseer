package com.oaxoa.fx
{
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class Lightning extends Sprite
   {
      
      private const SMOOTH_COLOR:uint = 8421504;
      
      private var holder:Sprite;
      
      private var sbd:BitmapData;
      
      private var bbd:BitmapData;
      
      private var soffs:Array;
      
      private var boffs:Array;
      
      private var glow:GlowFilter;
      
      public var lifeSpan:Number;
      
      private var lifeTimer:Timer;
      
      public var startX:Number;
      
      public var startY:Number;
      
      public var endX:Number;
      
      public var endY:Number;
      
      public var len:Number;
      
      public var multi:Number;
      
      public var multi2:Number;
      
      public var _steps:uint;
      
      public var stepEvery:Number;
      
      private var seed1:uint;
      
      private var seed2:uint;
      
      public var smooth:Sprite;
      
      public var childrenSmooth:Sprite;
      
      public var childrenArray:Array = [];
      
      public var _smoothPercentage:uint = 50;
      
      public var _childrenSmoothPercentage:uint;
      
      public var _color:uint;
      
      private var generation:uint;
      
      private var _childrenMaxGenerations:uint = 3;
      
      private var _childrenProbability:Number = 0.025;
      
      private var _childrenProbabilityDecay:Number = 0;
      
      private var _childrenMaxCount:uint = 4;
      
      private var _childrenMaxCountDecay:Number = 0.5;
      
      private var _childrenLengthDecay:Number = 0;
      
      private var _childrenAngleVariation:Number = 60;
      
      private var _childrenLifeSpanMin:Number = 0;
      
      private var _childrenLifeSpanMax:Number = 0;
      
      private var _childrenDetachedEnd:Boolean = false;
      
      private var _maxLength:Number = 0;
      
      private var _maxLengthVary:Number = 0;
      
      public var _isVisible:Boolean = true;
      
      public var _alphaFade:Boolean = true;
      
      public var parentInstance:Lightning;
      
      private var _thickness:Number;
      
      private var _thicknessDecay:Number;
      
      private var initialized:Boolean = false;
      
      private var _wavelength:Number = 0.3;
      
      private var _amplitude:Number = 0.5;
      
      private var _speed:Number = 1;
      
      private var calculatedWavelength:Number;
      
      private var calculatedSpeed:Number;
      
      public var alphaFadeType:String;
      
      public var thicknessFadeType:String;
      
      private var position:Number = 0;
      
      private var absolutePosition:Number = 1;
      
      private var dx:Number;
      
      private var dy:Number;
      
      private var soff:Number;
      
      private var soffx:Number;
      
      private var soffy:Number;
      
      private var boff:Number;
      
      private var boffx:Number;
      
      private var boffy:Number;
      
      private var angle:Number;
      
      private var tx:Number;
      
      private var ty:Number;
      
      public function Lightning(param1:uint = 16777215, param2:Number = 2, param3:uint = 0)
      {
         super();
         mouseEnabled = false;
         this._color = param1;
         this._thickness = param2;
         this.alphaFadeType = LightningFadeType.GENERATION;
         this.thicknessFadeType = LightningFadeType.NONE;
         this.generation = param3;
         if(this.generation == 0)
         {
            this.init();
         }
      }
      
      private function init() : void
      {
         this.randomizeSeeds();
         if(this.lifeSpan > 0)
         {
            this.startLifeTimer();
         }
         this.multi2 = 0.03;
         this.holder = new Sprite();
         this.holder.mouseEnabled = false;
         this.startX = 50;
         this.startY = 200;
         this.endX = 50;
         this.endY = 600;
         this.stepEvery = 4;
         this._steps = 50;
         this.sbd = new BitmapData(this._steps,1,false);
         this.bbd = new BitmapData(this._steps,1,false);
         this.soffs = [new Point(0,0),new Point(0,0)];
         this.boffs = [new Point(0,0),new Point(0,0)];
         if(this.generation == 0)
         {
            this.smooth = new Sprite();
            this.childrenSmooth = new Sprite();
            this.smoothPercentage = 50;
            this.childrenSmoothPercentage = 50;
         }
         else
         {
            this.smooth = this.childrenSmooth = this.parentInstance.childrenSmooth;
         }
         this.steps = 100;
         this.childrenLengthDecay = 0.5;
         addChild(this.holder);
         this.initialized = true;
      }
      
      private function randomizeSeeds() : void
      {
         this.seed1 = Math.random() * 100;
         this.seed2 = Math.random() * 100;
      }
      
      public function set steps(param1:uint) : void
      {
         if(param1 < 2)
         {
            param1 = 2;
         }
         if(param1 > 2880)
         {
            param1 = 2880;
         }
         this._steps = param1;
         this.sbd = new BitmapData(this._steps,1,false);
         this.bbd = new BitmapData(this._steps,1,false);
         if(this.generation == 0)
         {
            this.smoothPercentage = this.smoothPercentage;
         }
      }
      
      public function get steps() : uint
      {
         return this._steps;
      }
      
      public function startLifeTimer() : void
      {
         this.lifeTimer = new Timer(this.lifeSpan * 1000,1);
         this.lifeTimer.start();
         this.lifeTimer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         this.kill();
      }
      
      public function kill() : void
      {
         var _loc1_:Number = 0;
         var _loc2_:Lightning = null;
         var _loc3_:Object = null;
         this.killAllChildren();
         if(Boolean(this.lifeTimer))
         {
            this.lifeTimer.removeEventListener(TimerEvent.TIMER,this.kill);
            this.lifeTimer.stop();
         }
         if(this.parentInstance != null)
         {
            _loc1_ = 0;
            _loc2_ = this.parent as Lightning;
            for each(_loc3_ in _loc2_.childrenArray)
            {
               if(_loc3_.instance == this)
               {
                  _loc2_.childrenArray.splice(_loc1_,1);
               }
               _loc1_++;
            }
         }
         this.parent.removeChild(this);
      }
      
      public function killAllChildren() : void
      {
         var _loc1_:Lightning = null;
         while(this.childrenArray.length > 0)
         {
            _loc1_ = this.childrenArray[0].instance;
            _loc1_.kill();
         }
      }
      
      public function generateChild(param1:uint = 1, param2:Boolean = false) : void
      {
         var _loc3_:* = 0;
         var _loc4_:Number = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:Number = NaN;
         var _loc8_:Lightning = null;
         if(this.generation < this.childrenMaxGenerations && this.childrenArray.length < this.childrenMaxCount)
         {
            _loc3_ = this.steps * this.childrenLengthDecay;
            if(_loc3_ >= 2)
            {
               _loc4_ = 0;
               while(_loc4_ < param1)
               {
                  _loc5_ = Math.random() * this.steps;
                  _loc6_ = Math.random() * this.steps;
                  while(_loc6_ == _loc5_)
                  {
                     _loc6_ = Math.random() * this.steps;
                  }
                  _loc7_ = Math.random() * this.childrenAngleVariation - this.childrenAngleVariation / 2;
                  _loc8_ = new Lightning(this.color,this.thickness,this.generation + 1);
                  _loc8_.parentInstance = this;
                  _loc8_.lifeSpan = Math.random() * (this.childrenLifeSpanMax - this.childrenLifeSpanMin) + this.childrenLifeSpanMin;
                  _loc8_.position = 1 - _loc5_ / this.steps;
                  _loc8_.absolutePosition = this.absolutePosition * _loc8_.position;
                  _loc8_.alphaFadeType = this.alphaFadeType;
                  _loc8_.thicknessFadeType = this.thicknessFadeType;
                  if(this.alphaFadeType == LightningFadeType.GENERATION)
                  {
                     _loc8_.alpha = 1 - 1 / (this.childrenMaxGenerations + 1) * _loc8_.generation;
                  }
                  if(this.thicknessFadeType == LightningFadeType.GENERATION)
                  {
                     _loc8_.thickness = this.thickness - this.thickness / (this.childrenMaxGenerations + 1) * _loc8_.generation;
                  }
                  _loc8_.childrenMaxGenerations = this.childrenMaxGenerations;
                  _loc8_.childrenMaxCount = this.childrenMaxCount * (1 - this.childrenMaxCountDecay);
                  _loc8_.childrenProbability = this.childrenProbability * (1 - this.childrenProbabilityDecay);
                  _loc8_.childrenProbabilityDecay = this.childrenProbabilityDecay;
                  _loc8_.childrenLengthDecay = this.childrenLengthDecay;
                  _loc8_.childrenDetachedEnd = this.childrenDetachedEnd;
                  _loc8_.wavelength = this.wavelength;
                  _loc8_.amplitude = this.amplitude;
                  _loc8_.speed = this.speed;
                  _loc8_.init();
                  this.childrenArray.push({
                     "instance":_loc8_,
                     "startStep":_loc5_,
                     "endStep":_loc6_,
                     "detachedEnd":this.childrenDetachedEnd,
                     "childAngle":_loc7_
                  });
                  addChild(_loc8_);
                  _loc8_.steps = this.steps * (1 - this.childrenLengthDecay);
                  if(param2)
                  {
                     _loc8_.generateChild(param1,true);
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      public function update() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Object = null;
         var _loc3_:Matrix = null;
         var _loc4_:Number = NaN;
         if(this.initialized)
         {
            this.dx = this.endX - this.startX;
            this.dy = this.endY - this.startY;
            this.len = Math.sqrt(this.dx * this.dx + this.dy * this.dy);
            this.soffs[0].x += this.steps / 100 * this.speed;
            this.soffs[0].y += this.steps / 100 * this.speed;
            this.sbd.perlinNoise(this.steps / 20,this.steps / 20,1,this.seed1,false,true,7,true,this.soffs);
            this.calculatedWavelength = this.steps * this.wavelength;
            this.calculatedSpeed = this.calculatedWavelength * 0.1 * this.speed;
            this.boffs[0].x -= this.calculatedSpeed;
            this.boffs[0].y += this.calculatedSpeed;
            this.bbd.perlinNoise(this.calculatedWavelength,this.calculatedWavelength,1,this.seed2,false,true,7,true,this.boffs);
            if(this.smoothPercentage > 0)
            {
               _loc3_ = new Matrix();
               _loc3_.scale(this.steps / this.smooth.width,1);
               this.bbd.draw(this.smooth,_loc3_);
            }
            if(this.parentInstance != null)
            {
               this.isVisible = this.parentInstance.isVisible;
            }
            else if(this.maxLength == 0)
            {
               this.isVisible = true;
            }
            else
            {
               if(this.len <= this.maxLength)
               {
                  _loc4_ = 1;
               }
               else if(this.len > this.maxLength + this.maxLengthVary)
               {
                  _loc4_ = 0;
               }
               else
               {
                  _loc4_ = 1 - (this.len - this.maxLength) / this.maxLengthVary;
               }
               this.isVisible = Math.random() < _loc4_ ? true : false;
            }
            _loc1_ = Math.random();
            if(_loc1_ < this.childrenProbability)
            {
               this.generateChild();
            }
            if(this.isVisible)
            {
               this.render();
            }
            for each(_loc2_ in this.childrenArray)
            {
               _loc2_.instance.update();
            }
         }
      }
      
      public function render() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         this.holder.graphics.clear();
         this.holder.graphics.lineStyle(this.thickness,this._color);
         this.angle = Math.atan2(this.endY - this.startY,this.endX - this.startX);
         var _loc7_:Number = 0;
         while(_loc7_ < this.steps)
         {
            _loc2_ = 1 / this.steps * (this.steps - _loc7_);
            _loc3_ = 1;
            _loc4_ = this.thickness;
            if(this.alphaFadeType == LightningFadeType.TIP_TO_END)
            {
               _loc3_ = this.absolutePosition * _loc2_;
            }
            if(this.thicknessFadeType == LightningFadeType.TIP_TO_END)
            {
               _loc4_ = this.thickness * (this.absolutePosition * _loc2_);
            }
            if(this.alphaFadeType == LightningFadeType.TIP_TO_END || this.thicknessFadeType == LightningFadeType.TIP_TO_END)
            {
               this.holder.graphics.lineStyle(int(_loc4_),this._color,_loc3_);
            }
            this.soff = (this.sbd.getPixel(_loc7_,0) - 8421504) / 16777215 * this.len * this.multi2;
            this.soffx = Math.sin(this.angle) * this.soff;
            this.soffy = Math.cos(this.angle) * this.soff;
            this.boff = (this.bbd.getPixel(_loc7_,0) - 8421504) / 16777215 * this.len * this.amplitude;
            this.boffx = Math.sin(this.angle) * this.boff;
            this.boffy = Math.cos(this.angle) * this.boff;
            this.tx = this.startX + this.dx / (this.steps - 1) * _loc7_ + this.soffx + this.boffx;
            this.ty = this.startY + this.dy / (this.steps - 1) * _loc7_ - this.soffy - this.boffy;
            if(_loc7_ == 0)
            {
               this.holder.graphics.moveTo(this.tx,this.ty);
            }
            this.holder.graphics.lineTo(this.tx,this.ty);
            for each(_loc1_ in this.childrenArray)
            {
               if(_loc1_.startStep == _loc7_)
               {
                  _loc1_.instance.startX = this.tx;
                  _loc1_.instance.startY = this.ty;
               }
               if(Boolean(_loc1_.detachedEnd))
               {
                  _loc5_ = this.angle + _loc1_.childAngle / 180 * Math.PI;
                  _loc6_ = this.len * this.childrenLengthDecay;
                  _loc1_.instance.endX = _loc1_.instance.startX + Math.cos(_loc5_) * _loc6_;
                  _loc1_.instance.endY = _loc1_.instance.startY + Math.sin(_loc5_) * _loc6_;
               }
               else if(_loc1_.endStep == _loc7_)
               {
                  _loc1_.instance.endX = this.tx;
                  _loc1_.instance.endY = this.ty;
               }
            }
            _loc7_++;
         }
      }
      
      public function killSurplus() : void
      {
         var _loc1_:Lightning = null;
         while(this.childrenArray.length > this.childrenMaxCount)
         {
            _loc1_ = this.childrenArray[this.childrenArray.length - 1].instance;
            _loc1_.kill();
         }
      }
      
      public function set smoothPercentage(param1:Number) : void
      {
         var _loc2_:Matrix = null;
         var _loc3_:* = 0;
         if(Boolean(this.smooth))
         {
            this._smoothPercentage = param1;
            _loc2_ = new Matrix();
            _loc2_.createGradientBox(this.steps,1);
            _loc3_ = this._smoothPercentage / 100 * 128;
            this.smooth.graphics.clear();
            this.smooth.graphics.beginGradientFill("linear",[this.SMOOTH_COLOR,this.SMOOTH_COLOR,this.SMOOTH_COLOR,this.SMOOTH_COLOR],[1,0,0,1],[0,_loc3_,255 - _loc3_,255],_loc2_);
            this.smooth.graphics.drawRect(0,0,this.steps,1);
            this.smooth.graphics.endFill();
         }
      }
      
      public function set childrenSmoothPercentage(param1:Number) : void
      {
         this._childrenSmoothPercentage = param1;
         var _loc2_:Matrix = new Matrix();
         _loc2_.createGradientBox(this.steps,1);
         var _loc3_:uint = this._childrenSmoothPercentage / 100 * 128;
         this.childrenSmooth.graphics.clear();
         this.childrenSmooth.graphics.beginGradientFill("linear",[this.SMOOTH_COLOR,this.SMOOTH_COLOR,this.SMOOTH_COLOR,this.SMOOTH_COLOR],[1,0,0,1],[0,_loc3_,255 - _loc3_,255],_loc2_);
         this.childrenSmooth.graphics.drawRect(0,0,this.steps,1);
         this.childrenSmooth.graphics.endFill();
      }
      
      public function get smoothPercentage() : Number
      {
         return this._smoothPercentage;
      }
      
      public function get childrenSmoothPercentage() : Number
      {
         return this._childrenSmoothPercentage;
      }
      
      public function set color(param1:uint) : void
      {
         var _loc2_:Object = null;
         this._color = param1;
         this.glow.color = param1;
         this.holder.filters = [this.glow];
         for each(_loc2_ in this.childrenArray)
         {
            _loc2_.instance.color = param1;
         }
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set childrenProbability(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._childrenProbability = param1;
      }
      
      public function get childrenProbability() : Number
      {
         return this._childrenProbability;
      }
      
      public function set childrenProbabilityDecay(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._childrenProbabilityDecay = param1;
      }
      
      public function get childrenProbabilityDecay() : Number
      {
         return this._childrenProbabilityDecay;
      }
      
      public function set maxLength(param1:Number) : void
      {
         this._maxLength = param1;
      }
      
      public function get maxLength() : Number
      {
         return this._maxLength;
      }
      
      public function set maxLengthVary(param1:Number) : void
      {
         this._maxLengthVary = param1;
      }
      
      public function get maxLengthVary() : Number
      {
         return this._maxLengthVary;
      }
      
      public function set thickness(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         this._thickness = param1;
      }
      
      public function get thickness() : Number
      {
         return this._thickness;
      }
      
      public function set thicknessDecay(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._thicknessDecay = param1;
      }
      
      public function get thicknessDecay() : Number
      {
         return this._thicknessDecay;
      }
      
      public function set childrenLengthDecay(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._childrenLengthDecay = param1;
      }
      
      public function get childrenLengthDecay() : Number
      {
         return this._childrenLengthDecay;
      }
      
      public function set childrenMaxGenerations(param1:uint) : void
      {
         this._childrenMaxGenerations = param1;
         this.killSurplus();
      }
      
      public function get childrenMaxGenerations() : uint
      {
         return this._childrenMaxGenerations;
      }
      
      public function set childrenMaxCount(param1:uint) : void
      {
         this._childrenMaxCount = param1;
         this.killSurplus();
      }
      
      public function get childrenMaxCount() : uint
      {
         return this._childrenMaxCount;
      }
      
      public function set childrenMaxCountDecay(param1:Number) : void
      {
         if(param1 > 1)
         {
            param1 = 1;
         }
         else if(param1 < 0)
         {
            param1 = 0;
         }
         this._childrenMaxCountDecay = param1;
      }
      
      public function get childrenMaxCountDecay() : Number
      {
         return this._childrenMaxCountDecay;
      }
      
      public function set childrenAngleVariation(param1:Number) : void
      {
         var _loc2_:Object = null;
         this._childrenAngleVariation = param1;
         for each(_loc2_ in this.childrenArray)
         {
            _loc2_.childAngle = Math.random() * param1 - param1 / 2;
            _loc2_.instance.childrenAngleVariation = param1;
         }
      }
      
      public function get childrenAngleVariation() : Number
      {
         return this._childrenAngleVariation;
      }
      
      public function set childrenLifeSpanMin(param1:Number) : void
      {
         this._childrenLifeSpanMin = param1;
      }
      
      public function get childrenLifeSpanMin() : Number
      {
         return this._childrenLifeSpanMin;
      }
      
      public function set childrenLifeSpanMax(param1:Number) : void
      {
         this._childrenLifeSpanMax = param1;
      }
      
      public function get childrenLifeSpanMax() : Number
      {
         return this._childrenLifeSpanMax;
      }
      
      public function set childrenDetachedEnd(param1:Boolean) : void
      {
         this._childrenDetachedEnd = param1;
      }
      
      public function get childrenDetachedEnd() : Boolean
      {
         return this._childrenDetachedEnd;
      }
      
      public function set wavelength(param1:Number) : void
      {
         var _loc2_:Object = null;
         this._wavelength = param1;
         for each(_loc2_ in this.childrenArray)
         {
            _loc2_.instance.wavelength = param1;
         }
      }
      
      public function get wavelength() : Number
      {
         return this._wavelength;
      }
      
      public function set amplitude(param1:Number) : void
      {
         var _loc2_:Object = null;
         this._amplitude = param1;
         for each(_loc2_ in this.childrenArray)
         {
            _loc2_.instance.amplitude = param1;
         }
      }
      
      public function get amplitude() : Number
      {
         return this._amplitude;
      }
      
      public function set speed(param1:Number) : void
      {
         var _loc2_:Object = null;
         this._speed = param1;
         for each(_loc2_ in this.childrenArray)
         {
            _loc2_.instance.speed = param1;
         }
      }
      
      public function get speed() : Number
      {
         return this._speed;
      }
      
      public function set isVisible(param1:Boolean) : void
      {
         this._isVisible = visible = param1;
      }
      
      public function get isVisible() : Boolean
      {
         return this._isVisible;
      }
   }
}

