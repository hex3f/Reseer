package gs.plugins
{
   import flash.display.*;
   import gs.*;
   
   public class FastTransformPlugin extends TweenPlugin
   {
      
      public static const VERSION:Number = 1.02;
      
      public static const API:Number = 1;
      
      protected var widthStart:Number;
      
      protected var rotationStart:Number;
      
      protected var xChange:Number = 0;
      
      protected var yChange:Number = 0;
      
      protected var xStart:Number;
      
      protected var rotationChange:Number = 0;
      
      protected var scaleYStart:Number;
      
      protected var widthChange:Number = 0;
      
      protected var scaleXChange:Number = 0;
      
      protected var scaleYChange:Number = 0;
      
      protected var yStart:Number;
      
      protected var _target:DisplayObject;
      
      protected var scaleXStart:Number;
      
      protected var heightChange:Number = 0;
      
      protected var heightStart:Number;
      
      public function FastTransformPlugin()
      {
         super();
         this.propName = "fastTransform";
         this.overwriteProps = [];
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         if(this.xChange != 0)
         {
            this._target.x = this.xStart + param1 * this.xChange;
         }
         if(this.yChange != 0)
         {
            this._target.y = this.yStart + param1 * this.yChange;
         }
         if(this.widthChange != 0)
         {
            this._target.width = this.widthStart + param1 * this.widthChange;
         }
         if(this.heightChange != 0)
         {
            this._target.height = this.heightStart + param1 * this.heightChange;
         }
         if(this.scaleXChange != 0)
         {
            this._target.scaleX = this.scaleXStart + param1 * this.scaleXChange;
         }
         if(this.scaleYChange != 0)
         {
            this._target.scaleY = this.scaleYStart + param1 * this.scaleYChange;
         }
         if(this.rotationChange != 0)
         {
            this._target.rotation = this.rotationStart + param1 * this.rotationChange;
         }
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         this._target = param1 as DisplayObject;
         if("x" in param2)
         {
            this.xStart = this._target.x;
            this.xChange = typeof param2.x == "number" ? param2.x - this._target.x : Number(param2.x);
            this.overwriteProps[this.overwriteProps.length] = "x";
         }
         if("y" in param2)
         {
            this.yStart = this._target.y;
            this.yChange = typeof param2.y == "number" ? param2.y - this._target.y : Number(param2.y);
            this.overwriteProps[this.overwriteProps.length] = "y";
         }
         if("width" in param2)
         {
            this.widthStart = this._target.width;
            this.widthChange = typeof param2.width == "number" ? param2.width - this._target.width : Number(param2.width);
            this.overwriteProps[this.overwriteProps.length] = "width";
         }
         if("height" in param2)
         {
            this.heightStart = this._target.height;
            this.heightChange = typeof param2.height == "number" ? param2.height - this._target.height : Number(param2.height);
            this.overwriteProps[this.overwriteProps.length] = "height";
         }
         if("scaleX" in param2)
         {
            this.scaleXStart = this._target.scaleX;
            this.scaleXChange = typeof param2.scaleX == "number" ? param2.scaleX - this._target.scaleX : Number(param2.scaleX);
            this.overwriteProps[this.overwriteProps.length] = "scaleX";
         }
         if("scaleY" in param2)
         {
            this.scaleYStart = this._target.scaleY;
            this.scaleYChange = typeof param2.scaleY == "number" ? param2.scaleY - this._target.scaleY : Number(param2.scaleY);
            this.overwriteProps[this.overwriteProps.length] = "scaleY";
         }
         if("rotation" in param2)
         {
            this.rotationStart = this._target.rotation;
            this.rotationChange = typeof param2.rotation == "number" ? param2.rotation - this._target.rotation : Number(param2.rotation);
            this.overwriteProps[this.overwriteProps.length] = "rotation";
         }
         return true;
      }
      
      override public function killProps(param1:Object) : void
      {
         var _loc2_:String = null;
         for(_loc2_ in param1)
         {
            if(_loc2_ + "Change" in this && !isNaN(this[_loc2_ + "Change"]))
            {
               this[_loc2_ + "Change"] = 0;
            }
         }
         super.killProps(param1);
      }
   }
}

