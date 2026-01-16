package com.robot.petFightModule.ui.controlPanel.petItem
{
   import com.robot.petFightModule.ui.controlPanel.petItem.category.CatchPetItemCategory;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.IPetItemCategory;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.RenewBloodItemCategory;
   import com.robot.petFightModule.ui.controlPanel.petItem.category.RenewPPItemCategory;
   
   public class PetItemCategoryFactory
   {
      
      public function PetItemCategoryFactory()
      {
         super();
      }
      
      public static function getitemgory(param1:uint) : IPetItemCategory
      {
         var _loc2_:IPetItemCategory = null;
         if(param1 <= 300009)
         {
            _loc2_ = new CatchPetItemCategory(param1);
         }
         else if(param1 <= 300015 || param1 == 300020 || param1 == 300021 || param1 == 300022)
         {
            _loc2_ = new RenewBloodItemCategory(param1);
         }
         else if(param1 <= 300020 || param1 == 300023)
         {
            _loc2_ = new RenewPPItemCategory(param1);
         }
         return _loc2_;
      }
   }
}

