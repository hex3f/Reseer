package com.robot.core.info.fightInfo
{
   public class PetWarInfo
   {
      
      private var _myPetA:Array;
      
      private var _otherPetA:Array;
      
      public function PetWarInfo()
      {
         super();
      }
      
      public function get myPetA() : Array
      {
         return this._myPetA;
      }
      
      public function set myPetA(param1:Array) : void
      {
         this._myPetA = param1;
      }
      
      public function set otherPetA(param1:Array) : void
      {
         this._otherPetA = param1;
      }
      
      public function get otherPetA() : Array
      {
         return this._otherPetA;
      }
   }
}

