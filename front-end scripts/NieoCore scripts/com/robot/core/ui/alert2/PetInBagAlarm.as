package com.robot.core.ui.alert2
{
   import com.robot.core.manager.alert.AlertInfo;
   
   public class PetInBagAlarm extends BaseAlert
   {
      
      public function PetInBagAlarm(param1:AlertInfo)
      {
         super(param1,"UI_PetSwitchAlert","pet");
      }
   }
}

