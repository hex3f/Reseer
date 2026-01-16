package com.robot.app.equipStrengthen
{
   public class EquipStrengthenInfo
   {
      
      private var _itemId:uint;
      
      private var _itemLev:uint;
      
      private var _levelId:uint;
      
      private var _needCatalystId:uint;
      
      private var _needMatterA:Array;
      
      private var _ownNeedA:Array;
      
      private var _needMatterNumA:Array;
      
      private var _des:String;
      
      private var _prob:String;
      
      private var _needCatalystNum:uint;
      
      private var _ownCatalystNum:uint;
      
      private var _sendId:uint;
      
      public function EquipStrengthenInfo()
      {
         super();
      }
      
      public function set sendId(param1:uint) : void
      {
         this._sendId = param1;
      }
      
      public function get sendId() : uint
      {
         return this._sendId;
      }
      
      public function set ownCatalystNum(param1:uint) : void
      {
         this._ownCatalystNum = param1;
      }
      
      public function get ownCatalystNum() : uint
      {
         return this._ownCatalystNum;
      }
      
      public function set needCatalystNum(param1:uint) : void
      {
         this._needCatalystNum = param1;
      }
      
      public function get needCatalystNum() : uint
      {
         return this._needCatalystNum;
      }
      
      public function set ownNeedA(param1:Array) : void
      {
         this._ownNeedA = param1;
      }
      
      public function get ownNeedA() : Array
      {
         return this._ownNeedA;
      }
      
      public function get itemId() : uint
      {
         return this._itemId;
      }
      
      public function set itemId(param1:uint) : void
      {
         this._itemId = param1;
      }
      
      public function get levelId() : uint
      {
         return this._levelId;
      }
      
      public function set levelId(param1:uint) : void
      {
         this._levelId = param1;
      }
      
      public function get needCatalystId() : uint
      {
         return this._needCatalystId;
      }
      
      public function set needCatalystId(param1:uint) : void
      {
         this._needCatalystId = param1;
      }
      
      public function get needMatterA() : Array
      {
         return this._needMatterA;
      }
      
      public function set needMatterA(param1:Array) : void
      {
         this._needMatterA = param1;
      }
      
      public function get needMatterNumA() : Array
      {
         return this._needMatterNumA;
      }
      
      public function set needMatterNumA(param1:Array) : void
      {
         this._needMatterNumA = param1;
      }
      
      public function get prob() : String
      {
         return this._prob;
      }
      
      public function set prob(param1:String) : void
      {
         this._prob = param1;
      }
      
      public function get des() : String
      {
         return this._des;
      }
      
      public function set des(param1:String) : void
      {
         this._des = param1;
      }
   }
}

