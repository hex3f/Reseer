package gs.utils.tween
{
   import gs.TweenLite;
   
   public dynamic class TweenLiteVars
   {
      
      public static const version:Number = 2.03;
      
      protected var _glowFilter:GlowFilterVars;
      
      protected var _transformAroundCenter:TransformAroundCenterVars;
      
      public var easeParams:Array;
      
      protected var _shortRotation:Object;
      
      protected var _colorMatrixFilter:ColorMatrixFilterVars;
      
      protected var _frameLabel:String;
      
      public var onStartParams:Array;
      
      public const isTV:Boolean = true;
      
      public var onUpdateParams:Array;
      
      protected var _visible:Boolean = true;
      
      public var startAt:TweenLiteVars;
      
      public var onComplete:Function;
      
      protected var _volume:Number;
      
      protected var _setSize:Object;
      
      protected var _removeTint:Boolean;
      
      public var renderOnStart:Boolean = false;
      
      protected var _quaternions:Object;
      
      protected var _blurFilter:BlurFilterVars;
      
      protected var _colorTransform:ColorTransformVars;
      
      protected var _frame:int;
      
      protected var _autoAlpha:Number;
      
      public var delay:Number = 0;
      
      public var onUpdate:Function;
      
      public var overwrite:int = 2;
      
      protected var _transformAroundPoint:TransformAroundPointVars;
      
      protected var _endArray:Array;
      
      public var runBackwards:Boolean = false;
      
      protected var _exposedVars:Object;
      
      protected var _dropShadowFilter:DropShadowFilterVars;
      
      protected var _orientToBezier:Array;
      
      public var onStart:Function;
      
      protected var _bevelFilter:BevelFilterVars;
      
      public var persist:Boolean = false;
      
      protected var _tint:uint;
      
      public var onCompleteParams:Array;
      
      protected var _bezierThrough:Array;
      
      protected var _hexColors:Object;
      
      public var ease:Function;
      
      protected var _bezier:Array;
      
      public function TweenLiteVars(param1:Object = null)
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         super();
         this._exposedVars = {};
         if(param1 != null)
         {
            for(_loc2_ in param1)
            {
               if(!(_loc2_ == "blurFilter" || _loc2_ == "glowFilter" || _loc2_ == "colorMatrixFilter" || _loc2_ == "bevelFilter" || _loc2_ == "dropShadowFilter" || _loc2_ == "transformAroundPoint" || _loc2_ == "transformAroundCenter" || _loc2_ == "colorTransform"))
               {
                  if(_loc2_ != "protectedVars")
                  {
                     this[_loc2_] = param1[_loc2_];
                  }
               }
            }
            if(param1.blurFilter != null)
            {
               this.blurFilter = BlurFilterVars.createFromGeneric(param1.blurFilter);
            }
            if(param1.bevelFilter != null)
            {
               this.bevelFilter = BevelFilterVars.createFromGeneric(param1.bevelFilter);
            }
            if(param1.colorMatrixFilter != null)
            {
               this.colorMatrixFilter = ColorMatrixFilterVars.createFromGeneric(param1.colorMatrixFilter);
            }
            if(param1.dropShadowFilter != null)
            {
               this.dropShadowFilter = DropShadowFilterVars.createFromGeneric(param1.dropShadowFilter);
            }
            if(param1.glowFilter != null)
            {
               this.glowFilter = GlowFilterVars.createFromGeneric(param1.glowFilter);
            }
            if(param1.transformAroundPoint != null)
            {
               this.transformAroundPoint = TransformAroundPointVars.createFromGeneric(param1.transformAroundPoint);
            }
            if(param1.transformAroundCenter != null)
            {
               this.transformAroundCenter = TransformAroundCenterVars.createFromGeneric(param1.transformAroundCenter);
            }
            if(param1.colorTransform != null)
            {
               this.colorTransform = ColorTransformVars.createFromGeneric(param1.colorTransform);
            }
            if(param1.protectedVars != null)
            {
               _loc3_ = param1.protectedVars;
               for(_loc2_ in _loc3_)
               {
                  this[_loc2_] = _loc3_[_loc2_];
               }
            }
         }
         if(TweenLite.version < 10.05)
         {
         }
      }
      
      public function set setSize(param1:Object) : void
      {
         this._setSize = this._exposedVars.setSize = param1;
      }
      
      public function set frameLabel(param1:String) : void
      {
         this._frameLabel = this._exposedVars.frameLabel = param1;
      }
      
      public function get quaternions() : Object
      {
         return this._quaternions;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function set transformAroundCenter(param1:TransformAroundCenterVars) : void
      {
         this._transformAroundCenter = this._exposedVars.transformAroundCenter = param1;
      }
      
      public function get shortRotation() : Object
      {
         return this._shortRotation;
      }
      
      public function set bevelFilter(param1:BevelFilterVars) : void
      {
         this._bevelFilter = this._exposedVars.bevelFilter = param1;
      }
      
      public function set quaternions(param1:Object) : void
      {
         this._quaternions = this._exposedVars.quaternions = param1;
      }
      
      protected function appendCloneVars(param1:Object, param2:Object) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         _loc3_ = ["delay","ease","easeParams","onStart","onStartParams","onUpdate","onUpdateParams","onComplete","onCompleteParams","overwrite","persist","renderOnStart","runBackwards","startAt"];
         _loc5_ = _loc3_.length - 1;
         while(_loc5_ > -1)
         {
            param1[_loc3_[_loc5_]] = this[_loc3_[_loc5_]];
            _loc5_--;
         }
         _loc4_ = ["_autoAlpha","_bevelFilter","_bezier","_bezierThrough","_blurFilter","_colorMatrixFilter","_colorTransform","_dropShadowFilter","_endArray","_frame","_frameLabel","_glowFilter","_hexColors","_orientToBezier","_quaternions","_removeTint","_setSize","_shortRotation","_tint","_transformAroundCenter","_transformAroundPoint","_visible","_volume","_exposedVars"];
         _loc5_ = _loc4_.length - 1;
         while(_loc5_ > -1)
         {
            param2[_loc4_[_loc5_]] = this[_loc4_[_loc5_]];
            _loc5_--;
         }
         for(_loc6_ in this)
         {
            param1[_loc6_] = this[_loc6_];
         }
      }
      
      public function get transformAroundCenter() : TransformAroundCenterVars
      {
         return this._transformAroundCenter;
      }
      
      public function set volume(param1:Number) : void
      {
         this._volume = this._exposedVars.volume = param1;
      }
      
      public function get endArray() : Array
      {
         return this._endArray;
      }
      
      public function set colorMatrixFilter(param1:ColorMatrixFilterVars) : void
      {
         this._colorMatrixFilter = this._exposedVars.colorMatrixFilter = param1;
      }
      
      public function set shortRotation(param1:Object) : void
      {
         this._shortRotation = this._exposedVars.shortRotation = param1;
      }
      
      public function set removeTint(param1:Boolean) : void
      {
         this._removeTint = this._exposedVars.removeTint = param1;
      }
      
      public function get dropShadowFilter() : DropShadowFilterVars
      {
         return this._dropShadowFilter;
      }
      
      public function get colorTransform() : ColorTransformVars
      {
         return this._colorTransform;
      }
      
      public function addProps(param1:String, param2:Number, param3:Boolean = false, param4:String = null, param5:Number = 0, param6:Boolean = false, param7:String = null, param8:Number = 0, param9:Boolean = false, param10:String = null, param11:Number = 0, param12:Boolean = false, param13:String = null, param14:Number = 0, param15:Boolean = false, param16:String = null, param17:Number = 0, param18:Boolean = false, param19:String = null, param20:Number = 0, param21:Boolean = false, param22:String = null, param23:Number = 0, param24:Boolean = false, param25:String = null, param26:Number = 0, param27:Boolean = false, param28:String = null, param29:Number = 0, param30:Boolean = false, param31:String = null, param32:Number = 0, param33:Boolean = false, param34:String = null, param35:Number = 0, param36:Boolean = false, param37:String = null, param38:Number = 0, param39:Boolean = false, param40:String = null, param41:Number = 0, param42:Boolean = false, param43:String = null, param44:Number = 0, param45:Boolean = false) : void
      {
         this.addProp(param1,param2,param3);
         if(param4 != null)
         {
            this.addProp(param4,param5,param6);
         }
         if(param7 != null)
         {
            this.addProp(param7,param8,param9);
         }
         if(param10 != null)
         {
            this.addProp(param10,param11,param12);
         }
         if(param13 != null)
         {
            this.addProp(param13,param14,param15);
         }
         if(param16 != null)
         {
            this.addProp(param16,param17,param18);
         }
         if(param19 != null)
         {
            this.addProp(param19,param20,param21);
         }
         if(param22 != null)
         {
            this.addProp(param22,param23,param24);
         }
         if(param25 != null)
         {
            this.addProp(param25,param26,param27);
         }
         if(param28 != null)
         {
            this.addProp(param28,param29,param30);
         }
         if(param31 != null)
         {
            this.addProp(param31,param32,param33);
         }
         if(param34 != null)
         {
            this.addProp(param34,param35,param36);
         }
         if(param37 != null)
         {
            this.addProp(param37,param38,param39);
         }
         if(param40 != null)
         {
            this.addProp(param40,param41,param42);
         }
         if(param43 != null)
         {
            this.addProp(param43,param44,param45);
         }
      }
      
      public function clone() : TweenLiteVars
      {
         var _loc1_:Object = {"protectedVars":{}};
         this.appendCloneVars(_loc1_,_loc1_.protectedVars);
         return new TweenLiteVars(_loc1_);
      }
      
      public function set orientToBezier(param1:*) : void
      {
         if(param1 is Array)
         {
            this._orientToBezier = this._exposedVars.orientToBezier = param1;
         }
         else if(param1 == true)
         {
            this._orientToBezier = this._exposedVars.orientToBezier = [["x","y","rotation",0]];
         }
         else
         {
            this._orientToBezier = null;
            delete this._exposedVars.orientToBezier;
         }
      }
      
      public function get glowFilter() : GlowFilterVars
      {
         return this._glowFilter;
      }
      
      public function get hexColors() : Object
      {
         return this._hexColors;
      }
      
      public function get exposedVars() : Object
      {
         var _loc1_:String = null;
         var _loc2_:Object = {};
         for(_loc1_ in this._exposedVars)
         {
            _loc2_[_loc1_] = this._exposedVars[_loc1_];
         }
         for(_loc1_ in this)
         {
            _loc2_[_loc1_] = this[_loc1_];
         }
         return _loc2_;
      }
      
      public function get frame() : int
      {
         return this._frame;
      }
      
      public function set transformAroundPoint(param1:TransformAroundPointVars) : void
      {
         this._transformAroundPoint = this._exposedVars.transformAroundPoint = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._visible;
      }
      
      public function set endArray(param1:Array) : void
      {
         this._endArray = this._exposedVars.endArray = param1;
      }
      
      public function set blurFilter(param1:BlurFilterVars) : void
      {
         this._blurFilter = this._exposedVars.blurFilter = param1;
      }
      
      public function get frameLabel() : String
      {
         return this._frameLabel;
      }
      
      public function get setSize() : Object
      {
         return this._setSize;
      }
      
      public function set dropShadowFilter(param1:DropShadowFilterVars) : void
      {
         this._dropShadowFilter = this._exposedVars.dropShadowFilter = param1;
      }
      
      public function get bevelFilter() : BevelFilterVars
      {
         return this._bevelFilter;
      }
      
      public function set colorTransform(param1:ColorTransformVars) : void
      {
         this._colorTransform = this._exposedVars.colorTransform = param1;
      }
      
      public function get colorMatrixFilter() : ColorMatrixFilterVars
      {
         return this._colorMatrixFilter;
      }
      
      public function get removeTint() : Boolean
      {
         return this._removeTint;
      }
      
      public function addProp(param1:String, param2:Number, param3:Boolean = false) : void
      {
         if(param3)
         {
            this[param1] = String(param2);
         }
         else
         {
            this[param1] = param2;
         }
      }
      
      public function get orientToBezier() : *
      {
         return this._orientToBezier;
      }
      
      public function get transformAroundPoint() : TransformAroundPointVars
      {
         return this._transformAroundPoint;
      }
      
      public function get blurFilter() : BlurFilterVars
      {
         return this._blurFilter;
      }
      
      public function set bezier(param1:Array) : void
      {
         this._bezier = this._exposedVars.bezier = param1;
      }
      
      public function set glowFilter(param1:GlowFilterVars) : void
      {
         this._glowFilter = this._exposedVars.glowFilter = param1;
      }
      
      public function set bezierThrough(param1:Array) : void
      {
         this._bezierThrough = this._exposedVars.bezierThrough = param1;
      }
      
      public function set hexColors(param1:Object) : void
      {
         this._hexColors = this._exposedVars.hexColors = param1;
      }
      
      public function get bezier() : Array
      {
         return this._bezier;
      }
      
      public function set frame(param1:int) : void
      {
         this._frame = this._exposedVars.frame = param1;
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._visible = this._exposedVars.visible = param1;
      }
      
      public function set autoAlpha(param1:Number) : void
      {
         this._autoAlpha = this._exposedVars.autoAlpha = param1;
      }
      
      public function get bezierThrough() : Array
      {
         return this._bezierThrough;
      }
      
      public function get autoAlpha() : Number
      {
         return this._autoAlpha;
      }
      
      public function set tint(param1:uint) : void
      {
         this._tint = this._exposedVars.tint = param1;
      }
      
      public function get tint() : uint
      {
         return this._tint;
      }
   }
}

