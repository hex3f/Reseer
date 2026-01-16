package com.robot.core.ui.alert2
{
   import com.robot.core.manager.alert.AlertInfo;
   
   public class ItemInBagAlarm extends BaseAlert
   {
      
      public function ItemInBagAlarm(param1:AlertInfo)
      {
         super(param1,"TaskItemAlarmMC");
         _iconOfftX = -110;
         _iconOfftY = 5;
      }
   }
}

