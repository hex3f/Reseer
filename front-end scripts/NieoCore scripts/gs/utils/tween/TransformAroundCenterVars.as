package gs.utils.tween
{
   public class TransformAroundCenterVars extends TransformAroundPointVars
   {
      
      public function TransformAroundCenterVars(param1:Number = NaN, param2:Number = NaN, param3:Number = NaN, param4:Number = NaN, param5:Number = NaN, param6:Object = null, param7:Number = NaN, param8:Number = NaN)
      {
         super(null,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public static function createFromGeneric(param1:Object) : TransformAroundCenterVars
      {
         if(param1 is TransformAroundCenterVars)
         {
            return param1 as TransformAroundCenterVars;
         }
         return new TransformAroundCenterVars(param1.scaleX,param1.scaleY,param1.rotation,param1.width,param1.height,param1.shortRotation,param1.x,param1.y);
      }
   }
}

