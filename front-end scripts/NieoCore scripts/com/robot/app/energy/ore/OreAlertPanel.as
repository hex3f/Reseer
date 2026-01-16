package com.robot.app.energy.ore
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class OreAlertPanel
   {
      
      private static var oreTip:MovieClip;
      
      public function OreAlertPanel()
      {
         super();
      }
      
      public static function createOreAlert(param1:String, param2:Function = null, param3:Function = null) : void
      {
         var dragMc:SimpleButton = null;
         var tipTxt:TextField = null;
         var exitBtn:SimpleButton = null;
         var applyBtn:SimpleButton = null;
         var cancelBtn:SimpleButton = null;
         var apply:Function = null;
         var cancel:Function = null;
         var tipStr:String = param1;
         var applyFun:Function = param2;
         var cancelFun:Function = param3;
         exitBtn = null;
         applyBtn = null;
         cancelBtn = null;
         apply = null;
         cancel = null;
         apply = function(param1:MouseEvent):void
         {
            DisplayUtil.removeForParent(oreTip);
            exitBtn.removeEventListener(MouseEvent.CLICK,cancel);
            applyBtn.removeEventListener(MouseEvent.CLICK,apply);
            cancelBtn.removeEventListener(MouseEvent.CLICK,cancel);
            LevelManager.openMouseEvent();
            if(applyFun != null)
            {
               applyFun();
            }
         };
         cancel = function(param1:MouseEvent):void
         {
            LevelManager.openMouseEvent();
            DisplayUtil.removeForParent(oreTip);
            exitBtn.removeEventListener(MouseEvent.CLICK,cancel);
            applyBtn.removeEventListener(MouseEvent.CLICK,apply);
            cancelBtn.removeEventListener(MouseEvent.CLICK,cancel);
            if(cancelFun != null)
            {
               cancelFun();
            }
         };
         if(oreTip == null)
         {
            oreTip = UIManager.getMovieClip("oreTipMc");
         }
         dragMc = oreTip["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            oreTip.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            oreTip.stopDrag();
         });
         LevelManager.topLevel.addChild(oreTip);
         DisplayUtil.align(oreTip,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         tipTxt = oreTip["tipTxt"];
         tipTxt.text = tipStr;
         exitBtn = oreTip["closeBtn"];
         exitBtn.addEventListener(MouseEvent.CLICK,cancel);
         applyBtn = oreTip["okBtn"];
         cancelBtn = oreTip["cancelBtn"];
         applyBtn.addEventListener(MouseEvent.CLICK,apply);
         cancelBtn.addEventListener(MouseEvent.CLICK,cancel);
      }
   }
}

