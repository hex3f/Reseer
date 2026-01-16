package org.taomee.component.control
{
   import flash.display.DisplayObject;
   import org.taomee.component.UIComponent;
   
   public class UIMovieClip extends UIComponent
   {
      
      public function UIMovieClip(param1:DisplayObject = null)
      {
         super();
         bgMC.mouseChildren = true;
         if(Boolean(param1))
         {
            this.append(param1);
         }
      }
      
      override public function get numChildren() : int
      {
         return bgMC.numChildren;
      }
      
      override public function get width() : Number
      {
         return bgMC.width;
      }
      
      override public function get height() : Number
      {
         return bgMC.height;
      }
      
      override public function getChildByName(param1:String) : DisplayObject
      {
         return bgMC.getChildByName(param1);
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return bgMC.getChildAt(param1);
      }
      
      public function append(param1:DisplayObject) : DisplayObject
      {
         bgMC.addChild(param1);
         return param1;
      }
      
      override public function getChildIndex(param1:DisplayObject) : int
      {
         return bgMC.getChildIndex(param1);
      }
      
      override public function set width(param1:Number) : void
      {
         bgMC.width = param1;
      }
      
      public function appendAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         bgMC.addChildAt(param1,param2);
         return param1;
      }
      
      override public function set height(param1:Number) : void
      {
         bgMC.height = param1;
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         return bgMC.setChildIndex(param1,param2);
      }
   }
}

