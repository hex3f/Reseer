package gs.utils.tween
{
   public class DropShadowFilterVars extends FilterVars
   {
      
      protected var _blurX:Number;
      
      protected var _blurY:Number;
      
      protected var _distance:Number;
      
      protected var _inner:Boolean;
      
      protected var _quality:uint;
      
      protected var _knockout:Boolean;
      
      protected var _angle:Number;
      
      protected var _alpha:Number;
      
      protected var _strength:Number;
      
      protected var _hideObject:Boolean;
      
      protected var _color:uint;
      
      public function DropShadowFilterVars(param1:Number = 4, param2:Number = 4, param3:Number = 4, param4:Number = 1, param5:Number = 45, param6:uint = 0, param7:Number = 2, param8:Boolean = false, param9:Boolean = false, param10:Boolean = false, param11:uint = 2, param12:Boolean = false, param13:int = -1, param14:Boolean = false)
      {
         super(param12,param13,param14);
         this.distance = param1;
         this.blurX = param2;
         this.blurY = param3;
         this.alpha = param4;
         this.angle = param5;
         this.color = param6;
         this.strength = param7;
         this.inner = param8;
         this.knockout = param9;
         this.hideObject = param10;
         this.quality = param11;
      }
      
      public static function createFromGeneric(param1:Object) : DropShadowFilterVars
      {
         if(param1 is DropShadowFilterVars)
         {
            return param1 as DropShadowFilterVars;
         }
         return new DropShadowFilterVars(Number(param1.distance) || 0,Number(param1.blurX) || 0,Number(param1.blurY) || 0,Number(param1.alpha) || 0,param1.angle == null ? 45 : Number(param1.angle),param1.color == null ? 0 : uint(param1.color),param1.strength == null ? 2 : Number(param1.strength),Boolean(param1.inner),Boolean(param1.knockout),Boolean(param1.hideObject),uint(param1.quality) || 2,Boolean(param1.remove),param1.index == null ? -1 : int(param1.index),param1.addFilter);
      }
      
      public function get strength() : Number
      {
         return this._strength;
      }
      
      public function set strength(param1:Number) : void
      {
         this._strength = this.exposedVars.strength = param1;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._alpha = this.exposedVars.alpha = param1;
      }
      
      public function set quality(param1:uint) : void
      {
         this._quality = this.exposedVars.quality = param1;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = this.exposedVars.color = param1;
      }
      
      public function set hideObject(param1:Boolean) : void
      {
         this._hideObject = this.exposedVars.hideObject = param1;
      }
      
      public function get blurX() : Number
      {
         return this._blurX;
      }
      
      public function get inner() : Boolean
      {
         return this._inner;
      }
      
      public function get angle() : Number
      {
         return this._angle;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function get blurY() : Number
      {
         return this._blurY;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set blurX(param1:Number) : void
      {
         this._blurX = this.exposedVars.blurX = param1;
      }
      
      public function set distance(param1:Number) : void
      {
         this._distance = this.exposedVars.distance = param1;
      }
      
      public function set inner(param1:Boolean) : void
      {
         this._inner = this.exposedVars.inner = param1;
      }
      
      public function set angle(param1:Number) : void
      {
         this._angle = this.exposedVars.angle = param1;
      }
      
      public function get hideObject() : Boolean
      {
         return this._hideObject;
      }
      
      public function set knockout(param1:Boolean) : void
      {
         this._knockout = this.exposedVars.knockout = param1;
      }
      
      public function get distance() : Number
      {
         return this._distance;
      }
      
      public function get knockout() : Boolean
      {
         return this._knockout;
      }
      
      public function set blurY(param1:Number) : void
      {
         this._blurY = this.exposedVars.blurY = param1;
      }
      
      public function get quality() : uint
      {
         return this._quality;
      }
   }
}

