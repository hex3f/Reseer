package org.taomee.component.geom
{
   public class IntDimension
   {
      
      private var _height:int = 0;
      
      private var _width:int = 0;
      
      public function IntDimension(param1:int = 0, param2:int = 0)
      {
         super();
         this._width = param1;
         this._height = param2;
      }
      
      public function setSize(param1:IntDimension) : void
      {
         this._width = param1.width;
         this._height = param1.height;
      }
      
      public function setSizeWH(param1:int, param2:int) : void
      {
         this._width = param1;
         this._height = param2;
      }
      
      public function set height(param1:int) : void
      {
         this._height = param1;
      }
      
      public function set width(param1:int) : void
      {
         this._width = param1;
      }
      
      public function get width() : int
      {
         return this._width;
      }
      
      public function get height() : int
      {
         return this._height;
      }
   }
}

