package org.taomee.component.layout
{
   import org.taomee.component.UIComponent;
   
   public class FitSizeLayout extends EmptyLayout implements ILayoutManager
   {
      
      private static const TYPE:String = "fitSizeLayout";
      
      public function FitSizeLayout()
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
            _loc1_.x = _loc1_.y = 0;
            _loc1_.setSizeWH(container.width,container.height);
         }
      }
   }
}

