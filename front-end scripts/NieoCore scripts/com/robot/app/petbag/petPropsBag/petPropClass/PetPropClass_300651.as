package com.robot.app.petbag.petPropsBag.petPropClass
{
   import com.robot.app.petbag.PetPropInfo;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.net.SocketConnection;
   
   public class PetPropClass_300651
   {
      
      protected var _info:PetPropInfo;
      
      public function PetPropClass_300651(param1:PetPropInfo)
      {
         super();
         this._info = param1;
         var _loc2_:Object = {
            "name":PetXMLInfo.getName(this._info.petInfo.id),
            "fun":this.onChoose,
            "petInfo":this._info.petInfo
         };
         ModuleManager.showModule(ClientConfig.getAppModule("LearningabilityChoosePanle"),"正在加载....",_loc2_);
      }
      
      protected function onChoose(param1:int, param2:String) : void
      {
         SocketConnection.send(CommandID.USE_PET_ITEM_FULL_ABILITY_OF_STUDY,this._info.petInfo.catchTime,param1,this._info.itemId,1);
      }
   }
}

