package com.robot.core.ui.alert2
{
   import com.robot.core.manager.alert.AlertInfo;
   
   public class PetInStorageAlarm extends BaseAlert
   {
      
      public function PetInStorageAlarm(param1:AlertInfo)
      {
         super(param1,"UI_PetInStorageAlert","pet");
      }
   }
}

