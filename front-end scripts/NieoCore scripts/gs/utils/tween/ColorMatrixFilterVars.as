package gs.utils.tween
{
   import gs.plugins.*;
   
   public class ColorMatrixFilterVars extends FilterVars
   {
      
      protected static var _ID_MATRIX:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      protected static var _lumR:Number = 0.212671;
      
      protected static var _lumG:Number = 0.71516;
      
      protected static var _lumB:Number = 0.072169;
      
      public var matrix:Array;
      
      public function ColorMatrixFilterVars(param1:uint = 16777215, param2:Number = 1, param3:Number = 1, param4:Number = 1, param5:Number = 1, param6:Number = 0, param7:Number = -1, param8:Boolean = false, param9:int = -1, param10:Boolean = false)
      {
         super(param8,param9,param10);
         this.matrix = _ID_MATRIX.slice();
         if(param5 != 1)
         {
            this.setBrightness(param5);
         }
         if(param4 != 1)
         {
            this.setContrast(param4);
         }
         if(param6 != 0)
         {
            this.setHue(param6);
         }
         if(param3 != 1)
         {
            this.setSaturation(param3);
         }
         if(param7 != -1)
         {
            this.setThreshold(param7);
         }
         if(param1 != 16777215)
         {
            this.setColorize(param1,param2);
         }
      }
      
      public static function createFromGeneric(param1:Object) : ColorMatrixFilterVars
      {
         var _loc2_:ColorMatrixFilterVars = null;
         if(param1 is ColorMatrixFilterVars)
         {
            _loc2_ = param1 as ColorMatrixFilterVars;
         }
         else if(param1.matrix != null)
         {
            _loc2_ = new ColorMatrixFilterVars();
            _loc2_.matrix = param1.matrix;
         }
         else
         {
            _loc2_ = new ColorMatrixFilterVars(uint(param1.colorize) || 16777215,param1.amount == null ? 1 : Number(param1.amount),param1.saturation == null ? 1 : Number(param1.saturation),param1.contrast == null ? 1 : Number(param1.contrast),param1.brightness == null ? 1 : Number(param1.brightness),Number(param1.hue) || 0,param1.threshold == null ? -1 : Number(param1.threshold),Boolean(param1.remove),param1.index == null ? -1 : int(param1.index),Boolean(param1.addFilter));
         }
         return _loc2_;
      }
      
      public function setContrast(param1:Number) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setContrast(this.matrix,param1);
      }
      
      public function setColorize(param1:uint, param2:Number = 1) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.colorize(this.matrix,param1,param2);
      }
      
      public function setHue(param1:Number) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setHue(this.matrix,param1);
      }
      
      public function setThreshold(param1:Number) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setThreshold(this.matrix,param1);
      }
      
      public function setBrightness(param1:Number) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setBrightness(this.matrix,param1);
      }
      
      public function setSaturation(param1:Number) : void
      {
         this.matrix = this.exposedVars.matrix = ColorMatrixFilterPlugin.setSaturation(this.matrix,param1);
      }
   }
}

