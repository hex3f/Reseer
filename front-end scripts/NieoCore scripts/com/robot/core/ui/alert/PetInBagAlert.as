package com.robot.core.ui.alert
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PetInBagAlert
   {
      
      public function PetInBagAlert()
      {
         super();
      }
      
      public static function show(param1:uint, param2:String, param3:DisplayObjectContainer = null, param4:Function = null) : void
      {
         var bgmc:Sprite = null;
         var mainUI:Sprite = null;
         var applyBtn:SimpleButton = null;
         var onApply:Function = null;
         var onLoad:Function = null;
         var id:uint = param1;
         var str:String = param2;
         var par:DisplayObjectContainer = param3;
         var fun:Function = param4;
         mainUI = null;
         applyBtn = null;
         onApply = null;
         onLoad = null;
         onApply = function(param1:MouseEvent):void
         {
            if(fun != null)
            {
               fun();
            }
            LevelManager.openMouseEvent();
            applyBtn.removeEventListener(MouseEvent.CLICK,onApply);
            ResourceManager.cancel(ClientConfig.getPetSwfPath(id),onLoad);
            DisplayUtil.removeForParent(mainUI);
            txt = null;
            applyBtn = null;
            mainUI = null;
         };
         onLoad = function(param1:DisplayObject):void
         {
            var _loc2_:MovieClip = null;
            _loc2_ = param1 as MovieClip;
            DisplayUtil.stopAllMovieClip(_loc2_);
            mainUI.addChild(_loc2_);
            _loc2_.x = 100;
            _loc2_.y = 100;
         };
         mainUI = UIManager.getSprite("UI_PetSwitchAlert");
         var txt:TextField = mainUI["txt"];
         txt.htmlText = str;
         bgmc = mainUI["bgMc"];
         bgmc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            mainUI.startDrag();
         });
         bgmc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            mainUI.stopDrag();
         });
         if(Boolean(par))
         {
            par.addChild(mainUI);
         }
         else
         {
            LevelManager.topLevel.addChild(mainUI);
         }
         DisplayUtil.align(mainUI,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         applyBtn = mainUI["applyBtn"];
         applyBtn.addEventListener(MouseEvent.CLICK,onApply);
         ResourceManager.getResource(ClientConfig.getPetSwfPath(id),onLoad,"pet");
      }
   }
}

