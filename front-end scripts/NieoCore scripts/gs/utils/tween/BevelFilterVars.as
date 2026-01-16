package gs.utils.tween
{
   public class BevelFilterVars extends FilterVars
   {
      
      protected var _quality:uint;
      
      protected var _blurY:Number;
      
      protected var _distance:Number;
      
      protected var _blurX:Number;
      
      protected var _angle:Number;
      
      protected var _shadowAlpha:Number;
      
      protected var _strength:Number;
      
      protected var _highlightAlpha:Number;
      
      protected var _shadowColor:uint;
      
      protected var _highlightColor:uint;
      
      public function BevelFilterVars(param1:Number = 4, param2:Number = 4, param3:Number = 4, param4:Number = 1, param5:Number = 45, param6:Number = 1, param7:uint = 16777215, param8:Number = 1, param9:uint = 0, param10:uint = 2, param11:Boolean = false, param12:int = -1, param13:Boolean = false)
      {
         super(param11,param12,param13);
         this.distance = param1;
         this.blurX = param2;
         this.blurY = param3;
         this.strength = param4;
         this.angle = param5;
         this.highlightAlpha = param6;
         this.highlightColor = param7;
         this.shadowAlpha = param8;
         this.shadowColor = param9;
         this.quality = param10;
      }
      
      public static function createFromGeneric(param1:Object) : BevelFilterVars
      {
         if(param1 is BevelFilterVars)
         {
            return param1 as BevelFilterVars;
         }
         return new BevelFilterVars(Number(param1.distance) || 0,Number(param1.blurX) || 0,Number(param1.blurY) || 0,param1.strength == null ? 1 : Number(param1.strength),param1.angle == null ? 45 : Number(param1.angle),param1.highlightAlpha == null ? 1 : Number(param1.highlightAlpha),param1.highlightColor == null ? 16777215 : uint(param1.highlightColor),param1.shadowAlpha == null ? 1 : Number(param1.shadowAlpha),param1.shadowColor == null ? 16777215 : uint(param1.shadowColor),uint(param1.quality) || 2,Boolean(param1.remove),param1.index == null ? -1 : int(param1.index),Boolean(param1.addFilter));
      }
      
      public function get strength() : Number
      {
         return this._strength;
      }
      
      public function set strength(param1:Number) : void
      {
         this._strength = this.exposedVars.strength = param1;
      }
      
      public function set shadowAlpha(param1:Number) : void
      {
         this._shadowAlpha = this.exposedVars.shadowAlpha = param1;
      }
      
      public function set quality(param1:uint) : void
      {
         this._quality = this.exposedVars.quality = param1;
      }
      
      public function set shadowColor(param1:uint) : void
      {
         this._shadowColor = this.exposedVars.shadowColor = param1;
      }
      
      public function get highlightAlpha() : Number
      {
         return this._highlightAlpha;
      }
      
      public function get blurX() : Number
      {
         return this._blurX;
      }
      
      public function get highlightColor() : uint
      {
         return this._highlightColor;
      }
      
      public function get angle() : Number
      {
         return this._angle;
      }
      
      public function set highlightColor(param1:uint) : void
      {
         this._highlightColor = this.exposedVars.highlightColor = param1;
      }
      
      public function get blurY() : Number
      {
         return this._blurY;
      }
      
      public function set blurX(param1:Number) : void
      {
         this._blurX = this.exposedVars.blurX = param1;
      }
      
      public function set highlightAlpha(param1:Number) : void
      {
         this._highlightAlpha = this.exposedVars.highlightAlpha = param1;
      }
      
      public function get shadowAlpha() : Number
      {
         return this._shadowAlpha;
      }
      
      public function set distance(param1:Number) : void
      {
         this._distance = this.exposedVars.distance = param1;
      }
      
      public function set angle(param1:Number) : void
      {
         this._angle = this.exposedVars.angle = param1;
      }
      
      public function get shadowColor() : uint
      {
         return this._shadowColor;
      }
      
      public function get distance() : Number
      {
         return this._distance;
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

