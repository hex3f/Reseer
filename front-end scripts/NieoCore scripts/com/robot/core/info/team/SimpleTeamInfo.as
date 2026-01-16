package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class SimpleTeamInfo implements ITeamLogoInfo
   {
      
      private var _teamID:uint;
      
      private var _leader:uint;
      
      private var _memberCount:uint;
      
      private var _interest:uint;
      
      private var _joinFlag:uint;
      
      private var _visitFlag:uint;
      
      private var _exp:uint;
      
      private var _score:uint;
      
      private var _name:String;
      
      private var _slogan:String;
      
      private var _notice:String;
      
      private var _logoBg:uint;
      
      private var _logoIcon:uint;
      
      private var _logoColor:uint;
      
      private var _txtColor:uint;
      
      private var _logoWord:String;
      
      private var _superCoreNum:uint;
      
      public function SimpleTeamInfo(param1:IDataInput)
      {
         super();
         this._teamID = param1.readUnsignedInt();
         this._leader = param1.readUnsignedInt();
         this._superCoreNum = param1.readUnsignedInt();
         this._memberCount = param1.readUnsignedInt();
         this._interest = param1.readUnsignedInt();
         this._joinFlag = param1.readUnsignedInt();
         this._visitFlag = param1.readUnsignedInt();
         this._exp = param1.readUnsignedInt();
         this._score = param1.readUnsignedInt();
         this._name = param1.readUTFBytes(16);
         this._slogan = param1.readUTFBytes(60);
         this._notice = param1.readUTFBytes(60);
         this._logoBg = param1.readShort();
         this._logoIcon = param1.readShort();
         this._logoColor = param1.readShort();
         this._txtColor = param1.readShort();
         this._logoWord = param1.readUTFBytes(4);
      }
      
      public function get logoBg() : uint
      {
         return this._logoBg;
      }
      
      public function get logoIcon() : uint
      {
         return this._logoIcon;
      }
      
      public function get logoColor() : uint
      {
         return this._logoColor;
      }
      
      public function get txtColor() : uint
      {
         return this._txtColor;
      }
      
      public function get logoWord() : String
      {
         return this._logoWord;
      }
      
      public function set logoBg(param1:uint) : void
      {
         this._logoBg = param1;
      }
      
      public function set logoIcon(param1:uint) : void
      {
         this._logoIcon = param1;
      }
      
      public function set logoColor(param1:uint) : void
      {
         this._logoColor = param1;
      }
      
      public function set txtColor(param1:uint) : void
      {
         this._txtColor = param1;
      }
      
      public function set logoWord(param1:String) : void
      {
         this._logoWord = param1;
      }
      
      public function get superCoreNum() : uint
      {
         return this._superCoreNum;
      }
      
      public function set superCoreNum(param1:uint) : void
      {
         this._superCoreNum = param1;
      }
      
      public function get exp() : uint
      {
         return this._exp;
      }
      
      public function get score() : uint
      {
         return this._score;
      }
      
      public function get teamID() : uint
      {
         return this._teamID;
      }
      
      public function get leader() : uint
      {
         return this._leader;
      }
      
      public function get memberCount() : uint
      {
         return this._memberCount;
      }
      
      public function get interest() : uint
      {
         return this._interest;
      }
      
      public function get joinFlag() : uint
      {
         return this._joinFlag;
      }
      
      public function get visitFlag() : uint
      {
         return this._visitFlag;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get slogan() : String
      {
         return this._slogan;
      }
      
      public function get notice() : String
      {
         return this._notice;
      }
      
      public function get level() : uint
      {
         var _loc1_:Number = 2;
         var _loc2_:int = this.countExp(_loc1_);
         while(_loc2_ < this._exp)
         {
            _loc1_++;
            _loc2_ = this.countExp(_loc1_);
         }
         var _loc3_:* = uint(_loc1_ - 1);
         if(_loc3_ > 100)
         {
            _loc3_ = 100;
         }
         return _loc3_;
      }
      
      public function get realLevel() : uint
      {
         var _loc1_:Number = 2;
         var _loc2_:int = this.countExp(_loc1_);
         while(_loc2_ < this._exp)
         {
            _loc1_++;
            _loc2_ = this.countExp(_loc1_);
         }
         return uint(_loc1_ - 1);
      }
      
      public function countExp(param1:uint) : int
      {
         return uint(Math.ceil(6 * Math.pow(param1,3) / 5 - 15 * Math.pow(param1,2) + 100 * param1 - 140));
      }
   }
}

