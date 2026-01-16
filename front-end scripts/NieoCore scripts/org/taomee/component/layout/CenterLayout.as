package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class CenterLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static const TYPE:String = "centerLayout";
      
      public function CenterLayout()
      {
         super();
      }
      
      override public function getType() : String
      {
         return TYPE;
      }
      
      override public function doLayout() : void
      {
         var _loc1_:UIComponent = null;
         for each(_loc1_ in container.compList)
         {
            _loc1_.x = (container.width - _loc1_.width) / 2;
            _loc1_.y = (container.height - _loc1_.height) / 2;
         }
      }
   }
}

