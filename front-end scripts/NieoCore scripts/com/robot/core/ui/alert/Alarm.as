package com.robot.core.ui.alert
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormatAlign;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class Alarm
   {
      
      public function Alarm()
      {
         super();
      }
      
      public static function show(param1:String, param2:Function = null, param3:Boolean = false, param4:Boolean = false) : Sprite
      {
         var bgmc:Sprite = null;
         var txt:TextField = null;
         var sprite:Sprite = null;
         var applyBtn:SimpleButton = null;
         var apply:Function = null;
         var str:String = param1;
         var applyFun:Function = param2;
         var isColor:Boolean = param3;
         var isMouse:Boolean = param4;
         sprite = null;
         applyBtn = null;
         apply = null;
         apply = function(param1:MouseEvent):void
         {
            LevelManager.openMouseEvent();
            if(applyFun != null)
            {
               applyFun();
            }
            applyBtn.removeEventListener(MouseEvent.CLICK,apply);
            DisplayUtil.removeForParent(sprite);
         };
         if(isColor)
         {
            sprite = UIManager.getSprite("AlarmMc_Orange");
         }
         else
         {
            sprite = UIManager.getSprite("AlarmMC");
         }
         bgmc = sprite["bgMc"];
         bgmc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            sprite.startDrag();
         });
         bgmc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            sprite.stopDrag();
         });
         LevelManager.tipLevel.addChild(sprite);
         DisplayUtil.align(sprite,null,AlignType.MIDDLE_CENTER);
         if(!isMouse)
         {
            LevelManager.closeMouseEvent();
         }
         txt = sprite["txt"];
         txt.autoSize = TextFormatAlign.CENTER;
         txt.width = 265;
         txt.htmlText = str;
         txt.addEventListener(TextEvent.LINK,function(param1:TextEvent):void
         {
            param1.stopImmediatePropagation();
            sprite.dispatchEvent(param1);
         });
         DisplayUtil.align(txt,new Rectangle(40,60,265,90),AlignType.MIDDLE_CENTER);
         applyBtn = sprite["applyBtn"];
         applyBtn.addEventListener(MouseEvent.CLICK,apply);
         return sprite;
      }
   }
}

