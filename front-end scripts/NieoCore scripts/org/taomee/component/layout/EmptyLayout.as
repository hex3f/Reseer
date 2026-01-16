package org.taomee.component.layout
{
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import org.taomee.component.Container;
   import org.taomee.component.UIComponent;
   import org.taomee.component.event.LayoutEvent;
   
   [Event(name="layoutSetChanged",type="org.taomee.component.event.LayoutEvent")]
   public class EmptyLayout extends EventDispatcher implements ILayoutManager
   {
      
      private static const TYPE:String = "emptyLayout";
      
      protected var container:Container;
      
      protected var compSprite:Sprite;
      
      public function EmptyLayout()
      {
         super();
      }
      
      protected function broadcast() : void
      {
         dispatchEvent(new LayoutEvent(LayoutEvent.LAYOUT_SET_CHANGED));
      }
      
      public function destroy() : void
      {
         this.container = null;
         this.compSprite = null;
      }
      
      public function set layoutObj(param1:Container) : void
      {
         this.container = param1;
         this.compSprite = param1.getContainSprite();
      }
      
      public function removeLayoutComponent(param1:UIComponent) : void
      {
         if(!this.compSprite.contains(param1))
         {
            throw new Error(param1 + "不是" + this.container + "的子级，不能被移除");
         }
         this.compSprite.removeChild(param1);
      }
      
      public function getType() : String
      {
         return TYPE;
      }
      
      public function doLayout() : void
      {
      }
      
      public function addLayoutComponent(param1:UIComponent) : void
      {
         this.compSprite.addChild(param1);
      }
   }
}

