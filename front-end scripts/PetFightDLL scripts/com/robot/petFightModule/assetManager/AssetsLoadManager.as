package com.robot.petFightModule.assetManager
{
   import com.robot.core.*;
   import com.robot.core.info.fightInfo.*;
   import com.robot.core.net.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import flash.system.ApplicationDomain;
   import flash.utils.*;
   
   public class AssetsLoadManager extends EventDispatcher
   {
      
      private static const PET_PATH:String = "resource/fightResource/pet/swf/";
      
      private static const SKILL_PATH:String = "resource/fightResource/skill/swf/";
      
      private var skillLoader:Loader;
      
      private var timer:Timer;
      
      private var _percent:Number = 0;
      
      private var skillIDArray:Array = [];
      
      private var P:Number;
      
      private var petLoader:Loader;
      
      private var currentPercent:Number = 0;
      
      private var currentID:int;
      
      private var currentIndex:int = 0;
      
      private var petIDArray:Array = [];
      
      public function AssetsLoadManager()
      {
         super();
         this.petLoader = new Loader();
         this.petLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadPetAsset);
         this.petLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoadHandler);
         this.petLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onPetProgress);
         this.skillLoader = new Loader();
         this.skillLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadSkillAsset);
         this.skillLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.errorLoadHandler);
         this.skillLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onSkillProgress);
         this.timer = new Timer(2000);
         this.timer.addEventListener(TimerEvent.TIMER,this.onTimer);
      }
      
      private function loadPets() : void
      {
         var _loc1_:String = null;
         if(this.petIDArray.length == 0)
         {
            return;
         }
         if(this.currentIndex < this.petIDArray.length)
         {
            this.currentID = this.petIDArray[this.currentIndex];
            _loc1_ = this.formatID(this.currentID);
            this.petLoader.load(new URLRequest(PET_PATH + _loc1_ + ".swf"));
         }
         else
         {
            this.currentIndex = 0;
            this.loadSkills();
         }
      }
      
      public function loadAssets() : void
      {
         var _loc1_:int = int(this.petIDArray.indexOf(PetFightModel.defaultNpcID));
         if(_loc1_ == -1 && PetFightModel.defaultNpcID != 0)
         {
            this.petIDArray.push(PetFightModel.defaultNpcID);
         }
         else
         {
            this.timer.start();
         }
         this.P = 1 / (this.petIDArray.length + this.skillIDArray.length);
         this.loadPets();
      }
      
      public function addSkillID(... rest) : void
      {
         var _loc2_:int = 0;
         for each(_loc2_ in rest)
         {
            this.skillIDArray.push(_loc2_);
         }
      }
      
      private function stopAll() : void
      {
         try
         {
            this.petLoader.close();
         }
         catch(e:Error)
         {
         }
         try
         {
            this.skillLoader.close();
         }
         catch(e:Error)
         {
         }
      }
      
      private function loadSkills() : void
      {
         var _loc1_:String = null;
         if(this.skillIDArray.length == 0)
         {
            dispatchEvent(new AssetsEvent(AssetsEvent.LOAD_ALL_ASSETS));
            SocketConnection.send(CommandID.LOAD_PERCENT,100);
            return;
         }
         if(this.currentIndex < this.skillIDArray.length)
         {
            this.currentID = this.skillIDArray[this.currentIndex];
            _loc1_ = this.formatID(this.currentID);
            this.skillLoader.load(new URLRequest(SKILL_PATH + _loc1_ + ".swf"));
         }
         else
         {
            dispatchEvent(new AssetsEvent(AssetsEvent.LOAD_ALL_ASSETS));
            this.currentIndex = 0;
         }
      }
      
      private function onLoadPetAsset(param1:Event) : void
      {
         var _loc2_:ApplicationDomain = (param1.target as LoaderInfo).applicationDomain;
         PetAssetsManager.getInstance().addAsset(this.currentID,_loc2_);
         ++this.currentIndex;
         this.loadPets();
         this.currentPercent = this._percent;
      }
      
      private function onSkillProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = Math.floor(param1.bytesLoaded / param1.bytesTotal * this.P * 100);
         this._percent = this.currentPercent + _loc2_;
         dispatchEvent(new AssetsEvent(AssetsEvent.PROGRESS,this._percent));
      }
      
      private function errorLoadHandler(param1:IOErrorEvent) : void
      {
         throw new Error("AssetsLoading加载出错..." + this.currentID);
      }
      
      private function formatID(param1:uint, param2:uint = 3) : String
      {
         var _loc3_:int = 0;
         var _loc4_:String = param1.toString();
         var _loc5_:uint = uint(_loc4_.length);
         if(_loc5_ < param2)
         {
            _loc3_ = 0;
            while(_loc3_ < param2 - _loc5_)
            {
               _loc4_ = "0" + _loc4_;
               _loc3_++;
            }
         }
         return _loc4_;
      }
      
      private function onPetProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = Math.floor(param1.bytesLoaded / param1.bytesTotal * this.P * 100);
         this._percent = this.currentPercent + _loc2_;
         dispatchEvent(new AssetsEvent(AssetsEvent.PROGRESS,this._percent));
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         SocketConnection.send(CommandID.LOAD_PERCENT,this._percent);
      }
      
      private function onLoadSkillAsset(param1:Event) : void
      {
         var _loc2_:Class = (param1.target as LoaderInfo).applicationDomain.getDefinition("skill") as Class;
         var _loc3_:MovieClip = new _loc2_() as MovieClip;
         SkillAssetsManager.getInstance().addAsset(this.currentID,_loc3_);
         ++this.currentIndex;
         this.loadSkills();
         this.currentPercent = this._percent;
      }
      
      public function addPetID(... rest) : void
      {
         var _loc2_:int = 0;
         for each(_loc2_ in rest)
         {
            this.petIDArray.push(_loc2_);
         }
      }
      
      public function destroy() : void
      {
         this.timer.stop();
         this.timer.removeEventListener(TimerEvent.TIMER,this.onTimer);
         this.timer = null;
         this.stopAll();
         this.petLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadPetAsset);
         this.petLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoadHandler);
         this.petLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onPetProgress);
         this.skillLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadSkillAsset);
         this.skillLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.errorLoadHandler);
         this.skillLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.onSkillProgress);
         this.petLoader = null;
         this.skillLoader = null;
      }
   }
}

