package visualize
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import login.LoginPanel;
   import org.taomee.utils.DisplayUtil;
   import tip.TipPanel;
   
   public class AcceptRule extends Sprite
   {
      
      public static var myRole:mainRoll;
      
      private var actionRuleTxt:TextField;
      
      private var nextStep:SimpleButton;
      
      private var nickPanel:NameAndColthing;
      
      private var loPanel:LoginPanel;
      
      private var acPP:acceptPP;
      
      private var bAccept:Boolean = false;
      
      private var mailRole:mainRoll;
      
      public function AcceptRule()
      {
         super();
         DisplayUtil.removeForParent(Login.bg1);
         var _loc1_:robotBg = new robotBg();
         _loc1_.x = -10;
         _loc1_.y = 0;
         Login.loginRoot.addChild(_loc1_);
         this.mailRole = new mainRoll();
         this.mailRole.x = 73;
         this.mailRole.y = 92;
         Login.loginRoot.addChild(this.mailRole);
         myRole = this.mailRole;
         this.acPP = new acceptPP();
         this.acPP.x = 0;
         this.acPP.y = 0;
         this.addChild(this.acPP);
         this.acPP.accptBtn.addEventListener(MouseEvent.CLICK,this.acceptRule);
         this.nextStep = this.acPP.acNext;
         this.acPP.acRight.visible = false;
         this.nextStep.addEventListener(MouseEvent.CLICK,this.createNickId);
      }
      
      private function onExit(param1:MouseEvent) : void
      {
         Login.loginRoot.lp.visible = true;
         this.visible = false;
      }
      
      private function acceptRule(param1:MouseEvent) : void
      {
         this.acPP.acRight.visible = !this.acPP.acRight.visible;
      }
      
      private function createNickId(param1:MouseEvent) : void
      {
         if(this.acPP.acRight.visible == false)
         {
            TipPanel.createTipPanel("请你接受行动纪律");
            return;
         }
         this.visible = false;
         this.nickPanel = new NameAndColthing();
         this.nickPanel.x = 442;
         this.nickPanel.y = 42;
         Login.loginRoot.addChild(this.nickPanel);
         DisplayUtil.removeForParent(this.acPP);
         this.acPP = null;
         DisplayUtil.removeForParent(this);
      }
   }
}

