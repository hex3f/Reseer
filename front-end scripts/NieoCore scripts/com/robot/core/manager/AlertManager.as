package com.robot.core.manager
{
   import com.robot.core.manager.alert.AlertInfo;
   import com.robot.core.manager.alert.AlertType;
   import com.robot.core.ui.alert.IAlert;
   import com.robot.core.ui.alert2.Alarm;
   import com.robot.core.ui.alert2.Alert;
   import com.robot.core.ui.alert2.Answer;
   import com.robot.core.ui.alert2.ItemInBagAlarm;
   import com.robot.core.ui.alert2.PetInBagAlarm;
   import com.robot.core.ui.alert2.PetInStorageAlarm;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   
   public class AlertManager
   {
      
      private static var _currAlert:IAlert;
      
      private static var _list:Array = [];
      
      public function AlertManager()
      {
         super();
      }
      
      public static function show(param1:String, param2:String, param3:String = "", param4:DisplayObjectContainer = null, param5:Function = null, param6:Function = null, param7:Function = null, param8:Boolean = true, param9:Boolean = true, param10:Boolean = false) : void
      {
         var _loc11_:AlertInfo = null;
         _loc11_ = null;
         _loc11_ = new AlertInfo();
         _loc11_.type = param1;
         _loc11_.str = param2;
         _loc11_.iconURL = param3;
         _loc11_.parant = param4;
         _loc11_.applyFun = param5;
         _loc11_.cancelFun = param6;
         _loc11_.linkFun = param7;
         _loc11_.disMouse = param8;
         _loc11_.isGC = param9;
         _loc11_.isBreak = param10;
         _list.push(_loc11_);
         nextShow();
      }
      
      public static function showSimpleAlarm(param1:String, param2:Function = null) : void
      {
         show(AlertType.ALARM,param1,"",null,param2);
      }
      
      public static function showSimpleAlert(param1:String, param2:Function = null, param3:Function = null) : void
      {
         show(AlertType.ALERT,param1,"",null,param2,param3);
      }
      
      public static function showSimpleAnswer(param1:String, param2:Function = null, param3:Function = null) : void
      {
         show(AlertType.ANSWER,param1,"",null,param2,param3);
      }
      
      public static function showForInfo(param1:AlertInfo) : void
      {
         _list.push(param1);
         nextShow();
      }
      
      public static function nextShow() : void
      {
         var _loc1_:AlertInfo = null;
         if(_list.length == 0)
         {
            return;
         }
         if(_currAlert == null)
         {
            _loc1_ = _list.shift() as AlertInfo;
            switch(_loc1_.type)
            {
               case AlertType.ALARM:
                  _currAlert = new Alarm(_loc1_);
                  break;
               case AlertType.ALERT:
                  _currAlert = new Alert(_loc1_);
                  break;
               case AlertType.ANSWER:
                  _currAlert = new Answer(_loc1_);
                  break;
               case AlertType.ITEM_IN_BAG_ALARM:
                  _currAlert = new ItemInBagAlarm(_loc1_);
                  break;
               case AlertType.ITEM_IN_STORAGE_ALARM:
                  break;
               case AlertType.PET_IN_BAG_ALARM:
                  _currAlert = new PetInBagAlarm(_loc1_);
                  break;
               case AlertType.PET_IN_STORAGE_ALARM:
                  _currAlert = new PetInStorageAlarm(_loc1_);
            }
            _currAlert.addEventListener(Event.CLOSE,onClose);
            _currAlert.show();
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(_currAlert))
         {
            if(_currAlert.info.isGC)
            {
               _currAlert.removeEventListener(Event.CLOSE,onClose);
               _currAlert.destroy();
               _currAlert = null;
            }
         }
         _list = _list.filter(function(param1:AlertInfo, param2:int, param3:Array):Boolean
         {
            if(param1.isGC)
            {
               return false;
            }
            return true;
         });
      }
      
      private static function onClose(param1:Event) : void
      {
         var _loc2_:Boolean = Boolean(_currAlert.info.isBreak);
         _currAlert.removeEventListener(Event.CLOSE,onClose);
         _currAlert.destroy();
         _currAlert = null;
         if(!_loc2_)
         {
            nextShow();
         }
      }
   }
}

