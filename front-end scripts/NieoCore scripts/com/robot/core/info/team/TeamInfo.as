package com.robot.core.info.team
{
   import flash.utils.IDataInput;
   
   public class TeamInfo
   {
      
      public var id:uint;
      
      public var level:uint;
      
      public var priv:uint;
      
      public var superCore:Boolean;
      
      public var coreCount:uint;
      
      public var isShow:Boolean;
      
      public var logoBg:uint;
      
      public var logoIcon:uint;
      
      public var logoColor:uint;
      
      public var txtColor:uint;
      
      public var logoWord:String;
      
      public var allContribution:uint;
      
      public var canExContribution:uint;
      
      public function TeamInfo(param1:IDataInput = null)
      {
         super();
         if(!param1)
         {
            return;
         }
         this.id = param1.readUnsignedInt();
         this.priv = param1.readUnsignedInt();
         this.superCore = Boolean(param1.readUnsignedInt());
         this.isShow = Boolean(param1.readUnsignedInt());
         this.allContribution = param1.readUnsignedInt();
         this.canExContribution = param1.readUnsignedInt();
      }
   }
}

