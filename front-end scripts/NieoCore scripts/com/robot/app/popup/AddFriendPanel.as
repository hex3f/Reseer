package com.robot.app.popup
{
   import org.taomee.utils.DisplayUtil;
   
   public class AddFriendPanel
   {
      
      private static var _instance:AddFriendPanelImpl;
      
      public function AddFriendPanel()
      {
         super();
      }
      
      private static function get instance() : AddFriendPanelImpl
      {
         if(_instance == null)
         {
            _instance = new AddFriendPanelImpl();
         }
         return _instance;
      }
      
      public static function show() : void
      {
         if(DisplayUtil.hasParent(instance))
         {
            instance.destroy();
         }
         else
         {
            instance.show();
         }
      }
   }
}

import com.robot.core.manager.LevelManager;
import com.robot.core.manager.RelationManager;
import com.robot.core.manager.UIManager;
import com.robot.core.ui.alert.Alarm;
import com.robot.core.ui.alert.Alert;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.EventDispatcher;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import org.taomee.utils.AlignType;
import org.taomee.utils.DisplayUtil;

class AddFriendPanelImpl extends Sprite
{
   
   private static const TEXT:String = "[请输入对方米米号]";
   
   private var _mainUI:Sprite;
   
   private var _txt:TextField;
   
   private var _applyBtn:SimpleButton;
   
   private var _cancelBtn:SimpleButton;
   
   private var _bgmc:Sprite;
   
   public function AddFriendPanelImpl()
   {
      super();
      this._mainUI = UIManager.getSprite("AddFriendMC");
      this._txt = this._mainUI["txt"];
      this._applyBtn = this._mainUI["applyBtn"];
      this._cancelBtn = this._mainUI["cancelBtn"];
      this._bgmc = this._mainUI["bgMc"];
      addChild(this._mainUI);
      this._txt.restrict = "0-9";
      this._txt.maxChars = 20;
      this._txt.text = TEXT;
   }
   
   public function show() : void
   {
      LevelManager.appLevel.addChild(this);
      DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
      this._applyBtn.addEventListener(MouseEvent.CLICK,this.onApply);
      this._cancelBtn.addEventListener(MouseEvent.CLICK,this.onCancel);
      this._txt.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
      this._bgmc.addEventListener(MouseEvent.MOUSE_DOWN,this.onBgDown);
   }
   
   public function destroy() : void
   {
      this._applyBtn.removeEventListener(MouseEvent.CLICK,this.onApply);
      this._cancelBtn.removeEventListener(MouseEvent.CLICK,this.onCancel);
      this._txt.removeEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
      this._bgmc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBgDown);
      DisplayUtil.removeForParent(this);
   }
   
   private function onBgDown(param1:MouseEvent) : void
   {
      startDrag();
      this._bgmc.addEventListener(MouseEvent.MOUSE_UP,this.onBgUp);
      this._bgmc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBgDown);
   }
   
   private function onBgUp(param1:MouseEvent) : void
   {
      stopDrag();
      this._bgmc.addEventListener(MouseEvent.MOUSE_DOWN,this.onBgDown);
      this._bgmc.removeEventListener(MouseEvent.MOUSE_UP,this.onBgUp);
   }
   
   private function onFocusIn(param1:FocusEvent) : void
   {
      this._txt.text = "";
      this._txt.removeEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
      this._txt.addEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
   }
   
   private function onFocusOut(param1:FocusEvent) : void
   {
      if(this._txt.text == "")
      {
         this._txt.text = TEXT;
      }
      this._txt.removeEventListener(FocusEvent.FOCUS_OUT,this.onFocusOut);
      this._txt.addEventListener(FocusEvent.FOCUS_IN,this.onFocusIn);
   }
   
   private function onApply(param1:MouseEvent) : void
   {
      var e:MouseEvent = param1;
      var num:int = 0;
      if(this._txt.text != "" && this._txt.text != TEXT)
      {
         num = parseInt(this._txt.text);
         if(num > 50000 && num < 2000000000)
         {
            Alert.show("你想和(" + this._txt.text + ")\r成为好友吗?",function():void
            {
               RelationManager.addFriend(uint(_txt.text));
            });
         }
         else
         {
            Alarm.show("输入的米米号不正确!");
         }
      }
      this.destroy();
   }
   
   private function onCancel(param1:MouseEvent) : void
   {
      this.destroy();
   }
}
