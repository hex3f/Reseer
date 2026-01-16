package gs.plugins
{
   import flash.display.*;
   import flash.geom.ColorTransform;
   import gs.*;
   
   public class ColorTransformPlugin extends TintPlugin
   {
      
      public static const VERSION:Number = 1.01;
      
      public static const API:Number = 1;
      
      public function ColorTransformPlugin()
      {
         super();
         this.propName = "colorTransform";
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var _loc7_:* = undefined;
         var _loc4_:String = null;
         var _loc5_:Number = NaN;
         if(!(param1 is DisplayObject))
         {
            return false;
         }
         var _loc6_:ColorTransform = param1.transform.colorTransform;
         if(param2.isTV == true)
         {
            param2 = param2.exposedVars;
         }
         for(_loc4_ in param2)
         {
            if(_loc4_ == "tint" || _loc4_ == "color")
            {
               if(param2[_loc4_] != null)
               {
                  _loc6_.color = int(param2[_loc4_]);
               }
            }
            else if(!(_loc4_ == "tintAmount" || _loc4_ == "exposure" || _loc4_ == "brightness"))
            {
               _loc6_[_loc4_] = param2[_loc4_];
            }
         }
         if(!isNaN(param2.tintAmount))
         {
            _loc5_ = param2.tintAmount / (1 - (_loc6_.redMultiplier + _loc6_.greenMultiplier + _loc6_.blueMultiplier) / 3);
            _loc6_.redOffset *= _loc5_;
            _loc6_.greenOffset *= _loc5_;
            _loc6_.blueOffset *= _loc5_;
            _loc7_ = 1 - param2.tintAmount;
            _loc6_.blueMultiplier = 1 - param2.tintAmount;
            _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc7_;
         }
         else if(!isNaN(param2.exposure))
         {
            _loc7_ = 255 * (param2.exposure - 1);
            _loc6_.blueOffset = 255 * (param2.exposure - 1);
            _loc6_.redOffset = _loc6_.greenOffset = _loc7_;
            _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc6_.blueMultiplier = 1;
         }
         else if(!isNaN(param2.brightness))
         {
            _loc6_.redOffset = _loc6_.greenOffset = _loc6_.blueOffset = Math.max(0,(param2.brightness - 1) * 255);
            _loc7_ = 1 - Math.abs(param2.brightness - 1);
            _loc6_.blueMultiplier = 1 - Math.abs(param2.brightness - 1);
            _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc7_;
         }
         if(param3.exposedVars.alpha != undefined && param2.alphaMultiplier == undefined)
         {
            _loc6_.alphaMultiplier = param3.exposedVars.alpha;
            param3.killVars({"alpha":1});
         }
         init(param1 as DisplayObject,_loc6_);
         return true;
      }
   }
}

