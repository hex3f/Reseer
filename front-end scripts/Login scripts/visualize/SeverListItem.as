package visualize
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.ServerConfig;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import others.ServerInfo;
   
   public class SeverListItem extends Sprite
   {
      
      private var oneSvrInfo:ServerInfo;
      
      private var oneItem:slist;
      
      public function SeverListItem()
      {
         super();
         this.oneItem = new slist();
         this.oneItem.s1.gotoAndStop(2);
         this.oneItem.s2.stop();
         this.oneItem.s3.stop();
         this.oneItem.s4.stop();
         this.oneItem.s5.stop();
         this.oneItem.fullMC.visible = false;
         this.oneItem.noChatMC.visible = false;
         addChild(this.oneItem);
      }
      
      public function refresh() : void
      {
         this.oneItem.fullMC.visible = false;
         this.mouseEnabled = true;
         this.oneItem.s1.gotoAndStop(2);
         this.oneItem.s2.gotoAndStop(1);
         this.oneItem.s3.gotoAndStop(1);
         this.oneItem.s4.gotoAndStop(1);
         this.oneItem.s5.gotoAndStop(1);
         this.oneItem.noChatMC.visible = false;
         this.oneItem.sText.text = this.oneSvrInfo.OnlineID.toString();
         this.oneItem.svrName.text = ServerConfig.getNameByID(this.oneSvrInfo.OnlineID);
         if(this.oneSvrInfo.Friends != 0)
         {
            this.oneItem.statusHeadMC.gotoAndStop(2);
         }
         var _loc1_:* = uint(Math.ceil(this.oneSvrInfo.UserCnt / ClientConfig.maxPeople * 5));
         if(_loc1_ > 5)
         {
            _loc1_ = 5;
         }
         while(_loc1_ >= 1 && _loc1_ <= 5)
         {
            (this.oneItem["s" + _loc1_.toString()] as MovieClip).gotoAndStop(2);
            _loc1_--;
         }
         if(this.oneSvrInfo.UserCnt >= ClientConfig.maxPeople)
         {
            this.oneItem.fullMC.visible = true;
            if(!Login.isVip)
            {
               this.mouseEnabled = false;
            }
            this.oneItem.s5.gotoAndStop(2);
         }
         if(this.oneSvrInfo.UserCnt < ClientConfig.maxPeople)
         {
            this.oneItem.s5.gotoAndStop(1);
         }
      }
      
      public function get info() : ServerInfo
      {
         return this.oneSvrInfo;
      }
      
      public function set info(param1:ServerInfo) : void
      {
         this.oneSvrInfo = param1;
      }
   }
}

