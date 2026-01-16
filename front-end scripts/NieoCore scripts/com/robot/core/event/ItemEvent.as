package com.robot.core.event
{
   import flash.events.Event;
   
   public class ItemEvent extends Event
   {
      
      public static const CLOTH_LIST:String = "clothList";
      
      public static const COLLECTION_LIST:String = "collectionList";
      
      public static const THROW_LIST:String = "throwList";
      
      public static const PET_ITEM_LIST:String = "petItemList";
      
      public static const SUPER_ITEM_LIST:String = "superItemList";
      
      public static const SOULBEAD_ITEM_LIST:String = "soulbeadItemList";
      
      public function ItemEvent(param1:String)
      {
         super(param1,false,false);
      }
   }
}

