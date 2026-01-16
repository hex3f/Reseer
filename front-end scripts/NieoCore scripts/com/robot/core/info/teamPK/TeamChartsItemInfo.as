package com.robot.core.info.teamPK
{
   import flash.utils.IDataInput;
   
   public class TeamChartsItemInfo
   {
      
      private var _rank:uint;
      
      private var _teamID:uint;
      
      private var _score:uint;
      
      private var _win:uint;
      
      private var _lost:uint;
      
      private var _draw:uint;
      
      private var _killPlayerCount:uint;
      
      private var _killBuildCount:uint;
      
      private var _mvp:uint;
      
      public function TeamChartsItemInfo(param1:IDataInput)
      {
         super();
         this._rank = param1.readUnsignedInt();
         this._teamID = param1.readUnsignedInt();
         this._score = param1.readUnsignedInt();
         this._win = param1.readUnsignedInt();
         this._lost = param1.readUnsignedInt();
         this._draw = param1.readUnsignedInt();
         this._killPlayerCount = param1.readUnsignedInt();
         this._killBuildCount = param1.readUnsignedInt();
         this._mvp = param1.readUnsignedInt();
      }
      
      public function get rank() : uint
      {
         return this._rank;
      }
      
      public function get teamID() : uint
      {
         return this._teamID;
      }
      
      public function get score() : uint
      {
         return this._score;
      }
      
      public function get win() : uint
      {
         return this._win;
      }
      
      public function get lost() : uint
      {
         return this._lost;
      }
      
      public function get draw() : uint
      {
         return this._draw;
      }
      
      public function get killPlayerCount() : uint
      {
         return this._killPlayerCount;
      }
      
      public function get killBuildCount() : uint
      {
         return this._killBuildCount;
      }
      
      public function get mvp() : uint
      {
         return this._mvp;
      }
   }
}

