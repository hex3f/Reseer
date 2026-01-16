package org.taomee.module
{
   import flash.events.IEventDispatcher;
   
   public interface IModule extends IEventDispatcher
   {
      
      function init(param1:Object = null) : void;
      
      function hide() : void;
      
      function setup() : void;
      
      function destroy() : void;
      
      function show() : void;
   }
}

