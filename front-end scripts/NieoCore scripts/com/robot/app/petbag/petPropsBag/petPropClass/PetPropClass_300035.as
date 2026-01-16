package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petItem.StudyUpManager;
   import com.robot.app.petbag.PetPropInfo;
   
   public class PetPropClass_300035
   {
      
      public function PetPropClass_300035(param1:PetPropInfo)
      {
         super();
         StudyUpManager.useItem(param1.itemId);
      }
   }
}

