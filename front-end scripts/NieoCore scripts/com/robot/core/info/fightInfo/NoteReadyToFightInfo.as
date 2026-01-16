package com.robot.core.info.fightInfo
{
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.PetSkillInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.pet.petWar.PetWarController;
   import flash.utils.IDataInput;
   import org.taomee.ds.*;
   import org.taomee.manager.EventManager;
   
   public class NoteReadyToFightInfo
   {
      
      private var _userInfoArray:Array;
      
      private var _petArray:Array;
      
      private var _skillArray:Array;
      
      private var _obj:PetWarInfo;
      
      private var _petInfoMap:Array;
      
      private var _myCapA:Array;
      
      private var _myPetInfoA:Array;
      
      private var _petInfoArray:HashMap;
      
      public function NoteReadyToFightInfo(param1:IDataInput)
      {
         var _loc2_:uint = 0;
         var _loc3_:FighetUserInfo = null;
         var _loc4_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:PetInfo = null;
         var _loc7_:Number = 0;
         var _loc8_:* = 0;
         var _loc9_:* = 0;
         var _loc10_:Number = 0;
         var _loc11_:* = 0;
         this._userInfoArray = [];
         this._petArray = [];
         this._skillArray = [];
         this._petInfoMap = new Array();
         this._myCapA = new Array();
         this._myPetInfoA = new Array();
         this._petInfoArray = new HashMap();
         super();
         this._obj = new PetWarInfo();
         this._obj.myPetA = new Array();
         this._obj.otherPetA = new Array();
         var _loc12_:uint = uint(param1.readUnsignedInt());
         var _loc13_:int = 0;
         while(_loc13_ < 2)
         {
            _loc3_ = new FighetUserInfo(param1);
            this._userInfoArray.push(_loc3_);
            _loc4_ = uint(param1.readUnsignedInt());
            _loc5_ = 0;
            while(_loc5_ < _loc4_)
            {
               _loc6_ = new PetInfo(param1,false);
               this._petInfoArray.add(_loc6_.catchTime,_loc6_);
               this._petInfoMap.push(_loc6_);
               _loc2_ = _loc6_.skinID;
               if(this._petArray.indexOf(_loc2_) == -1 && _loc2_ != 0)
               {
                  this._petArray.push(_loc2_);
               }
               if(this._petArray.indexOf(_loc6_.id) == -1)
               {
                  this._petArray.push(_loc6_.id);
               }
               if(_loc3_.id == MainManager.actorID)
               {
                  this._obj.myPetA.push(_loc6_.id);
                  this._myCapA.push(_loc6_.catchTime);
                  this._myPetInfoA.push(_loc6_);
               }
               else
               {
                  this._obj.otherPetA.push(_loc6_.id);
               }
               _loc7_ = 0;
               while(_loc7_ < _loc6_.skillArray.length)
               {
                  if(this._skillArray.indexOf((_loc6_.skillArray[_loc7_] as PetSkillInfo).id) == -1)
                  {
                     this._skillArray.push((_loc6_.skillArray[_loc7_] as PetSkillInfo).id);
                  }
                  _loc7_++;
               }
               _loc5_++;
            }
            _loc13_++;
         }
         PetWarController.myPetInfoA = this._myPetInfoA;
         PetWarController.allPetA = this._petInfoMap;
         PetWarController.myCapA = this._myCapA;
         EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.GET_FIGHT_INFO_SUCCESS,this._obj));
      }
      
      public function get petArray() : Array
      {
         return this._petArray;
      }
      
      public function get skillArray() : Array
      {
         return this._skillArray;
      }
      
      public function get userInfoArray() : Array
      {
         return this._userInfoArray;
      }
      
      public function get petInfoArray() : HashMap
      {
         return this._petInfoArray;
      }
   }
}

