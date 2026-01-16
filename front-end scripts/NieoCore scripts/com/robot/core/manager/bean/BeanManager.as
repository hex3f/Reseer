package com.robot.core.manager.bean
{
   import com.robot.core.event.RobotEvent;
   import com.robot.core.event.XMLLoadEvent;
   import com.robot.core.newloader.XMLLoader;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import org.taomee.manager.EventManager;
   
   public class BeanManager
   {
      
      private static var xmlData:XMLList;
      
      private static var dataArray:Array;
      
      private static var dataDictionary:Dictionary;
      
      public static const BEAN_FINISH:String = "beanFinish";
      
      private static const ID_NODE:String = "id";
      
      private static const CLASS_NODE:String = "class";
      
      public function BeanManager()
      {
         super();
      }
      
      public static function start() : void
      {
         var _loc1_:* = getDefinitionByName("DLLLoader");
         xmlData = _loc1_.getBeanXML();
         parseXML();
      }
      
      private static function failLoadHandler(param1:XMLLoadEvent) : void
      {
         var _loc2_:XMLLoader = param1.currentTarget as XMLLoader;
         _loc2_.removeEventListener(XMLLoadEvent.ERROR,failLoadHandler);
      }
      
      private static function parseXML() : void
      {
         var _loc1_:XML = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         dataArray = [];
         dataDictionary = new Dictionary(true);
         for each(_loc1_ in xmlData.elements())
         {
            _loc2_ = _loc1_.attribute(ID_NODE).toString();
            _loc3_ = _loc1_.attribute(CLASS_NODE).toString();
            dataArray.push({
               "id":_loc2_,
               "classPath":_loc3_
            });
         }
         EventManager.addEventListener(BEAN_FINISH,initClasses);
         initClasses();
      }
      
      private static function initClasses(param1:Event = null) : void
      {
         var _loc2_:Class = null;
         var _loc3_:* = undefined;
         if(dataArray.length > 0)
         {
            _loc2_ = getDefinitionByName(dataArray[0]["classPath"]) as Class;
            _loc3_ = new _loc2_();
            dataDictionary[dataArray[0]["id"]] = _loc3_;
            dataArray.shift();
            _loc3_.start();
         }
         else
         {
            EventManager.removeEventListener(BeanManager.BEAN_FINISH,initClasses);
            EventManager.dispatchEvent(new Event(RobotEvent.BEAN_COMPLETE));
         }
      }
      
      public static function getBeanInstance(param1:String) : *
      {
         return dataDictionary[param1];
      }
   }
}

