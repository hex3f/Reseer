package gs.utils.tween
{
   public dynamic class TweenMaxVars extends TweenLiteVars
   {
      
      public static const version:Number = 2.01;
      
      protected var _roundProps:Array;
      
      public var loop:Number;
      
      public var yoyo:Number;
      
      public var onCompleteListener:Function;
      
      public var onStartListener:Function;
      
      public var onUpdateListener:Function;
      
      public function TweenMaxVars(param1:Object = null)
      {
         super(param1);
      }
      
      public function get roundProps() : Array
      {
         return this._roundProps;
      }
      
      public function set roundProps(param1:Array) : void
      {
         this._roundProps = _exposedVars.roundProps = param1;
      }
      
      override protected function appendCloneVars(param1:Object, param2:Object) : void
      {
         super.appendCloneVars(param1,param2);
         var _loc3_:Array = ["onStartListener","onUpdateListener","onCompleteListener","onCompleteAllListener","yoyo","loop"];
         var _loc4_:int = _loc3_.length - 1;
         while(_loc4_ > -1)
         {
            param1[_loc3_[_loc4_]] = this[_loc3_[_loc4_]];
            _loc4_--;
         }
         param2._roundProps = this._roundProps;
      }
      
      override public function clone() : TweenLiteVars
      {
         var _loc1_:Object = {"protectedVars":{}};
         this.appendCloneVars(_loc1_,_loc1_.protectedVars);
         return new TweenMaxVars(_loc1_);
      }
   }
}

