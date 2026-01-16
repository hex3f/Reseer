package gs.utils.tween
{
   public class ColorTransformVars extends SubVars
   {
      
      public function ColorTransformVars(param1:Number = NaN, param2:Number = NaN, param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:Number = NaN, param7:Number = NaN, param8:Number = NaN, param9:Number = NaN, param10:Number = NaN, param11:Number = NaN, param12:Number = NaN)
      {
         super();
         if(!isNaN(param1))
         {
            this.tint = uint(param1);
         }
         if(!isNaN(param2))
         {
            this.tintAmount = param2;
         }
         if(!isNaN(param3))
         {
            this.exposure = param3;
         }
         if(!isNaN(param4))
         {
            this.brightness = param4;
         }
         if(!isNaN(param5))
         {
            this.redMultiplier = param5;
         }
         if(!isNaN(param6))
         {
            this.greenMultiplier = param6;
         }
         if(!isNaN(param7))
         {
            this.blueMultiplier = param7;
         }
         if(!isNaN(param8))
         {
            this.alphaMultiplier = param8;
         }
         if(!isNaN(param9))
         {
            this.redOffset = param9;
         }
         if(!isNaN(param10))
         {
            this.greenOffset = param10;
         }
         if(!isNaN(param11))
         {
            this.blueOffset = param11;
         }
         if(!isNaN(param12))
         {
            this.alphaOffset = param12;
         }
      }
      
      public static function createFromGeneric(param1:Object) : ColorTransformVars
      {
         if(param1 is ColorTransformVars)
         {
            return param1 as ColorTransformVars;
         }
         return new ColorTransformVars(param1.tint,param1.tintAmount,param1.exposure,param1.brightness,param1.redMultiplier,param1.greenMultiplier,param1.blueMultiplier,param1.alphaMultiplier,param1.redOffset,param1.greenOffset,param1.blueOffset,param1.alphaOffset);
      }
      
      public function get tint() : Number
      {
         return Number(this.exposedVars.tint);
      }
      
      public function get redOffset() : Number
      {
         return Number(this.exposedVars.redOffset);
      }
      
      public function set blueMultiplier(param1:Number) : void
      {
         this.exposedVars.blueMultiplier = param1;
      }
      
      public function get exposure() : Number
      {
         return Number(this.exposedVars.exposure);
      }
      
      public function set greenMultiplier(param1:Number) : void
      {
         this.exposedVars.greenMultiplier = param1;
      }
      
      public function get blueOffset() : Number
      {
         return Number(this.exposedVars.blueOffset);
      }
      
      public function set exposure(param1:Number) : void
      {
         this.exposedVars.exposure = param1;
      }
      
      public function set redOffset(param1:Number) : void
      {
         this.exposedVars.redOffset = param1;
      }
      
      public function get brightness() : Number
      {
         return Number(this.exposedVars.brightness);
      }
      
      public function get alphaOffset() : Number
      {
         return Number(this.exposedVars.alphaOffset);
      }
      
      public function set blueOffset(param1:Number) : void
      {
         this.exposedVars.blueOffset = param1;
      }
      
      public function set brightness(param1:Number) : void
      {
         this.exposedVars.brightness = param1;
      }
      
      public function set redMultiplier(param1:Number) : void
      {
         this.exposedVars.redMultiplier = param1;
      }
      
      public function set tintAmount(param1:Number) : void
      {
         this.exposedVars.tintAmount = param1;
      }
      
      public function set alphaOffset(param1:Number) : void
      {
         this.exposedVars.alphaOffset = param1;
      }
      
      public function get greenMultiplier() : Number
      {
         return Number(this.exposedVars.greenMultiplier);
      }
      
      public function set greenOffset(param1:Number) : void
      {
         this.exposedVars.greenOffset = param1;
      }
      
      public function get redMultiplier() : Number
      {
         return Number(this.exposedVars.redMultiplier);
      }
      
      public function get tintAmount() : Number
      {
         return Number(this.exposedVars.tintAmount);
      }
      
      public function get greenOffset() : Number
      {
         return Number(this.exposedVars.greenOffset);
      }
      
      public function get blueMultiplier() : Number
      {
         return Number(this.exposedVars.blueMultiplier);
      }
      
      public function set tint(param1:Number) : void
      {
         this.exposedVars.tint = param1;
      }
      
      public function set alphaMultiplier(param1:Number) : void
      {
         this.exposedVars.alphaMultiplier = param1;
      }
      
      public function get alphaMultiplier() : Number
      {
         return Number(this.exposedVars.alphaMultiplier);
      }
   }
}

