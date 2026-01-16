package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class SoftBoxLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static const TYPE:String = "softBoxLayout";
      
      public static const CENTER:uint = 0;
      
      public static const LEFT:uint = 1;
      
      public static const TOP:uint = 1;
      
      public static const RIGHT:uint = 2;
      
      public static const BOTTOM:uint = 2;
      
      public static const X_AXIS:uint = 0;
      
      public static const Y_AXIS:uint = 1;
      
      private var _axis:uint;
      
      private var _align:uint;
      
      private var _gap:int;
      
      public function SoftBoxLayout(param1:int = 0, param2:int = 5, param3:int = 0)
      {
         super();
         this._axis = param1;
         this._gap = param2;
         this._align = param3;
      }
      
      public function get axis() : uint
      {
         return this._axis;
      }
      
      public function set axis(param1:uint) : void
      {
         if(param1 == this._axis)
         {
            return;
         }
         this._axis = param1;
         broadcast();
      }
      
      public function get align() : uint
      {
         return this._align;
      }
      
      public function set align(param1:uint) : void
      {
         if(param1 == this._align)
         {
            return;
         }
         this._align = param1;
         broadcast();
      }
      
      private function layoutX() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:UIComponent = null;
         var _loc3_:UIComponent = null;
         var _loc4_:UIComponent = null;
         var _loc5_:Number = 0;
         var _loc6_:int = int(container.compList.length);
         var _loc7_:Number = 0;
         for each(_loc2_ in container.compList)
         {
            _loc2_.x = _loc2_.y = 0;
            _loc5_ += _loc2_.width;
            _loc2_.height = container.height;
            _loc7_++;
         }
         if(_loc6_ > 0)
         {
            _loc5_ += (_loc6_ - 1) * this.gap;
         }
         switch(this.align)
         {
            case RIGHT:
               _loc1_ = container.width - _loc5_;
               break;
            case CENTER:
               _loc1_ = (container.width - _loc5_) / 2;
               break;
            default:
               _loc1_ = 0;
         }
         var _loc8_:Number = 0;
         for each(_loc3_ in container.compList)
         {
            if(_loc8_ == 0)
            {
               _loc3_.x = _loc1_;
            }
            else
            {
               _loc4_ = container.compList[_loc8_ - 1];
               _loc3_.x = _loc4_.x + _loc4_.width + this.gap;
            }
            _loc8_++;
         }
      }
      
      private function layoutY() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:UIComponent = null;
         var _loc3_:UIComponent = null;
         var _loc4_:UIComponent = null;
         var _loc5_:Number = 0;
         var _loc6_:int = int(container.compList.length);
         var _loc7_:Number = 0;
         for each(_loc2_ in container.compList)
         {
            _loc2_.x = _loc2_.y = 0;
            _loc5_ += _loc2_.height;
            _loc2_.width = container.width;
            _loc7_++;
         }
         if(_loc6_ > 0)
         {
            _loc5_ += (_loc6_ - 1) * this.gap;
         }
         switch(this.align)
         {
            case RIGHT:
               _loc1_ = container.height - _loc5_;
               break;
            case CENTER:
               _loc1_ = (container.height - _loc5_) / 2;
               break;
            default:
               _loc1_ = 0;
         }
         var _loc8_:Number = 0;
         for each(_loc3_ in container.compList)
         {
            if(_loc8_ == 0)
            {
               _loc3_.y = _loc1_;
            }
            else
            {
               _loc4_ = container.compList[_loc8_ - 1];
               _loc3_.y = _loc4_.y + _loc4_.height + this.gap;
            }
            _loc8_++;
         }
      }
      
      override public function getType() : String
      {
         return TYPE + this.axis.toString() + this.gap.toString() + this.align.toString();
      }
      
      public function get gap() : int
      {
         return this._gap;
      }
      
      public function set gap(param1:int) : void
      {
         if(param1 == this._gap)
         {
            return;
         }
         this._gap = param1;
         broadcast();
      }
      
      override public function doLayout() : void
      {
         if(this.axis == X_AXIS)
         {
            this.layoutX();
         }
         else
         {
            this.layoutY();
         }
      }
   }
}

