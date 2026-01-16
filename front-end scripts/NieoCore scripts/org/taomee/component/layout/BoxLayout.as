package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class BoxLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static var TYPE:String = "boxLayout";
      
      public static const X_AXIS:uint = 0;
      
      public static const Y_AXIS:uint = 1;
      
      private var _axis:uint;
      
      private var _gap:int;
      
      public function BoxLayout(param1:int = 0, param2:int = 5)
      {
         super();
         this._axis = param1;
         this._gap = param2;
      }
      
      public function get axis() : uint
      {
         return this._axis;
      }
      
      public function set axis(param1:uint) : void
      {
         if(this._axis == param1)
         {
            return;
         }
         this._axis = param1;
         broadcast();
      }
      
      public function set gap(param1:int) : void
      {
         if(this._gap == param1)
         {
            return;
         }
         this._gap = param1;
         broadcast();
      }
      
      private function layoutY() : void
      {
         var _loc1_:UIComponent = null;
         var _loc2_:uint = container.compList.length;
         var _loc3_:Number = (container.height - (_loc2_ - 1) * this._gap) / _loc2_;
         var _loc4_:Number = 0;
         for each(_loc1_ in container.compList)
         {
            if(_loc4_ == 0)
            {
               _loc1_.y = _loc3_ * _loc4_;
            }
            else
            {
               _loc1_.y = _loc3_ * _loc4_ + this._gap;
            }
            _loc1_.x = 0;
            _loc1_.height = _loc3_;
            _loc1_.width = container.width;
            _loc4_++;
         }
      }
      
      override public function getType() : String
      {
         return TYPE + this._axis.toString() + this._gap.toString();
      }
      
      override public function doLayout() : void
      {
         if(this._axis == Y_AXIS)
         {
            this.layoutY();
         }
         else
         {
            this.layoutX();
         }
      }
      
      public function get gap() : int
      {
         return this._gap;
      }
      
      private function layoutX() : void
      {
         var _loc1_:UIComponent = null;
         var _loc2_:uint = container.compList.length;
         var _loc3_:Number = (container.width - (_loc2_ - 1) * this._gap) / _loc2_;
         var _loc4_:Number = 0;
         for each(_loc1_ in container.compList)
         {
            if(_loc4_ == 0)
            {
               _loc1_.x = _loc3_ * _loc4_;
            }
            else
            {
               _loc1_.x = _loc3_ * _loc4_ + this._gap;
            }
            _loc1_.y = 0;
            _loc1_.width = _loc3_;
            _loc1_.height = container.height;
            _loc4_++;
         }
      }
   }
}

