package gs.plugins
{
   import flash.display.*;
   import gs.*;
   
   public class FrameLabelPlugin extends FramePlugin
   {
      
      public static const VERSION:Number = 1.01;
      
      public static const API:Number = 1;
      
      public function FrameLabelPlugin()
      {
         super();
         this.propName = "frameLabel";
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var _loc4_:int = 0;
         if(!param3.target is MovieClip)
         {
            return false;
         }
         _target = param1 as MovieClip;
         this.frame = _target.currentFrame;
         var _loc5_:Array = _target.currentLabels;
         var _loc6_:String = param2;
         var _loc7_:int = _target.currentFrame;
         _loc4_ = _loc5_.length - 1;
         while(_loc4_ > -1)
         {
            if(_loc5_[_loc4_].name == _loc6_)
            {
               _loc7_ = int(_loc5_[_loc4_].frame);
               break;
            }
            _loc4_--;
         }
         if(this.frame != _loc7_)
         {
            addTween(this,"frame",this.frame,_loc7_,"frame");
         }
         return true;
      }
   }
}

