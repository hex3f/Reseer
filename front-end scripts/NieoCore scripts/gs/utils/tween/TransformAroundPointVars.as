package gs.utils.tween
{
   import flash.geom.Point;
   
   public class TransformAroundPointVars extends SubVars
   {
      
      public function TransformAroundPointVars(param1:Point = null, param2:Number = NaN, param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:Number = NaN, param7:Object = null, param8:Number = NaN, param9:Number = NaN)
      {
         super();
         if(param1 != null)
         {
            this.point = param1;
         }
         if(!isNaN(param2))
         {
            this.scaleX = param2;
         }
         if(!isNaN(param3))
         {
            this.scaleY = param3;
         }
         if(!isNaN(param4))
         {
            this.rotation = param4;
         }
         if(!isNaN(param5))
         {
            this.width = param5;
         }
         if(!isNaN(param6))
         {
            this.height = param6;
         }
         if(param7 != null)
         {
            this.shortRotation = param7;
         }
         if(!isNaN(param8))
         {
            this.x = param8;
         }
         if(!isNaN(param9))
         {
            this.y = param9;
         }
      }
      
      public static function createFromGeneric(param1:Object) : TransformAroundPointVars
      {
         if(param1 is TransformAroundPointVars)
         {
            return param1 as TransformAroundPointVars;
         }
         return new TransformAroundPointVars(param1.point,param1.scaleX,param1.scaleY,param1.rotation,param1.width,param1.height,param1.shortRotation,param1.x,param1.y);
      }
      
      public function set point(param1:Point) : void
      {
         this.exposedVars.point = param1;
      }
      
      public function set scaleX(param1:Number) : void
      {
         this.exposedVars.scaleX = param1;
      }
      
      public function set scaleY(param1:Number) : void
      {
         this.exposedVars.scaleY = param1;
      }
      
      public function get width() : Number
      {
         return Number(this.exposedVars.width);
      }
      
      public function get height() : Number
      {
         return Number(this.exposedVars.height);
      }
      
      public function get scale() : Number
      {
         return Number(this.exposedVars.scale);
      }
      
      public function set width(param1:Number) : void
      {
         this.exposedVars.width = param1;
      }
      
      public function get scaleX() : Number
      {
         return Number(this.exposedVars.scaleX);
      }
      
      public function get scaleY() : Number
      {
         return Number(this.exposedVars.scaleY);
      }
      
      public function get point() : Point
      {
         return this.exposedVars.point;
      }
      
      public function set y(param1:Number) : void
      {
         this.exposedVars.y = param1;
      }
      
      public function set scale(param1:Number) : void
      {
         this.exposedVars.scale = param1;
      }
      
      public function set height(param1:Number) : void
      {
         this.exposedVars.height = param1;
      }
      
      public function set x(param1:Number) : void
      {
         this.exposedVars.x = param1;
      }
      
      public function get x() : Number
      {
         return Number(this.exposedVars.x);
      }
      
      public function get y() : Number
      {
         return Number(this.exposedVars.y);
      }
      
      public function get shortRotation() : Object
      {
         return this.exposedVars.shortRotation;
      }
      
      public function set shortRotation(param1:Object) : void
      {
         this.exposedVars.shortRotation = param1;
      }
      
      public function set rotation(param1:Number) : void
      {
         this.exposedVars.rotation = param1;
      }
      
      public function get rotation() : Number
      {
         return Number(this.exposedVars.rotation);
      }
   }
}

