package com.robot.core.ui.alert
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class AchieveTitleAlert
   {
      
      public function AchieveTitleAlert()
      {
         super();
      }
      
      public static function show(param1:uint, param2:String, param3:Function = null, param4:Boolean = false) : Sprite
      {
         var bgmc:Sprite = null;
         var txt:TextField = null;
         var sprite:Sprite = null;
         var icon:Sprite = null;
         var applyBtn:SimpleButton = null;
         var apply:Function = null;
         var id:uint = param1;
         var str:String = param2;
         var applyFun:Function = param3;
         var isMouse:Boolean = param4;
         sprite = null;
         icon = null;
         applyBtn = null;
         apply = null;
         var onLoadIcon:Function = null;
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
         onLoadIcon = function(param1:DisplayObject):void
         {
            icon.addChild(param1);
            icon.x = (bgmc.width - param1.width) / 2;
         };
         sprite = UIManager.getSprite("AchieveTitleMC");
         bgmc = sprite["bgMc"];
         icon = new Sprite();
         icon.y = 90;
         sprite.addChild(icon);
         bgmc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            sprite.startDrag();
         });
         bgmc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            sprite.stopDrag();
         });
         LevelManager.topLevel.addChild(sprite);
         DisplayUtil.align(sprite,null,AlignType.MIDDLE_CENTER);
         if(!isMouse)
         {
            LevelManager.closeMouseEvent();
         }
         txt = sprite["txt"];
         txt.htmlText = str;
         applyBtn = sprite["applyBtn"];
         applyBtn.addEventListener(MouseEvent.CLICK,apply);
         ResourceManager.getResource(ClientConfig.getResPath("achieve/title/" + id.toString() + ".swf"),onLoadIcon,"title");
         return sprite;
      }
   }
}

