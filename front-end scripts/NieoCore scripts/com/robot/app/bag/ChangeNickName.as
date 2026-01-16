package com.robot.app.bag
{
   import com.robot.app.ParseSocketError;
   import com.robot.core.manager.MainManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.StringUtil;
   
   public class ChangeNickName
   {
      
      private var chNickBtn:SimpleButton;
      
      private var chNickTagBtn:SimpleButton;
      
      private var nickTxt:TextField;
      
      public function ChangeNickName()
      {
         super();
      }
      
      public function init(param1:MovieClip) : void
      {
         this.nickTxt = param1["name_txt"];
         this.nickTxt.text = MainManager.actorInfo.nick;
         this.nickTxt.addEventListener(Event.CHANGE,this.onTxtChange);
         this.nickTxt.selectable = true;
         this.nickTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown);
         this.chNickBtn = param1["chNickBtn"] as SimpleButton;
         this.chNickTagBtn = param1["chNickTagBtn"] as SimpleButton;
         this.chNickTagBtn.visible = false;
         this.chNickBtn.addEventListener(MouseEvent.CLICK,this.onChangeTag);
      }
      
      private function onChangeTag(param1:MouseEvent) : void
      {
         this.chNickTagBtn.visible = true;
         this.chNickBtn.visible = false;
         this.nickTxt.type = TextFieldType.INPUT;
         this.nickTxt.background = true;
         this.nickTxt.backgroundColor = 11131128;
         MainManager.getStage().focus = this.nickTxt;
         this.chNickTagBtn.addEventListener(MouseEvent.CLICK,this.onChangeName);
         EventManager.addEventListener(ParseSocketError.NAME_BAD_LANGUAGE,this.onBadName);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.ENTER)
         {
            this.changeName();
         }
      }
      
      private function onBadName(param1:Event) : void
      {
         EventManager.removeEventListener(ParseSocketError.NAME_BAD_LANGUAGE,this.onBadName);
         this.nickTxt.text = MainManager.actorInfo.nick;
      }
      
      private function onChangeName(param1:MouseEvent) : void
      {
         this.changeName();
      }
      
      private function changeName() : void
      {
         this.nickTxt.text = StringUtil.trim(this.nickTxt.text);
         if(this.nickTxt.text == "")
         {
            Alarm.show("昵称不能为空");
            return;
         }
         if(this.checkNickLength())
         {
            return;
         }
         this.chNickTagBtn.visible = false;
         this.chNickBtn.visible = true;
         this.nickTxt.type = TextFieldType.DYNAMIC;
         this.nickTxt.background = false;
         if(this.nickTxt.text == MainManager.actorInfo.nick)
         {
            return;
         }
         MainManager.actorModel.changeNickName(this.nickTxt.text);
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
            Alarm.show("输入的文字太长了",this.onReceive);
            _loc1_ = true;
         }
         return _loc1_;
      }
      
      private function onReceive() : void
      {
         this.nickTxt.type = TextFieldType.INPUT;
      }
      
      private function onTxtChange(param1:Event) : void
      {
         if(this.checkNickLength())
         {
            return;
         }
      }
      
      public function destory() : void
      {
         this.chNickTagBtn.visible = false;
         this.chNickBtn.visible = true;
         this.nickTxt.type = TextFieldType.DYNAMIC;
         this.nickTxt.background = false;
      }
   }
}

