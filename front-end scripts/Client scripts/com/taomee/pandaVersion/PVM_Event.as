package com.taomee.pandaVersion
{
   import flash.events.Event;
   
   public class PVM_Event extends Event
   {
      
      public static const ON_HEADER_AMEND_LOADED:String = "onHeaderAmendLoaded";
      
      public static const ON_HEADER_LOADED:String = "onHeaderLoaded";
      
      public static const ON_LOADED:String = "onLoaded";
      
      public static const ON_LOAD_ERROR:String = "onLoadError";
      
      public static const ON_LOAD_TIMEOUT:String = "onLoadTimeout";
      
      public function PVM_Event(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      public function getTarget() : IPVM_Loader
      {
         return super.target as IPVM_Loader;
      }
   }
}

