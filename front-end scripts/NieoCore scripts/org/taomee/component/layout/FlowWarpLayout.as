package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class FlowWarpLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static const TYPE:String = "flowWarpLayout";
      
      public static const CENTER:int = 0;
      
      public static const LEFT:int = 1;
      
      public static const RIGHT:int = 2;
      
      public static const TOP:uint = 1;
      
      public static const MIDLLE:uint = 0;
      
      public static const BOTTOM:uint = 2;
      
      private var initialHeight:Number;
      
      private var _hgap:int;
      
      private var initialWidth:Number;
      
      private var _valign:uint;
      
      private var _halign:uint;
      
      private var _vgap:int;
      
      public function FlowWarpLayout(param1:uint = 1, param2:uint = 0, param3:int = 5, param4:int = 5)
      {
         super();
         this._halign = param1;
         this._valign = param2;
         this._hgap = param3;
         this._vgap = param4;
      }
      
      public function set vgap(param1:int) : void
      {
         if(param1 == this._vgap)
         {
            return;
         }
         this._vgap = param1;
         broadcast();
      }
      
      public function get valign() : uint
      {
         return this._valign;
      }
      
      override public function doLayout() : void
      {
         var _loc1_:UIComponent = null;
         this.initialWidth = this.initialHeight = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = 0;
         var _loc4_:Number = compSprite.numChildren;
         var _loc5_:Number = 0;
         for each(_loc1_ in container.compList)
         {
            if(this.initialWidth + _loc1_.width + this.hgap * (_loc5_ - _loc2_) > container.width)
            {
               this.moveComponent(_loc2_,_loc5_ - 1,this.initialWidth,_loc3_);
               _loc2_ = _loc5_;
               this.initialWidth = _loc1_.width;
               _loc3_ = _loc1_.height;
               if(_loc5_ == _loc4_ - 1)
               {
                  this.moveComponent(_loc2_,_loc4_ - 1,this.initialWidth,_loc3_);
               }
            }
            else
            {
               this.initialWidth += _loc1_.width;
               _loc3_ = Math.max(_loc3_,_loc1_.height);
               if(_loc5_ == _loc4_ - 1)
               {
                  this.moveComponent(_loc2_,_loc4_ - 1,this.initialWidth,_loc3_);
               }
            }
            _loc5_++;
         }
      }
      
      public function get halign() : uint
      {
         return this._halign;
      }
      
      public function set valign(param1:uint) : void
      {
         if(param1 == this._valign)
         {
            return;
         }
         this._valign = param1;
         broadcast();
      }
      
      public function get vgap() : int
      {
         return this._vgap;
      }
      
      public function set hgap(param1:int) : void
      {
         if(param1 == this._hgap)
         {
            return;
         }
         this._hgap = param1;
         broadcast();
      }
      
      private function moveComponent(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         var _loc5_:Number = NaN;
         var _loc6_:UIComponent = null;
         var _loc7_:UIComponent = null;
         switch(this.halign)
         {
            case RIGHT:
               _loc5_ = container.width - param3 - this.hgap * (param2 - param1);
               break;
            case CENTER:
               _loc5_ = (container.width - param3 - this.hgap * (param2 - param1)) / 2;
               break;
            default:
               _loc5_ = 0;
         }
         var _loc8_:int = param1;
         while(_loc8_ < param2 + 1)
         {
            _loc6_ = container.compList[_loc8_] as UIComponent;
            if(_loc8_ == param1)
            {
               _loc6_.x = _loc5_;
            }
            else
            {
               _loc7_ = container.compList[_loc8_ - 1] as UIComponent;
               _loc6_.x = _loc7_.x + _loc7_.width + this.hgap;
            }
            switch(this.valign)
            {
               case MIDLLE:
                  _loc6_.y = (param4 - _loc6_.height) / 2 + this.initialHeight;
                  break;
               case BOTTOM:
                  _loc6_.y = param4 - _loc6_.height + this.initialHeight;
                  break;
               default:
                  _loc6_.y = this.initialHeight;
            }
            _loc8_++;
         }
         this.initialHeight += param4 + this.vgap;
      }
      
      public function get hgap() : int
      {
         return this._hgap;
      }
      
      override public function getType() : String
      {
         return TYPE + this.halign.toString() + this.valign.toString() + this.hgap.toString() + this.vgap.toString();
      }
      
      public function set halign(param1:uint) : void
      {
         if(param1 == this._halign)
         {
            return;
         }
         this._halign = param1;
         broadcast();
      }
   }
}

