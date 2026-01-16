package gs.utils.tween
{
   public class GlowFilterVars extends FilterVars
   {
      
      protected var _quality:uint;
      
      protected var _blurY:Number;
      
      protected var _inner:Boolean;
      
      protected var _blurX:Number;
      
      protected var _alpha:Number;
      
      protected var _strength:Number;
      
      protected var _color:uint;
      
      protected var _knockout:Boolean;
      
      public function GlowFilterVars(param1:Number = 10, param2:Number = 10, param3:uint = 16777215, param4:Number = 1, param5:Number = 2, param6:Boolean = false, param7:Boolean = false, param8:uint = 2, param9:Boolean = false, param10:int = -1, param11:Boolean = false)
      {
         super(param9,param10,param11);
         this.blurX = param1;
         this.blurY = param2;
         this.color = param3;
         this.alpha = param4;
         this.strength = param5;
         this.inner = param6;
         this.knockout = param7;
         this.quality = param8;
      }
      
      public static function createFromGeneric(param1:Object) : GlowFilterVars
      {
         if(param1 is GlowFilterVars)
         {
            return param1 as GlowFilterVars;
         }
         return new GlowFilterVars(Number(param1.blurX) || 0,Number(param1.blurY) || 0,param1.color == null ? 0 : uint(param1.color),Number(param1.alpha) || 0,param1.strength == null ? 2 : Number(param1.strength),Boolean(param1.inner),Boolean(param1.knockout),uint(param1.quality) || 2,Boolean(param1.remove),param1.index == null ? -1 : int(param1.index),Boolean(param1.addFilter));
      }
      
      public function get strength() : Number
      {
         return this._strength;
      }
      
      public function set strength(param1:Number) : void
      {
         this._strength = this.exposedVars.strength = param1;
      }
      
      public function set quality(param1:uint) : void
      {
         this._quality = this.exposedVars.quality = param1;
      }
      
      public function set color(param1:uint) : void
      {
         this._color = this.exposedVars.color = param1;
      }
      
      public function get blurX() : Number
      {
         return this._blurX;
      }
      
      public function get blurY() : Number
      {
         return this._blurY;
      }
      
      public function get inner() : Boolean
      {
         return this._inner;
      }
      
      public function set blurY(param1:Number) : void
      {
         this._blurY = this.exposedVars.blurY = param1;
      }
      
      public function get alpha() : Number
      {
         return this._alpha;
      }
      
      public function set blurX(param1:Number) : void
      {
         this._blurX = this.exposedVars.blurX = param1;
      }
      
      public function get color() : uint
      {
         return this._color;
      }
      
      public function set inner(param1:Boolean) : void
      {
         this._inner = this.exposedVars.inner = param1;
      }
      
      public function set knockout(param1:Boolean) : void
      {
         this._knockout = this.exposedVars.knockout = param1;
      }
      
      public function get knockout() : Boolean
      {
         return this._knockout;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._alpha = this.exposedVars.alpha = param1;
      }
      
      public function get quality() : uint
      {
         return this._quality;
      }
   }
}

