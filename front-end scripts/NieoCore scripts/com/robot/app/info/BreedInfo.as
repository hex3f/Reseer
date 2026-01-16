package com.robot.app.info
{
   import flash.utils.IDataInput;
   
   public class BreedInfo
   {
      
      private var _breedState:int;
      
      private var _breedCoolTime:uint;
      
      private var _breedLeftTime:uint;
      
      private var _malePetCatchTime:uint;
      
      private var _malePetID:uint;
      
      private var _feMalePetCatchTime:uint;
      
      private var _feMalePetID:uint;
      
      private var _hatchState:int;
      
      private var _hatchLeftTime:uint;
      
      private var _eggID:uint;
      
      private var _intimacy:uint;
      
      private var _motherPetCatchTime:uint;
      
      private var _motherPetID:uint;
      
      public function BreedInfo(param1:IDataInput = null)
      {
         super();
         this._breedState = param1.readUnsignedInt();
         this._breedLeftTime = param1.readUnsignedInt();
         this._breedCoolTime = param1.readUnsignedInt();
         this._malePetCatchTime = param1.readUnsignedInt();
         this._malePetID = param1.readUnsignedInt();
         this._feMalePetCatchTime = param1.readUnsignedInt();
         this._feMalePetID = param1.readUnsignedInt();
         this._hatchState = param1.readUnsignedInt();
         this._hatchLeftTime = param1.readUnsignedInt();
         this._eggID = param1.readUnsignedInt();
         this._intimacy = param1.readUnsignedInt();
      }
      
      public function get breedState() : int
      {
         return this._breedState;
      }
      
      public function set breedState(param1:int) : void
      {
         this._breedState = param1;
      }
      
      public function get breedLeftTime() : uint
      {
         return this._breedLeftTime;
      }
      
      public function set breedLeftTime(param1:uint) : void
      {
         this._breedLeftTime = param1;
      }
      
      public function get malePetCatchTime() : uint
      {
         return this._malePetCatchTime;
      }
      
      public function set malePetCatchTime(param1:uint) : void
      {
         this._malePetCatchTime = param1;
      }
      
      public function get malePetID() : uint
      {
         return this._malePetID;
      }
      
      public function set malePetID(param1:uint) : void
      {
         this._malePetID = param1;
      }
      
      public function get feMalePetCatchTime() : uint
      {
         return this._feMalePetCatchTime;
      }
      
      public function set feMalePetCatchTime(param1:uint) : void
      {
         this._feMalePetCatchTime = param1;
      }
      
      public function get feMalePetID() : uint
      {
         return this._feMalePetID;
      }
      
      public function set feMalePetID(param1:uint) : void
      {
         this._feMalePetID = param1;
      }
      
      public function get hatchState() : int
      {
         return this._hatchState;
      }
      
      public function set hatchState(param1:int) : void
      {
         this._hatchState = param1;
      }
      
      public function get hatchLeftTime() : uint
      {
         return this._hatchLeftTime;
      }
      
      public function set hatchLeftTime(param1:uint) : void
      {
         this._hatchLeftTime = param1;
      }
      
      public function get eggID() : uint
      {
         return this._eggID;
      }
      
      public function set eggID(param1:uint) : void
      {
         this._eggID = param1;
      }
      
      public function get intimacy() : uint
      {
         return this._intimacy;
      }
      
      public function set intimacy(param1:uint) : void
      {
         this._intimacy = param1;
      }
      
      public function get motherPetCatchTime() : uint
      {
         return this._motherPetCatchTime;
      }
      
      public function set motherPetCatchTime(param1:uint) : void
      {
         this._motherPetCatchTime = param1;
      }
      
      public function get motherPetID() : uint
      {
         return this._motherPetID;
      }
      
      public function set motherPetID(param1:uint) : void
      {
         this._motherPetID = param1;
      }
      
      public function get breedCoolTime() : uint
      {
         return this._breedCoolTime;
      }
      
      public function set breedCoolTime(param1:uint) : void
      {
         this._breedCoolTime = param1;
      }
   }
}

