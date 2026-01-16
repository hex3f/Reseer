package com.robot.core.info.team
{
   import com.robot.core.manager.MainManager;
   import flash.utils.IDataInput;
   
   public class TeamLogoInfo implements ITeamLogoInfo
   {
      
      private var _id:uint;
      
      private var _logoBg:uint;
      
      private var _logoIcon:uint;
      
      private var _logoColor:uint;
      
      private var _txtColor:uint;
      
      private var _logoWord:String;
      
      public function TeamLogoInfo(param1:IDataInput = null)
      {
         super();
         if(!param1)
         {
            return;
         }
         this._id = param1.readUnsignedInt();
         this._logoBg = param1.readShort();
         this._logoIcon = param1.readShort();
         this._logoColor = param1.readShort();
         this._txtColor = param1.readShort();
         this._logoWord = param1.readUTFBytes(4);
         if(this._id == MainManager.actorInfo.teamInfo.id)
         {
            MainManager.actorInfo.teamInfo.logoBg = this.logoBg;
            MainManager.actorInfo.teamInfo.logoIcon = this.logoIcon;
            MainManager.actorInfo.teamInfo.logoColor = this.logoColor;
            MainManager.actorInfo.teamInfo.txtColor = this.txtColor;
            MainManager.actorInfo.teamInfo.logoWord = this.logoWord;
         }
      }
      
      public function get teamID() : uint
      {
         return this._id;
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
   }
}

