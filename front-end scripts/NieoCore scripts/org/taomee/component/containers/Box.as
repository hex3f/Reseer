package org.taomee.component.containers
{
   import org.taomee.component.Container;
   import org.taomee.component.layout.FlowLayout;
   
   public class Box extends Container
   {
      
      private var _dir:String;
      
      private var _valign:int;
      
      private var _halign:int;
      
      public function Box(param1:int = 5)
      {
         super();
         layout = new FlowLayout(FlowLayout.X_AXIS);
         this.gap = param1;
      }
      
      private function updateLayout() : void
      {
         if(this._dir == BoxDirection.HORIZONTAL)
         {
            (layout as FlowLayout).axis = FlowLayout.X_AXIS;
         }
         else
         {
            (layout as FlowLayout).axis = FlowLayout.Y_AXIS;
         }
      }
      
      public function set valign(param1:uint) : void
      {
         this._valign = param1;
         (layout as FlowLayout).valign = param1;
      }
      
      public function set gap(param1:uint) : void
      {
         (layout as FlowLayout).gap = param1;
      }
      
      public function get gap() : uint
      {
         return (layout as FlowLayout).gap;
      }
      
      public function set halign(param1:uint) : void
      {
         this._halign = param1;
         (layout as FlowLayout).halign = param1;
      }
      
      public function set direction(param1:String) : void
      {
         if(param1 == this._dir)
         {
            return;
         }
         this._dir = param1;
         this.updateLayout();
      }
      
      public function get direction() : String
      {
         return this._dir;
      }
   }
}

