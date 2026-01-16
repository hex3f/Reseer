package com.robot.core.npc
{
   import com.robot.core.config.xml.NpcXMLInfo;
   import flash.geom.Point;
   
   public class NpcInfo
   {
      
      public var bubbingList:Array;
      
      public var dialogList:Array;
      
      public var point:Point;
      
      public var clothIds:Array;
      
      public var npcId:uint;
      
      public var npcMap:uint;
      
      public var npcName:String;
      
      public var color:uint;
      
      public var npcPath:String;
      
      public var type:String;
      
      public var startIDs:Array;
      
      public var endIDs:Array;
      
      public var proIDs:Array;
      
      public var offSetPoint:Point;
      
      public var questionA:Array;
      
      public function NpcInfo(param1:XMLList = null)
      {
         var _loc2_:Array = null;
         var _loc3_:XML = null;
         var _loc4_:Array = null;
         this.bubbingList = [];
         this.dialogList = [];
         this.clothIds = [];
         super();
         if(Boolean(param1))
         {
            this.npcId = uint(param1.@id);
            this.npcMap = uint(param1.@mapID);
            this.npcName = param1.@name;
            this.color = uint(param1.@color);
            this.type = param1.@type;
            if(Boolean(param1.@offSetPoint))
            {
               _loc4_ = String(param1.@offSetPoint).split("|");
               this.offSetPoint = new Point(uint(_loc4_[0]),uint(_loc4_[1]));
            }
            else
            {
               this.offSetPoint = new Point();
            }
            if(Boolean(param1.question))
            {
               this.questionA = String(param1.question).split("$");
            }
            else
            {
               this.questionA = [];
            }
            this.startIDs = NpcXMLInfo.getStartIDs(this.npcId);
            this.endIDs = NpcXMLInfo.getEndIDs(this.npcId);
            this.proIDs = NpcXMLInfo.getNpcProIDs(this.npcId);
            this.npcPath = NPC.getSceneNpcPathById(this.npcId > 90000 ? 90000 : this.npcId);
            _loc2_ = String(param1.@point).split("|");
            this.point = new Point(uint(_loc2_[0]),uint(_loc2_[1]));
            if(Boolean(param1.hasOwnProperty("@cloths")))
            {
               this.clothIds = String(param1.@cloths).split("|");
            }
            else
            {
               this.clothIds = [];
            }
            for each(_loc3_ in param1.dialog.list)
            {
               this.bubbingList.push(_loc3_.@str);
            }
            if(Boolean(param1.des))
            {
               this.dialogList = String(param1.des).split("$");
            }
            else
            {
               this.dialogList = [];
            }
         }
      }
   }
}

