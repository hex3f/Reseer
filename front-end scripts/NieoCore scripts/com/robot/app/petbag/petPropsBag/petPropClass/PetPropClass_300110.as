package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petItem.StudyUpManager;
   import com.robot.app.petbag.PetPropInfo;
   
   public class PetPropClass_300110
   {
      
      public function PetPropClass_300110(param1:PetPropInfo)
      {
         super();
         StudyUpManager.useItem(param1.itemId);
      }
   }
}

