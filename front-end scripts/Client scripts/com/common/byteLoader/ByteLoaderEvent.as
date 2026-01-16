package com.common.byteLoader
{
   import flash.events.Event;
   import flash.utils.getQualifiedClassName;
   
   public class ByteLoaderEvent extends Event
   {
      
      public static const ON_TIME_OUT:String = "onTimeout";
      
      public static const ON_START_LOAD:String = "onStartLoad";
      
      public static const GET_DATA_BEGIN:String = "getDataBegin";
      
      public static const GET_BYTE_DATA:String = "getByteData";
      
      public function ByteLoaderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      override public function toString() : String
      {
         return "[" + getQualifiedClassName(this) + " type=\"" + type + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
      }
   }
}

