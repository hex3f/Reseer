package com.robot.petFightModule.assetManager
{
   import flash.display.MovieClip;
   
   public class SkillAssetsManager
   {
      
      private static var instance:SkillAssetsManager;
      
      private var assetsObj:Object;
      
      public function SkillAssetsManager()
      {
         super();
      }
      
      public static function getInstance() : SkillAssetsManager
      {
         if(!instance)
         {
            instance = new SkillAssetsManager();
         }
         return instance;
      }
      
      public function getAssetsByID(param1:int) : MovieClip
      {
         return this.assetsObj["asset_" + param1];
      }
      
      public function deleteAsset(param1:int) : void
      {
         delete this.assetsObj["asset_" + param1];
      }
      
      public function clearAll() : void
      {
         this.assetsObj = {};
      }
      
      public function addAsset(param1:int, param2:MovieClip) : void
      {
         if(!this.assetsObj)
         {
            this.assetsObj = {};
         }
         this.assetsObj["asset_" + param1] = param2;
      }
   }
}

