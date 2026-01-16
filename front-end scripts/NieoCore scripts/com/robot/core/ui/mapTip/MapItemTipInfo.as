package com.robot.core.ui.mapTip
{
   import com.robot.core.config.xml.MapIntroXMLInfo;
   
   public class MapItemTipInfo
   {
      
      public var type:uint;
      
      public var title:String;
      
      public var content:Array;
      
      public function MapItemTipInfo(param1:uint, param2:uint)
      {
         super();
         this.type = param2;
         switch(this.type)
         {
            case 0:
               this.title = MapIntroXMLInfo.getDes(param1);
               this.content = [MapIntroXMLInfo.getDifficulty(param1),MapIntroXMLInfo.getLevel(param1)];
               break;
            case 1:
               this.title = "任务";
               this.content = MapIntroXMLInfo.getTasks(param1);
               break;
            case 2:
               this.title = "精灵";
               this.content = MapIntroXMLInfo.getSprites(param1);
               break;
            case 3:
               this.title = "矿产";
               this.content = MapIntroXMLInfo.getMinerals(param1);
               break;
            case 4:
               this.title = "游戏";
               this.content = MapIntroXMLInfo.getGames(param1);
               break;
            case 5:
               this.title = "NoNo";
               this.content = MapIntroXMLInfo.getNonos(param1);
               break;
            case 6:
               this.title = "新品上架";
               this.content = MapIntroXMLInfo.getNewgoods(param1);
               break;
            default:
               this.title = "";
               this.content = [];
         }
      }
   }
}

