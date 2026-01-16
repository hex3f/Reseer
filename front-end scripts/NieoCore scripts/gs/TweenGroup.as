package gs
{
   import flash.events.*;
   import flash.utils.*;
   
   use namespace flash_proxy;
   
   public dynamic class TweenGroup extends Proxy implements IEventDispatcher
   {
      
      protected static var _classInitted:Boolean;
      
      protected static var _TweenMax:Class;
      
      public static const version:Number = 1.02;
      
      public static const ALIGN_INIT:String = "init";
      
      public static const ALIGN_START:String = "start";
      
      public static const ALIGN_END:String = "end";
      
      public static const ALIGN_SEQUENCE:String = "sequence";
      
      public static const ALIGN_NONE:String = "none";
      
      protected static var _overwriteMode:int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init();
      
      protected static var _unexpired:Array = [];
      
      protected static var _prevTime:uint = 0;
      
      protected var _align:String;
      
      protected var _tweens:Array;
      
      protected var _reversed:Boolean;
      
      public var loop:Number;
      
      public var expired:Boolean;
      
      public var yoyo:Number;
      
      public var onComplete:Function;
      
      protected var _dispatcher:EventDispatcher;
      
      public var endTime:Number;
      
      protected var _startTime:Number;
      
      protected var _initTime:Number;
      
      public var onCompleteParams:Array;
      
      protected var _pauseTime:Number;
      
      protected var _stagger:Number;
      
      protected var _repeatCount:Number;
      
      public function TweenGroup(param1:Array = null, param2:Class = null, param3:String = "none", param4:Number = 0)
      {
         var $tweens:Array = param1;
         var $DefaultTweenClass:Class = param2;
         var $align:String = param3;
         var $stagger:Number = param4;
         super();
         if(!_classInitted)
         {
            if(TweenLite.version < 9.291)
            {
            }
            try
            {
               _TweenMax = getDefinitionByName("gs.TweenMax") as Class;
            }
            catch($e:Error)
            {
               _TweenMax = Array;
            }
            TweenLite.timingSprite.addEventListener(Event.ENTER_FRAME,checkExpiration,false,-1,true);
            _classInitted = true;
         }
         this.expired = true;
         this._repeatCount = 0;
         this._align = $align;
         this._stagger = $stagger;
         this._dispatcher = new EventDispatcher(this);
         if($tweens != null)
         {
            this._tweens = parse($tweens,$DefaultTweenClass);
            this.updateTimeSpan();
            this.realign();
         }
         else
         {
            this._tweens = [];
            this._initTime = this._startTime = this.endTime = 0;
         }
      }
      
      protected static function checkExpiration(param1:Event) : void
      {
         var _loc2_:TweenGroup = null;
         var _loc3_:int = 0;
         var _loc4_:uint = TweenLite.currentTime;
         var _loc5_:Array = _unexpired;
         _loc3_ = _loc5_.length - 1;
         while(_loc3_ > -1)
         {
            _loc2_ = _loc5_[_loc3_];
            if(_loc2_.endTime > _prevTime && _loc2_.endTime <= _loc4_ && !_loc2_.paused)
            {
               _loc5_.splice(_loc3_,1);
               _loc2_.expired = true;
               _loc2_.handleCompletion();
            }
            _loc3_--;
         }
         _prevTime = _loc4_;
      }
      
      public static function allFrom(param1:Array, param2:Number, param3:Object, param4:Class = null) : TweenGroup
      {
         param3.runBackwards = true;
         return allTo(param1,param2,param3,param4);
      }
      
      public static function parse(param1:Array, param2:Class = null) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Number = NaN;
         if(param2 == null)
         {
            param2 = TweenLite;
         }
         var _loc6_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] is TweenLite)
            {
               _loc6_[_loc6_.length] = param1[_loc3_];
            }
            else
            {
               _loc4_ = param1[_loc3_].target;
               _loc5_ = Number(param1[_loc3_].time);
               delete param1[_loc3_].target;
               delete param1[_loc3_].time;
               _loc6_[_loc6_.length] = new param2(_loc4_,_loc5_,param1[_loc3_]);
            }
            _loc3_++;
         }
         return _loc6_;
      }
      
      public static function allTo(param1:Array, param2:Number, param3:Object, param4:Class = null) : TweenGroup
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         if(param4 == null)
         {
            param4 = TweenLite;
         }
         var _loc8_:TweenGroup = new TweenGroup(null,param4,ALIGN_INIT,Number(param3.stagger) || 0);
         _loc8_.onComplete = param3.onCompleteAll;
         _loc8_.onCompleteParams = param3.onCompleteAllParams;
         delete param3.stagger;
         delete param3.onCompleteAll;
         delete param3.onCompleteAllParams;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = {};
            for(_loc7_ in param3)
            {
               _loc6_[_loc7_] = param3[_loc7_];
            }
            _loc8_[_loc8_.length] = new param4(param1[_loc5_],param2,_loc6_);
            _loc5_++;
         }
         if(_loc8_.stagger < 0)
         {
            _loc8_.progressWithDelay = 0;
         }
         return _loc8_;
      }
      
      protected function offsetTime(param1:Array, param2:Number) : void
      {
         var _loc5_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:TweenLite = null;
         var _loc8_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(param1.length != 0)
         {
            _loc3_ = param2 * 1000;
            _loc4_ = isNaN(this._pauseTime) ? TweenLite.currentTime : this._pauseTime;
            _loc5_ = this.getRenderOrder(param1,_loc4_);
            _loc12_ = [];
            _loc11_ = _loc5_.length - 1;
            while(_loc11_ > -1)
            {
               _loc7_ = _loc5_[_loc11_];
               _loc7_.initTime += _loc3_;
               _loc6_ = Boolean(_loc7_.startTime == 999999999999999);
               _loc9_ = _loc7_.initTime + _loc7_.delay * (1000 / _loc7_.combinedTimeScale);
               _loc10_ = this.getEndTime(_loc7_);
               _loc8_ = (_loc9_ <= _loc4_ || _loc9_ - _loc3_ <= _loc4_) && (_loc10_ >= _loc4_ || _loc10_ - _loc3_ >= _loc4_);
               if(isNaN(this._pauseTime) && _loc10_ >= _loc4_)
               {
                  _loc7_.enabled = true;
               }
               if(!_loc6_)
               {
                  _loc7_.startTime = _loc9_;
               }
               if(_loc9_ >= _loc4_)
               {
                  if(!_loc7_.initted)
                  {
                     _loc8_ = false;
                  }
                  _loc7_.active = false;
               }
               if(_loc8_)
               {
                  _loc12_[_loc12_.length] = _loc7_;
               }
               _loc11_--;
            }
            _loc11_ = _loc12_.length - 1;
            while(_loc11_ > -1)
            {
               this.renderTween(_loc12_[_loc11_],_loc4_);
               _loc11_--;
            }
            this.endTime += _loc3_;
            this._startTime += _loc3_;
            this._initTime += _loc3_;
            if(this.expired && this.endTime > _loc4_)
            {
               this.expired = false;
               _unexpired[_unexpired.length] = this;
            }
         }
      }
      
      protected function renderTween(param1:TweenLite, param2:Number) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = this.getEndTime(param1);
         if(param1.startTime == 999999999999999)
         {
            param1.startTime = param1.initTime + param1.delay * (1000 / param1.combinedTimeScale);
            _loc4_ = true;
         }
         if(!param1.initted)
         {
            _loc5_ = param1.active;
            param1.active = false;
            if(_loc4_)
            {
               param1.initTweenVals();
               if(param1.vars.onStart != null)
               {
                  param1.vars.onStart.apply(null,param1.vars.onStartParams);
               }
            }
            else
            {
               param1.activate();
            }
            param1.active = _loc5_;
         }
         if(param1.startTime > param2)
         {
            _loc3_ = param1.startTime;
         }
         else if(_loc7_ < param2)
         {
            _loc3_ = _loc7_;
         }
         else
         {
            _loc3_ = param2;
         }
         if(_loc3_ < 0)
         {
            _loc6_ = param1.startTime;
            param1.startTime -= _loc3_;
            param1.render(0);
            param1.startTime = _loc6_;
         }
         else
         {
            param1.render(_loc3_);
         }
         if(_loc4_)
         {
            param1.startTime = 999999999999999;
         }
      }
      
      public function get align() : String
      {
         return this._align;
      }
      
      public function set align(param1:String) : void
      {
         this._align = param1;
         this.realign();
      }
      
      public function set reversed(param1:Boolean) : void
      {
         if(this._reversed != param1)
         {
            this.reverse(true);
         }
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return this._dispatcher.willTrigger(param1);
      }
      
      override flash_proxy function hasProperty(param1:*) : Boolean
      {
         if(this._tweens.hasOwnProperty(param1))
         {
            return true;
         }
         if(" progress progressWithDelay duration durationWithDelay paused reversed timeScale align stagger tweens ".indexOf(" " + param1 + " ") != -1)
         {
            return true;
         }
         return false;
      }
      
      protected function getEndTime(param1:TweenLite) : Number
      {
         return param1.initTime + (param1.delay + param1.duration) * (1000 / param1.combinedTimeScale);
      }
      
      public function get duration() : Number
      {
         if(this._tweens.length == 0)
         {
            return 0;
         }
         return (this.endTime - this._startTime) / 1000;
      }
      
      public function restart(param1:Boolean = false) : void
      {
         this.setProgress(0,param1);
         this._repeatCount = 0;
         this.resume();
      }
      
      protected function getStartTime(param1:TweenLite) : Number
      {
         return param1.initTime + param1.delay * 1000 / param1.combinedTimeScale;
      }
      
      protected function pauseTween(param1:TweenLite) : void
      {
         if(param1 is _TweenMax)
         {
            (param1 as Object).pauseTime = this._pauseTime;
         }
         param1.startTime = 999999999999999;
         param1.enabled = false;
      }
      
      protected function getRenderOrder(param1:Array, param2:Number) : Array
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         _loc3_ = param1.length - 1;
         while(_loc3_ > -1)
         {
            _loc4_ = this.getStartTime(param1[_loc3_]);
            if(_loc4_ >= param2)
            {
               _loc5_[_loc5_.length] = {
                  "start":_loc4_,
                  "tween":param1[_loc3_]
               };
            }
            else
            {
               _loc6_[_loc6_.length] = {
                  "end":this.getEndTime(param1[_loc3_]),
                  "tween":param1[_loc3_]
               };
            }
            _loc3_--;
         }
         _loc5_.sortOn("start",Array.NUMERIC);
         _loc6_.sortOn("end",Array.NUMERIC);
         _loc3_ = _loc5_.length - 1;
         while(_loc3_ > -1)
         {
            _loc7_[_loc3_] = _loc5_[_loc3_].tween;
            _loc3_--;
         }
         _loc3_ = _loc6_.length - 1;
         while(_loc3_ > -1)
         {
            _loc7_[_loc7_.length] = _loc6_[_loc3_].tween;
            _loc3_--;
         }
         return _loc7_;
      }
      
      protected function getProgress(param1:Boolean = false) : Number
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._tweens.length == 0)
         {
            return 0;
         }
         _loc2_ = isNaN(this._pauseTime) ? TweenLite.currentTime : this._pauseTime;
         _loc3_ = param1 ? this._initTime : this._startTime;
         _loc4_ = (_loc2_ - _loc3_) / (this.endTime - _loc3_);
         if(_loc4_ < 0)
         {
            return 0;
         }
         if(_loc4_ > 1)
         {
            return 1;
         }
         return _loc4_;
      }
      
      protected function setTweenStartTime(param1:TweenLite, param2:Number) : void
      {
         var _loc3_:Number = param2 - this.getStartTime(param1);
         param1.initTime += _loc3_;
         if(param1.startTime != 999999999999999)
         {
            param1.startTime = param2;
         }
      }
      
      public function mergeGroup(param1:TweenGroup, param2:Number = NaN) : void
      {
         var _loc3_:int = 0;
         if(isNaN(param2) || param2 > this._tweens.length)
         {
            param2 = this._tweens.length;
         }
         var _loc4_:Array = param1.tweens;
         var _loc5_:uint = _loc4_.length;
         _loc3_ = 0;
         while(_loc3_ < _loc5_)
         {
            this._tweens.splice(param2 + _loc3_,0,_loc4_[_loc3_]);
            _loc3_++;
         }
         this.realign();
      }
      
      public function get durationWithDelay() : Number
      {
         if(this._tweens.length == 0)
         {
            return 0;
         }
         return (this.endTime - this._initTime) / 1000;
      }
      
      public function handleCompletion() : void
      {
         if(!isNaN(this.yoyo) && (this._repeatCount < this.yoyo || this.yoyo == 0))
         {
            ++this._repeatCount;
            this.reverse(true);
         }
         else if(!isNaN(this.loop) && (this._repeatCount < this.loop || this.loop == 0))
         {
            ++this._repeatCount;
            this.setProgress(0,true);
         }
         if(this.onComplete != null)
         {
            this.onComplete.apply(null,this.onCompleteParams);
         }
         this._dispatcher.dispatchEvent(new Event(Event.COMPLETE));
      }
      
      public function resume() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Array = [];
         var _loc4_:Number = TweenLite.currentTime;
         _loc1_ = this._tweens.length - 1;
         while(_loc1_ > -1)
         {
            if(this._tweens[_loc1_].startTime == 999999999999999)
            {
               this.resumeTween(this._tweens[_loc1_]);
               _loc3_[_loc3_.length] = this._tweens[_loc1_];
            }
            if(this._tweens[_loc1_].startTime >= _loc4_ && !this._tweens[_loc1_].enabled)
            {
               this._tweens[_loc1_].enabled = true;
               this._tweens[_loc1_].active = false;
            }
            _loc1_--;
         }
         if(!isNaN(this._pauseTime))
         {
            _loc2_ = (TweenLite.currentTime - this._pauseTime) / 1000;
            this._pauseTime = NaN;
            this.offsetTime(_loc3_,_loc2_);
         }
      }
      
      public function get paused() : Boolean
      {
         return !isNaN(this._pauseTime);
      }
      
      public function updateTimeSpan() : void
      {
         var _loc1_:int = 0;
         var _loc5_:TweenLite = null;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._tweens.length == 0)
         {
            this.endTime = this._startTime = this._initTime = 0;
         }
         else
         {
            _loc5_ = this._tweens[0];
            this._initTime = _loc5_.initTime;
            this._startTime = this._initTime + _loc5_.delay * (1000 / _loc5_.combinedTimeScale);
            this.endTime = this._startTime + _loc5_.duration * (1000 / _loc5_.combinedTimeScale);
            _loc1_ = this._tweens.length - 1;
            while(_loc1_ > 0)
            {
               _loc5_ = this._tweens[_loc1_];
               _loc3_ = _loc5_.initTime;
               _loc2_ = _loc3_ + _loc5_.delay * (1000 / _loc5_.combinedTimeScale);
               _loc4_ = _loc2_ + _loc5_.duration * (1000 / _loc5_.combinedTimeScale);
               if(_loc3_ < this._initTime)
               {
                  this._initTime = _loc3_;
               }
               if(_loc2_ < this._startTime)
               {
                  this._startTime = _loc2_;
               }
               if(_loc4_ > this.endTime)
               {
                  this.endTime = _loc4_;
               }
               _loc1_--;
            }
            if(this.expired && this.endTime > TweenLite.currentTime)
            {
               this.expired = false;
               _unexpired[_unexpired.length] = this;
            }
         }
      }
      
      public function get progressWithDelay() : Number
      {
         return this.getProgress(true);
      }
      
      public function realign() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:int = 0;
         var _loc5_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._align != ALIGN_NONE && this._tweens.length > 1)
         {
            _loc1_ = this._tweens.length;
            _loc3_ = this._stagger * 1000;
            _loc5_ = this._reversed;
            if(_loc5_)
            {
               _loc4_ = this.progressWithDelay;
               this.reverse();
               this.progressWithDelay = 0;
            }
            if(this._align == ALIGN_SEQUENCE)
            {
               this.setTweenInitTime(this._tweens[0],this._initTime);
               _loc2_ = 1;
               while(_loc2_ < _loc1_)
               {
                  this.setTweenInitTime(this._tweens[_loc2_],this.getEndTime(this._tweens[_loc2_ - 1]) + _loc3_);
                  _loc2_++;
               }
            }
            else if(this._align == ALIGN_INIT)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  this.setTweenInitTime(this._tweens[_loc2_],this._initTime + _loc3_ * _loc2_);
                  _loc2_++;
               }
            }
            else if(this._align == ALIGN_START)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  this.setTweenStartTime(this._tweens[_loc2_],this._startTime + _loc3_ * _loc2_);
                  _loc2_++;
               }
            }
            else
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_)
               {
                  this.setTweenInitTime(this._tweens[_loc2_],this.endTime - (this._tweens[_loc2_].delay + this._tweens[_loc2_].duration) * 1000 / this._tweens[_loc2_].combinedTimeScale - _loc3_ * _loc2_);
                  _loc2_++;
               }
            }
            if(_loc5_)
            {
               this.reverse();
               this.progressWithDelay = _loc4_;
            }
         }
         this.updateTimeSpan();
      }
      
      public function get progress() : Number
      {
         return this.getProgress(false);
      }
      
      protected function setProgress(param1:Number, param2:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(this._tweens.length != 0)
         {
            _loc3_ = isNaN(this._pauseTime) ? TweenLite.currentTime : this._pauseTime;
            _loc4_ = param2 ? this._initTime : this._startTime;
            this.offsetTime(this._tweens,(_loc3_ - (_loc4_ + (this.endTime - _loc4_) * param1)) / 1000);
         }
      }
      
      protected function resumeTween(param1:TweenLite) : void
      {
         if(param1 is _TweenMax)
         {
            (param1 as Object).pauseTime = NaN;
         }
         param1.startTime = param1.initTime + param1.delay * (1000 / param1.combinedTimeScale);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return this._dispatcher.dispatchEvent(param1);
      }
      
      public function get stagger() : Number
      {
         return this._stagger;
      }
      
      public function get reversed() : Boolean
      {
         return this._reversed;
      }
      
      override flash_proxy function getProperty(param1:*) : *
      {
         return this._tweens[param1];
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         this._dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         this._dispatcher.removeEventListener(param1,param2,param3);
      }
      
      override flash_proxy function callProperty(param1:*, ... rest) : *
      {
         var _loc3_:* = this._tweens[param1].apply(null,rest);
         this.realign();
         if(!isNaN(this._pauseTime))
         {
            this.pause();
         }
         return _loc3_;
      }
      
      protected function setTweenInitTime(param1:TweenLite, param2:Number) : void
      {
         var _loc3_:Number = param2 - param1.initTime;
         param1.initTime = param2;
         if(param1.startTime != 999999999999999)
         {
            param1.startTime += _loc3_;
         }
      }
      
      public function set progress(param1:Number) : void
      {
         this.setProgress(param1,false);
      }
      
      public function set progressWithDelay(param1:Number) : void
      {
         this.setProgress(param1,true);
      }
      
      public function set stagger(param1:Number) : void
      {
         this._stagger = param1;
         this.realign();
      }
      
      public function reverse(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TweenLite = null;
         var _loc4_:ReverseProxy = null;
         var _loc10_:Boolean = false;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         this._reversed = !this._reversed;
         var _loc9_:Number = 0;
         var _loc11_:Number = !isNaN(this._pauseTime) ? this._pauseTime : TweenLite.currentTime;
         if(this.endTime <= _loc11_)
         {
            _loc9_ = int(this.endTime - _loc11_) + 1;
            _loc10_ = true;
         }
         _loc2_ = this._tweens.length - 1;
         while(_loc2_ > -1)
         {
            _loc3_ = this._tweens[_loc2_];
            if(_loc3_ is _TweenMax)
            {
               _loc5_ = _loc3_.startTime;
               _loc6_ = _loc3_.initTime;
               (_loc3_ as Object).reverse(false,false);
               _loc3_.startTime = _loc5_;
               _loc3_.initTime = _loc6_;
            }
            else if(_loc3_.ease != _loc3_.vars.ease)
            {
               _loc3_.ease = _loc3_.vars.ease;
            }
            else
            {
               _loc4_ = new ReverseProxy(_loc3_);
               _loc3_.ease = _loc4_.reverseEase;
            }
            _loc8_ = _loc3_.combinedTimeScale;
            _loc7_ = ((_loc11_ - _loc3_.initTime) / 1000 - _loc3_.delay / _loc8_) / _loc3_.duration * _loc8_;
            _loc5_ = int(_loc11_ - (1 - _loc7_) * _loc3_.duration * 1000 / _loc8_ + _loc9_);
            _loc3_.initTime = int(_loc5_ - _loc3_.delay * (1000 / _loc8_));
            if(_loc3_.startTime != 999999999999999)
            {
               _loc3_.startTime = _loc5_;
            }
            if(_loc3_.startTime > _loc11_)
            {
               _loc3_.enabled = true;
               _loc3_.active = false;
            }
            _loc2_--;
         }
         this.updateTimeSpan();
         if(param1)
         {
            if(_loc10_)
            {
               this.setProgress(0,true);
            }
            this.resume();
         }
      }
      
      public function clear(param1:Boolean = true) : void
      {
         var _loc2_:int = this._tweens.length - 1;
         while(_loc2_ > -1)
         {
            if(param1)
            {
               TweenLite.removeTween(this._tweens[_loc2_],true);
            }
            this._tweens[_loc2_] = null;
            this._tweens.splice(_loc2_,1);
            _loc2_--;
         }
         if(!this.expired)
         {
            _loc2_ = _unexpired.length - 1;
            while(_loc2_ > -1)
            {
               if(_unexpired[_loc2_] == this)
               {
                  _unexpired.splice(_loc2_,1);
                  break;
               }
               _loc2_--;
            }
            this.expired = true;
         }
      }
      
      override flash_proxy function setProperty(param1:*, param2:*) : void
      {
         this.onSetProperty(param1,param2);
      }
      
      public function get tweens() : Array
      {
         return this._tweens.slice();
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(param1)
         {
            this.pause();
         }
         else
         {
            this.resume();
         }
      }
      
      public function toString() : String
      {
         return "TweenGroup( " + this._tweens.toString() + " )";
      }
      
      public function get length() : uint
      {
         return this._tweens.length;
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return this._dispatcher.hasEventListener(param1);
      }
      
      public function pause() : void
      {
         if(isNaN(this._pauseTime))
         {
            this._pauseTime = TweenLite.currentTime;
         }
         var _loc1_:int = this._tweens.length - 1;
         while(_loc1_ > -1)
         {
            if(this._tweens[_loc1_].startTime != 999999999999999)
            {
               this.pauseTween(this._tweens[_loc1_]);
            }
            _loc1_--;
         }
      }
      
      protected function onSetProperty(param1:*, param2:*) : void
      {
         if(!(!isNaN(param1) && !(param2 is TweenLite)))
         {
            this._tweens[param1] = param2;
            this.realign();
            if(!isNaN(this._pauseTime) && param2 is TweenLite)
            {
               this.pauseTween(param2 as TweenLite);
            }
         }
      }
      
      public function set timeScale(param1:Number) : void
      {
         var _loc2_:int = this._tweens.length - 1;
         while(_loc2_ > -1)
         {
            if(this._tweens[_loc2_] is _TweenMax)
            {
               this._tweens[_loc2_].timeScale = param1;
            }
            _loc2_--;
         }
         this.updateTimeSpan();
      }
      
      public function getActive() : Array
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Array = [];
         if(isNaN(this._pauseTime))
         {
            _loc2_ = TweenLite.currentTime;
            _loc1_ = this._tweens.length - 1;
            while(_loc1_ > -1)
            {
               if(this._tweens[_loc1_].startTime <= _loc2_ && this.getEndTime(this._tweens[_loc1_]) >= _loc2_)
               {
                  _loc3_[_loc3_.length] = this._tweens[_loc1_];
               }
               _loc1_--;
            }
         }
         return _loc3_;
      }
      
      public function get timeScale() : Number
      {
         var _loc1_:uint = 0;
         while(_loc1_ < this._tweens.length)
         {
            if(this._tweens[_loc1_] is _TweenMax)
            {
               return this._tweens[_loc1_].timeScale;
            }
            _loc1_++;
         }
         return 1;
      }
   }
}

class ReverseProxy
{
   
   private var _tween:TweenLite;
   
   public function ReverseProxy(param1:TweenLite)
   {
      super();
      this._tween = param1;
   }
   
   public function reverseEase(param1:Number, param2:Number, param3:Number, param4:Number) : Number
   {
      return this._tween.vars.ease(param4 - param1,param2,param3,param4);
   }
}
