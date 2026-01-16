package com.robot.petFightModule.control.petItemCon
{
   import com.robot.core.info.fightInfo.UsePetItemInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.petFightModule.TimerManager;
   import com.robot.petFightModule.mode.BaseFighterMode;
   
   public class UsePetItemController
   {
      
      public function UsePetItemController()
      {
         super();
      }
      
      public static function useItem(param1:BaseFighterMode, param2:UsePetItemInfo) : void
      {
         if(param2.userID == MainManager.actorID)
         {
            TimerManager.clearTxt();
         }
         var _loc3_:int = int(param2.userHP);
         param1.hp = _loc3_;
         param1.propView.resetBar(param1);
         var _loc4_:uint = uint(param2.itemID);
         if(_loc4_ <= 300015 || _loc4_ == 300020 || _loc4_ == 300021 || _loc4_ == 300022)
         {
            new RenewBloodEffect(param1,_loc4_,param2.changeHp);
         }
         else if(_loc4_ <= 300020 || _loc4_ == 300023)
         {
            new RenewPPEffect(param1,_loc4_);
         }
      }
   }
}

