package com.robot.core.ui.alert
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormatAlign;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class IconAlert
   {
      
      public function IconAlert()
      {
         super();
      }
      
      public static function show(param1:String, param2:uint, param3:Function = null, param4:Function = null) : Sprite
      {
         var txt:TextField = null;
         var sprite:Sprite = null;
         var icon:Sprite = null;
         var applyBtn:SimpleButton = null;
         var cancelBtn:SimpleButton = null;
         var apply:Function = null;
         var cancel:Function = null;
         var str:String = param1;
         var itemID:uint = param2;
         var applyFun:Function = param3;
         var cancelFun:Function = param4;
         sprite = null;
         icon = null;
         applyBtn = null;
         cancelBtn = null;
         apply = null;
         cancel = null;
         var onLoadIcon:Function = null;
         apply = function(param1:MouseEvent):void
         {
            LevelManager.openMouseEvent();
            if(applyFun != null)
            {
               applyFun();
            }
            applyBtn.removeEventListener(MouseEvent.CLICK,apply);
            cancelBtn.removeEventListener(MouseEvent.CLICK,cancel);
            DisplayUtil.removeForParent(sprite);
         };
         cancel = function(param1:MouseEvent):void
         {
            LevelManager.openMouseEvent();
            if(cancelFun != null)
            {
               cancelFun();
            }
            applyBtn.removeEventListener(MouseEvent.CLICK,apply);
            cancelBtn.removeEventListener(MouseEvent.CLICK,cancel);
            DisplayUtil.removeForParent(sprite);
         };
         onLoadIcon = function(param1:DisplayObject):void
         {
            icon.addChild(param1);
         };
         sprite = UIManager.getSprite("AlertMC");
         var bgmc:Sprite = sprite["bgMc"];
         bgmc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            sprite.startDrag();
         });
         bgmc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            sprite.stopDrag();
         });
         icon = new Sprite();
         icon.mouseChildren = icon.mouseEnabled = false;
         sprite.addChild(icon);
         DisplayUtil.align(icon,new Rectangle(40,60,217,90),AlignType.TOP_CENTER);
         LevelManager.topLevel.addChild(sprite);
         DisplayUtil.align(sprite,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         txt = sprite["txt"];
         txt.autoSize = TextFormatAlign.CENTER;
         txt.width = 265;
         txt.htmlText = str;
         DisplayUtil.align(txt,new Rectangle(40,60,265,90),AlignType.BOTTOM_CENTER);
         applyBtn = sprite["applyBtn"];
         cancelBtn = sprite["cancelBtn"];
         applyBtn.addEventListener(MouseEvent.CLICK,apply);
         cancelBtn.addEventListener(MouseEvent.CLICK,cancel);
         ResourceManager.getResource(ItemXMLInfo.getIconURL(itemID),onLoadIcon);
         return sprite;
      }
   }
}

