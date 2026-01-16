package gs.plugins
{
   import flash.display.*;
   import gs.*;
   
   public class ScalePlugin extends TweenPlugin
   {
      
      public static const VERSION:Number = 1.11;
      
      public static const API:Number = 1;
      
      protected var _changeX:Number;
      
      protected var _changeY:Number;
      
      protected var _target:Object;
      
      protected var _startX:Number;
      
      protected var _startY:Number;
      
      public function ScalePlugin()
      {
         super();
         this.propName = "scale";
         this.overwriteProps = ["scaleX","scaleY","width","height"];
      }
      
      override public function killProps(param1:Object) : void
      {
         var _loc2_:int = this.overwriteProps.length - 1;
         while(_loc2_ > -1)
         {
            if(this.overwriteProps[_loc2_] in param1)
            {
               this.overwriteProps = [];
               return;
            }
            _loc2_--;
         }
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!param1.hasOwnProperty("scaleX"))
         {
            return false;
         }
         this._target = param1;
         this._startX = this._target.scaleX;
         this._startY = this._target.scaleY;
         if(typeof param2 == "number")
         {
            this._changeX = param2 - this._startX;
            this._changeY = param2 - this._startY;
         }
         else
         {
            this._changeX = this._changeY = Number(param2);
         }
         return true;
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         this._target.scaleX = this._startX + param1 * this._changeX;
         this._target.scaleY = this._startY + param1 * this._changeY;
      }
   }
}

