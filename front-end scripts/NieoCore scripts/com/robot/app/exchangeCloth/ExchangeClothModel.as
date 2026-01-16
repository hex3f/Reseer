package com.robot.app.exchangeCloth
{
   import com.robot.core.config.xml.ItemTipXMLInfo;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   
   public class ExchangeClothModel
   {
      
      private var xmlClass:Class = ExchangeClothModel_xmlClass;
      
      private var xml:XML = XML(new this.xmlClass());
      
      private var info_a:Array;
      
      public function ExchangeClothModel()
      {
         super();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         ItemManager.getCollection();
      }
      
      private function getInfo() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.xml.item.length())
         {
            if(ItemManager.getCollectionInfo(uint(this.xml.item[_loc2_].@id)) != null)
            {
               _loc1_ = new Object();
               _loc1_.className = this.xml.item[_loc2_].@className;
               _loc1_.iconName = this.xml.item[_loc2_].@iconName;
               _loc1_.id = this.xml.item[_loc2_].@id;
               _loc1_.exName = this.xml.item[_loc2_].@exName;
               _loc1_.eName = ItemXMLInfo.getName(uint(_loc1_.id));
               _loc1_.des = ItemTipXMLInfo.getItemDes(uint(_loc1_.id));
               this.info_a.push(_loc1_);
            }
            _loc2_++;
         }
      }
      
      public function onList(param1:Event) : void
      {
         this.destroy();
         this.info_a = new Array();
         this.getInfo();
         if(this.info_a.length > 0)
         {
            ExchangeClothController.show(this.info_a);
         }
         else
         {
            Alarm.show("你还没有原材料打造装备，快去搜集吧!");
         }
      }
      
      public function destroy() : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
      }
   }
}

