package com.robot.core.event
{
   import flash.events.Event;
   
   public class PetEvent extends Event
   {
      
      public static const ADDED:String = "added";
      
      public static const REMOVED:String = "removed";
      
      public static const SET_DEFAULT:String = "setDefault";
      
      public static const CURE_COMPLETE:String = "cureComplete";
      
      public static const CURE_ONE_COMPLETE:String = "cureOneComplete";
      
      public static const UPDATE_INFO:String = "updateInfo";
      
      public static const STORAGE_LIST:String = "storageList";
      
      public static const STORAGE_ADDED:String = "storageAdded";
      
      public static const STORAGE_REMOVED:String = "storageRsemoved";
      
      public static const GET_ROWEI_PET_LIST:String = "getRoweiPetList";
      
      public static const ROWEI_PET:String = "roweiPet";
      
      public static const RETRIEVE_PET:String = "RetrievePet";
      
      public static const ROOM_PET_LIST:String = "roomPetList";
      
      public static const ROOM_PET_SHOW:String = "roomPetShow";
      
      public static const START_EXE_PET:String = "startExePet";
      
      public static const STOP_EXE_PET:String = "stopExePet";
      
      public static const STUDY_SPECIAL_SKILL:String = "studySpecialSkill";
      
      private var _catchTime:uint;
      
      private var _obj:Object;
      
      public function PetEvent(param1:String, param2:uint, param3:Object = null)
      {
         super(param1,false,false);
         this._catchTime = param2;
         this._obj = param3;
      }
      
      public function catchTime() : uint
      {
         return this._catchTime;
      }
      
      public function obj() : Object
      {
         return this._obj;
      }
   }
}

