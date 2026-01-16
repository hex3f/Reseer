package gs.plugins
{
   import flash.display.*;
   import gs.*;
   
   public class SetSizePlugin extends TweenPlugin
   {
      
      public static const VERSION:Number = 1.01;
      
      public static const API:Number = 1;
      
      protected var _setWidth:Boolean;
      
      public var width:Number;
      
      public var height:Number;
      
      protected var _hasSetSize:Boolean;
      
      protected var _setHeight:Boolean;
      
      protected var _target:Object;
      
      public function SetSizePlugin()
      {
         super();
         this.propName = "setSize";
         this.overwriteProps = ["setSize","width","height","scaleX","scaleY"];
         this.round = true;
      }
      
      override public function killProps(param1:Object) : void
      {
         super.killProps(param1);
         if(_tweens.length == 0 || "setSize" in param1)
         {
            this.overwriteProps = [];
         }
      }
      
      override public function onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         this._target = param1;
         this._hasSetSize = Boolean("setSize" in this._target);
         if("width" in param2 && this._target.width != param2.width)
         {
            addTween(this._hasSetSize ? this : this._target,"width",this._target.width,param2.width,"width");
            this._setWidth = this._hasSetSize;
         }
         if("height" in param2 && this._target.height != param2.height)
         {
            addTween(this._hasSetSize ? this : this._target,"height",this._target.height,param2.height,"height");
            this._setHeight = this._hasSetSize;
         }
         return true;
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         updateTweens(param1);
         if(this._hasSetSize)
         {
            this._target.setSize(this._setWidth ? this.width : this._target.width,this._setHeight ? this.height : this._target.height);
         }
      }
   }
}

