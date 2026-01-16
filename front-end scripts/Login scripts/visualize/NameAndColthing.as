package visualize
{
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.utils.ByteArray;
   import login.LoginPanel;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.StringUtil;
   import register.RegisterManage;
   import tip.TipPanel;
   
   public class NameAndColthing extends Sprite
   {
      
      private static var _robotId:String;
      
      private static var colorNum:uint;
      
      private var nickTxt:TextField;
      
      private var nextStep:SimpleButton;
      
      private var loPanel:LoginPanel;
      
      private var putRot:selfRobot;
      
      private var allInfo:GetAllInfo;
      
      private var role:mainRoll;
      
      private var codeTxt:TextField;
      
      public function NameAndColthing()
      {
         super();
         this.putRot = new selfRobot();
         this.putRot.x = 0;
         this.putRot.y = 0;
         addChild(this.putRot);
         this.nickTxt = this.putRot.robotIdTxt;
         this.nickTxt.type = TextFieldType.INPUT;
         this.nickTxt.addEventListener(Event.CHANGE,this.onTxtChange);
         this.nextStep = this.putRot.okBtn;
         this.nextStep.addEventListener(MouseEvent.CLICK,this.showRobotColor);
         this.codeTxt = this.putRot.codeTxt;
         if(RegisterManage.bDirectReg)
         {
            if(SeerVerify.verifyCode == 0)
            {
               this.codeTxt.text = "";
               this.putRot.codeBgMC.visible = false;
               this.putRot.codeBgMC1.visible = true;
               trace("");
            }
            else
            {
               this.codeTxt.text = SeerVerify.verifyCode.toString();
            }
            this.codeTxt.type = TextFieldType.DYNAMIC;
         }
         this.putRot.c1.addEventListener(MouseEvent.CLICK,this.c1);
         this.putRot.c2.addEventListener(MouseEvent.CLICK,this.c2);
         this.putRot.c3.addEventListener(MouseEvent.CLICK,this.c3);
         this.putRot.c4.addEventListener(MouseEvent.CLICK,this.c4);
         this.putRot.c5.addEventListener(MouseEvent.CLICK,this.c5);
         this.putRot.c6.addEventListener(MouseEvent.CLICK,this.c6);
         this.putRot.c7.addEventListener(MouseEvent.CLICK,this.c7);
         this.putRot.c8.addEventListener(MouseEvent.CLICK,this.c8);
         this.role = AcceptRule.myRole;
      }
      
      public static function get robotId() : String
      {
         return _robotId;
      }
      
      public static function getColor() : uint
      {
         return colorNum;
      }
      
      private function clearCodeTxt(param1:Event) : void
      {
         this.codeTxt.removeEventListener(FocusEvent.FOCUS_IN,this.clearCodeTxt);
         this.codeTxt.text = "";
         this.codeTxt.restrict = "0-9";
      }
      
      private function onTxtChange(param1:Event) : void
      {
         if(this.checkNickLength())
         {
            return;
         }
      }
      
      private function showRobotColor(param1:MouseEvent) : void
      {
         if(this.nickTxt.text == "")
         {
            TipPanel.createTipPanel("请输入机器人ID");
            return;
         }
         if(this.checkNickLength())
         {
            return;
         }
         if(!RegisterManage.bDirectReg)
         {
            this.showNext();
            SeerVerify.verifyCode = 0;
         }
         else
         {
            this.showNext();
         }
      }
      
      private function checkNickLength() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(this.nickTxt.text);
         if(_loc2_.length > 15)
         {
            this.nickTxt.text = StringUtil.trim(this.nickTxt.text);
            this.nickTxt.type = TextFieldType.DYNAMIC;
            this.nickTxt.setSelection(0,1);
            TipPanel.createTipPanel("输入的文字太长了",this.onReceive);
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      private function onReceive() : void
      {
         this.nickTxt.type = TextFieldType.INPUT;
      }
      
      private function showNext() : void
      {
         _robotId = this.nickTxt.text;
         this.visible = false;
         this.allInfo = new GetAllInfo(this);
         this.allInfo.x = 100;
         this.allInfo.y = 100;
         Login.loginRoot.addChild(this.allInfo);
         this.role.visible = false;
      }
      
      private function onVerifyOK(param1:Event) : void
      {
         EventManager.removeEventListener(SeerVerify.SEER_VERIFY_OK,this.onVerifyOK);
         this.showNext();
      }
      
      private function c1(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 16776960;
         colorNum = 16776960;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c2(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 65280;
         colorNum = 65280;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c3(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 16596542;
         colorNum = 16596542;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c4(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 16737536;
         colorNum = 16737536;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c5(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 255;
         colorNum = 255;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c6(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 10053120;
         colorNum = 10053120;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c7(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 16777215;
         colorNum = 16777215;
         this.role.color.transform.colorTransform = _loc2_;
      }
      
      private function c8(param1:MouseEvent) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         _loc2_.color = 0;
         colorNum = 0;
         this.role.color.transform.colorTransform = _loc2_;
      }
   }
}

