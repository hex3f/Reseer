package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class FlowLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static const TYPE:String = "flowLayout";
      
      public static const CENTER:int = 0;
      
      public static const LEFT:int = 1;
      
      public static const RIGHT:int = 2;
      
      public static const TOP:uint = 1;
      
      public static const MIDLLE:uint = 0;
      
      public static const BOTTOM:uint = 2;
      
      public static const X_AXIS:uint = 0;
      
      public static const Y_AXIS:uint = 1;
      
      private var _axis:uint;
      
      private var _halign:uint;
      
      private var _valign:uint;
      
      private var _gap:int;
      
      public function FlowLayout(param1:uint = 1, param2:uint = 1, param3:uint = 1, param4:int = 5)
      {
         super();
         this._axis = param1;
         this._gap = param4;
         this._halign = param2;
         this._valign = param3;
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
      
      public function get gap() : int
      {
         return this._gap;
      }
      
      public function get halign() : uint
      {
         return this._halign;
      }
      
      private function layoutY() : void
      {
         var _loc4_:Number = NaN;
         var _loc1_:UIComponent = null;
         var _loc2_:UIComponent = null;
         var _loc3_:Number = NaN;
         _loc4_ = 0;
         var _loc5_:uint = container.compList.length;
         for each(_loc2_ in container.compList)
         {
            _loc2_.x = _loc2_.y = 0;
            _loc4_ += _loc2_.height;
            if(Boolean(_loc1_))
            {
               _loc2_.y = _loc1_.y + _loc1_.height + this.gap;
            }
            _loc1_ = _loc2_;
         }
         _loc4_ += this.gap * (_loc5_ - 1);
         switch(this.valign)
         {
            case BOTTOM:
               _loc3_ = container.height - _loc4_;
               break;
            case MIDLLE:
               _loc3_ = (container.height - _loc4_) / 2;
               break;
            default:
               _loc3_ = 0;
         }
         for each(_loc2_ in container.compList)
         {
            _loc2_.y += _loc3_;
            switch(this.halign)
            {
               case RIGHT:
                  _loc2_.x = container.width - _loc2_.width;
                  break;
               case CENTER:
                  _loc2_.x = (container.width - _loc2_.width) / 2;
            }
         }
      }
      
      override public function getType() : String
      {
         return TYPE + this.axis.toString() + this.gap.toString();
      }
      
      override public function doLayout() : void
      {
         if(this.axis == Y_AXIS)
         {
            this.layoutY();
         }
         else
         {
            this.layoutX();
         }
      }
      
      public function get valign() : uint
      {
         return this._valign;
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
      
      public function set gap(param1:int) : void
      {
         if(param1 == this._gap)
         {
            return;
         }
         this._gap = param1;
         broadcast();
      }
      
      private function layoutX() : void
      {
         var _loc1_:UIComponent = null;
         var _loc2_:UIComponent = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = 0;
         var _loc5_:uint = container.compList.length;
         for each(_loc2_ in container.compList)
         {
            _loc2_.x = _loc2_.y = 0;
            _loc4_ += _loc2_.width;
            if(Boolean(_loc1_))
            {
               _loc2_.x = _loc1_.x + _loc1_.width + this.gap;
            }
            _loc1_ = _loc2_;
         }
         _loc4_ += this.gap * (_loc5_ - 1);
         switch(this.halign)
         {
            case RIGHT:
               _loc3_ = container.width - _loc4_;
               break;
            case CENTER:
               _loc3_ = (container.width - _loc4_) / 2;
               break;
            default:
               _loc3_ = 0;
         }
         for each(_loc2_ in container.compList)
         {
            _loc2_.x += _loc3_;
            switch(this.valign)
            {
               case BOTTOM:
                  _loc2_.y = container.height - _loc2_.height;
                  break;
               case MIDLLE:
                  _loc2_.y = (container.height - _loc2_.height) / 2;
            }
         }
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
   }
}

