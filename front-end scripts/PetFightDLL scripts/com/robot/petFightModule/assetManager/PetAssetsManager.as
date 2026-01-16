package com.robot.petFightModule.assetManager
{
   import flash.display.*;
   import flash.system.*;
   
   public class PetAssetsManager
   {
      
      private static var instance:PetAssetsManager;
      
      private var assetsObj:Object;
      
      private var defaultID:int;
      
      public function PetAssetsManager()
      {
         super();
      }
      
      public static function getInstance() : PetAssetsManager
      {
         if(!instance)
         {
            instance = new PetAssetsManager();
         }
         return instance;
      }
      
      public function getDefaultPet() : MovieClip
      {
         return this.getAssetsByID(this.defaultID);
      }
      
      public function getAssetsByID(param1:int) : MovieClip
      {
         var _loc2_:Class = (this.assetsObj["asset_" + param1] as ApplicationDomain).getDefinition("pet") as Class;
         return new _loc2_() as MovieClip;
      }
      
      public function deleteAsset(param1:int) : void
      {
         delete this.assetsObj["asset_" + param1];
      }
      
      public function addAsset(param1:int, param2:ApplicationDomain) : void
      {
         if(!this.assetsObj)
         {
            this.assetsObj = {};
            this.defaultID = param1;
         }
         this.assetsObj["asset_" + param1] = param2;
      }
      
      public function clearAll() : void
      {
         this.assetsObj = {};
      }
   }
}

