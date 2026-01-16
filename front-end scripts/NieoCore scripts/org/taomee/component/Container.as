package org.taomee.component
{
   import flash.display.Sprite;
   import org.taomee.component.event.ContainerEvent;
   import org.taomee.component.event.LayoutEvent;
   import org.taomee.component.geom.IntDimension;
   import org.taomee.component.layout.EmptyLayout;
   import org.taomee.component.layout.ILayoutManager;
   
   [Event(name="compAdded",type="org.taomee.component.event.ContainerEvent")]
   [Event(name="compRemoved",type="org.taomee.component.event.ContainerEvent")]
   public class Container extends UIComponent
   {
      
      protected var layoutManager:ILayoutManager;
      
      private var isUpdating:Boolean = false;
      
      public function Container()
      {
         super();
         this.layoutManager = new EmptyLayout();
         this.layoutManager.addEventListener(LayoutEvent.LAYOUT_SET_CHANGED,this.layoutChanged);
         this.initLayout();
      }
      
      public function append(param1:UIComponent) : void
      {
         this.layoutManager.addLayoutComponent(param1);
         containSprite.addChild(param1);
         this.layoutManager.doLayout();
         dispatchEvent(new ContainerEvent(ContainerEvent.COMP_ADDED,param1));
      }
      
      public function remove(param1:UIComponent) : void
      {
         this.layoutManager.removeLayoutComponent(param1);
         param1.destroy();
         this.layoutManager.doLayout();
         dispatchEvent(new ContainerEvent(ContainerEvent.COMP_REMOVED,param1));
      }
      
      public function appendAll(... rest) : void
      {
         var _loc2_:UIComponent = null;
         for each(_loc2_ in rest)
         {
            this.layoutManager.addLayoutComponent(_loc2_);
            containSprite.addChild(_loc2_);
            dispatchEvent(new ContainerEvent(ContainerEvent.COMP_ADDED,_loc2_));
         }
         this.layoutManager.doLayout();
      }
      
      override protected function revalidate() : void
      {
         if(this.isUpdating)
         {
            return;
         }
         super.revalidate();
         this.isUpdating = true;
         this.initLayout();
      }
      
      private function layoutChanged(param1:LayoutEvent) : void
      {
         this.initLayout();
      }
      
      public function set layout(param1:ILayoutManager) : void
      {
         if(Boolean(this.layoutManager))
         {
            this.layoutManager.removeEventListener(LayoutEvent.LAYOUT_SET_CHANGED,this.layoutChanged);
            this.layoutManager.destroy();
         }
         if(!param1)
         {
            param1 = new EmptyLayout();
         }
         this.layoutManager = param1;
         this.layoutManager.addEventListener(LayoutEvent.LAYOUT_SET_CHANGED,this.layoutChanged);
         this.initLayout();
      }
      
      public function appendAt(param1:UIComponent, param2:int) : void
      {
         containSprite.addChildAt(param1,param2);
         this.layoutManager.doLayout();
         dispatchEvent(new ContainerEvent(ContainerEvent.COMP_ADDED,param1));
      }
      
      public function get layout() : ILayoutManager
      {
         return this.layoutManager;
      }
      
      protected function initLayout() : void
      {
         this.layoutManager.layoutObj = this;
         this.layoutManager.doLayout();
         this.isUpdating = false;
      }
      
      public function get compList() : Array
      {
         var _loc1_:Array = [];
         var _loc2_:Number = 0;
         while(_loc2_ < containSprite.numChildren)
         {
            _loc1_.push(containSprite.getChildAt(_loc2_));
            _loc2_++;
         }
         return _loc1_;
      }
      
      override public function destroy() : void
      {
         this.layoutManager.removeEventListener(LayoutEvent.LAYOUT_SET_CHANGED,this.layoutChanged);
         this.layoutManager.destroy();
         this.layoutManager = null;
         super.destroy();
      }
      
      public function getContainSprite() : Sprite
      {
         return containSprite;
      }
      
      public function get contentSize() : IntDimension
      {
         return new IntDimension(containSprite.width,containSprite.height);
      }
      
      public function removeAll() : void
      {
         var _loc1_:UIComponent = null;
         while(containSprite.numChildren > 0)
         {
            _loc1_ = containSprite.getChildAt(0) as UIComponent;
            this.layoutManager.removeLayoutComponent(_loc1_);
            _loc1_.destroy();
            dispatchEvent(new ContainerEvent(ContainerEvent.COMP_REMOVED,_loc1_));
         }
      }
   }
}

