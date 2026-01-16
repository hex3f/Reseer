package com.robot.core.controller
{
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetEvent;
   import com.robot.core.manager.PetManager;
   import com.robot.core.ui.alert.PetInBagAlert;
   import com.robot.core.ui.alert.PetInStorageAlert;
   
   public class GetPetController
   {
      
      public function GetPetController()
      {
         super();
      }
      
      public static function getPet(param1:uint, param2:uint, param3:Function = null, param4:Boolean = true) : void
      {
         var monID:uint = param1;
         var captureTm:uint = param2;
         var func:Function = param3;
         var isAlart:Boolean = param4;
         if(PetManager.length < 6)
         {
            PetManager.addEventListener(PetEvent.ADDED,function(param1:PetEvent):void
            {
               PetManager.removeEventListener(PetEvent.ADDED,arguments.callee);
               if(isAlart)
               {
                  PetInBagAlert.show(monID,PetXMLInfo.getName(monID) + "已经放入了你的精灵背包！",null,func);
               }
               else if(func != null)
               {
                  func();
               }
            });
            PetManager.setIn(captureTm,1);
         }
         else
         {
            PetManager.addStorage(monID,captureTm);
            if(isAlart)
            {
               PetInStorageAlert.show(monID,PetXMLInfo.getName(monID) + "已经放入了你的精灵仓库！",null,func);
            }
            else if(func != null)
            {
               func();
            }
         }
      }
   }
}

