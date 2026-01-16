package gs.plugins
{
   import flash.display.*;
   import flash.filters.*;
   import gs.*;
   import gs.utils.tween.TweenInfo;
   
   public class FilterPlugin extends TweenPlugin
   {
      
      public static const VERSION:Number = 1.03;
      
      public static const API:Number = 1;
      
      protected var _remove:Boolean;
      
      protected var _target:Object;
      
      protected var _index:int;
      
      protected var _filter:BitmapFilter;
      
      protected var _type:Class;
      
      public function FilterPlugin()
      {
         super();
      }
      
      public function onCompleteTween() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Array = null;
         if(this._remove)
         {
            _loc2_ = this._target.filters;
            if(!(_loc2_[this._index] is this._type))
            {
               _loc1_ = _loc2_.length - 1;
               while(_loc1_ > -1)
               {
                  if(_loc2_[_loc1_] is this._type)
                  {
                     _loc2_.splice(_loc1_,1);
                     break;
                  }
                  _loc1_--;
               }
            }
            else
            {
               _loc2_.splice(this._index,1);
            }
            this._target.filters = _loc2_;
         }
      }
      
      protected function initFilter(param1:Object, param2:BitmapFilter) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:HexColorsPlugin = null;
         var _loc6_:Array = this._target.filters;
         this._index = -1;
         if(param1.index != null)
         {
            this._index = param1.index;
         }
         else
         {
            _loc4_ = _loc6_.length - 1;
            while(_loc4_ > -1)
            {
               if(_loc6_[_loc4_] is this._type)
               {
                  this._index = _loc4_;
                  break;
               }
               _loc4_--;
            }
         }
         if(this._index == -1 || _loc6_[this._index] == null || param1.addFilter == true)
         {
            this._index = param1.index != null ? int(param1.index) : int(_loc6_.length);
            _loc6_[this._index] = param2;
            this._target.filters = _loc6_;
         }
         this._filter = _loc6_[this._index];
         this._remove = Boolean(param1.remove == true);
         if(this._remove)
         {
            this.onComplete = this.onCompleteTween;
         }
         var _loc7_:Object = param1.isTV == true ? param1.exposedVars : param1;
         for(_loc3_ in _loc7_)
         {
            if(!(!(_loc3_ in this._filter) || this._filter[_loc3_] == _loc7_[_loc3_] || _loc3_ == "remove" || _loc3_ == "index" || _loc3_ == "addFilter"))
            {
               if(_loc3_ == "color" || _loc3_ == "highlightColor" || _loc3_ == "shadowColor")
               {
                  _loc5_ = new HexColorsPlugin();
                  _loc5_.initColor(this._filter,_loc3_,this._filter[_loc3_],_loc7_[_loc3_]);
                  _tweens[_tweens.length] = new TweenInfo(_loc5_,"changeFactor",0,1,_loc3_,false);
               }
               else if(_loc3_ == "quality" || _loc3_ == "inner" || _loc3_ == "knockout" || _loc3_ == "hideObject")
               {
                  this._filter[_loc3_] = _loc7_[_loc3_];
               }
               else
               {
                  addTween(this._filter,_loc3_,this._filter[_loc3_],_loc7_[_loc3_],_loc3_);
               }
            }
         }
      }
      
      override public function set changeFactor(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:TweenInfo = null;
         var _loc4_:Array = this._target.filters;
         _loc2_ = _tweens.length - 1;
         while(_loc2_ > -1)
         {
            _loc3_ = _tweens[_loc2_];
            _loc3_.target[_loc3_.property] = _loc3_.start + _loc3_.change * param1;
            _loc2_--;
         }
         if(!(_loc4_[this._index] is this._type))
         {
            this._index = _loc4_.length - 1;
            _loc2_ = _loc4_.length - 1;
            while(_loc2_ > -1)
            {
               if(_loc4_[_loc2_] is this._type)
               {
                  this._index = _loc2_;
                  break;
               }
               _loc2_--;
            }
         }
         _loc4_[this._index] = this._filter;
         this._target.filters = _loc4_;
      }
   }
}

