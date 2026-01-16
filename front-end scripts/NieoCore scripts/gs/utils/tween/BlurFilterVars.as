package gs.utils.tween
{
   public class BlurFilterVars extends FilterVars
   {
      
      protected var _quality:uint;
      
      protected var _blurX:Number;
      
      protected var _blurY:Number;
      
      public function BlurFilterVars(param1:Number = 10, param2:Number = 10, param3:uint = 2, param4:Boolean = false, param5:int = -1, param6:Boolean = false)
      {
         super(param4,param5,param6);
         this.blurX = param1;
         this.blurY = param2;
         this.quality = param3;
      }
      
      public static function createFromGeneric(param1:Object) : BlurFilterVars
      {
         if(param1 is BlurFilterVars)
         {
            return param1 as BlurFilterVars;
         }
         return new BlurFilterVars(Number(param1.blurX) || 0,Number(param1.blurY) || 0,uint(param1.quality) || 2,Boolean(param1.remove),param1.index == null ? -1 : int(param1.index),Boolean(param1.addFilter));
      }
      
      public function set blurX(param1:Number) : void
      {
         this._blurX = this.exposedVars.blurX = param1;
      }
      
      public function set blurY(param1:Number) : void
      {
         this._blurY = this.exposedVars.blurY = param1;
      }
      
      public function get blurX() : Number
      {
         return this._blurX;
      }
      
      public function get blurY() : Number
      {
         return this._blurY;
      }
      
      public function set quality(param1:uint) : void
      {
         this._quality = this.exposedVars.quality = param1;
      }
      
      public function get quality() : uint
      {
         return this._quality;
      }
   }
}

