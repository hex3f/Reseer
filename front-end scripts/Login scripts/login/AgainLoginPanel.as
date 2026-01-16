package login
{
   import com.robot.app.bag.BagClothPreview;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.skeleton.ClothPreview;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class AgainLoginPanel extends Sprite
   {
      
      public var miId:String;
      
      public var pwd:String = "";
      
      private var otherLog:SimpleButton;
      
      private var sRolePanelArr:Array;
      
      public function AgainLoginPanel(param1:Array)
      {
         var _loc2_:savaRolePanel = null;
         var _loc3_:Object = null;
         var _loc4_:BagClothPreview = null;
         var _loc5_:Array = null;
         var _loc6_:Number = 0;
         super();
         ItemXMLInfo.parseInfo();
         this.sRolePanelArr = new Array();
         var _loc7_:int = 0;
         while(_loc7_ < param1.length)
         {
            _loc2_ = new savaRolePanel();
            this.sRolePanelArr.push(_loc2_);
            switch(param1.length)
            {
               case 1:
                  _loc2_.x = 340;
                  break;
               case 2:
                  _loc2_.x = 150 + (_loc2_.width + 10) * _loc7_;
                  break;
               case 3:
                  _loc2_.x = 30 + (_loc2_.width + 10) * _loc7_;
            }
            _loc3_ = param1[_loc7_];
            _loc2_.y = 0;
            addChild(_loc2_);
            _loc2_.miId.text = "(" + _loc3_.id + ")";
            _loc2_.nickName.text = _loc3_.nickName;
            _loc2_.mimi = _loc3_.id;
            _loc2_.pwd = _loc3_.pwd;
            _loc2_.mouseChildren = false;
            _loc2_.buttonMode = true;
            _loc4_ = new BagClothPreview(_loc2_.compose,null,ClothPreview.MODEL_SHOW);
            _loc4_.changeColor(_loc3_.color);
            _loc5_ = [];
            for each(_loc6_ in _loc3_.clothes)
            {
               _loc5_.push(new PeopleItemInfo(_loc6_));
            }
            _loc4_.showCloths(_loc5_);
            _loc4_.showDoodle(_loc3_.texture);
            _loc2_.addEventListener(MouseEvent.CLICK,this.agLoginnn);
            _loc7_++;
         }
         this.otherLog = new otherBtna();
         this.otherLog.x = 373;
         this.otherLog.y = 400;
         this.otherLog.addEventListener(MouseEvent.CLICK,this.showLogin);
         addChild(this.otherLog);
      }
      
      private function showLogin(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         Login.loginRoot.createLogin(true);
      }
      
      private function agLoginnn(param1:MouseEvent) : void
      {
         var _loc2_:savaRolePanel = param1.target as savaRolePanel;
         this.miId = _loc2_.mimi;
         this.pwd = _loc2_.pwd;
         this.release();
         DisplayUtil.removeForParent(this);
         Login.loginRoot.createLogin(false);
      }
      
      private function release() : void
      {
      }
   }
}

