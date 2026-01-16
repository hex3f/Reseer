package org.taomee.component.layout
{
   import flash.events.IEventDispatcher;
   import org.taomee.component.Container;
   import org.taomee.component.UIComponent;
   
   public interface ILayoutManager extends IEventDispatcher
   {
      
      function getType() : String;
      
      function destroy() : void;
      
      function addLayoutComponent(param1:UIComponent) : void;
      
      function doLayout() : void;
      
      function set layoutObj(param1:Container) : void;
      
      function removeLayoutComponent(param1:UIComponent) : void;
   }
}

