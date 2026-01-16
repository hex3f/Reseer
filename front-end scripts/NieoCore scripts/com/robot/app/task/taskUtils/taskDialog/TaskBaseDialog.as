package com.robot.app.task.taskUtils.taskDialog
{
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskBaseDialog
   {
      
      public static var dialogMC:MovieClip;
      
      private static var _fun:Function;
      
      private static var taskAwardDialog:MovieClip;
      
      public function TaskBaseDialog()
      {
         super();
      }
      
      public static function showNpcImgDialog(param1:String = "", param2:Function = null) : void
      {
         initDialog(new Point(0,-80),param2);
         var _loc3_:SimpleButton = dialogMC["closeBtn"];
         _loc3_.addEventListener(MouseEvent.CLICK,onRemove);
      }
      
      private static function onRemove(param1:MouseEvent) : void
      {
         removeDialog();
      }
      
      private static function removeDialog() : void
      {
         DisplayUtil.removeForParent(dialogMC);
         LevelManager.openMouseEvent();
         dialogMC = null;
         if(_fun != null)
         {
            _fun();
         }
      }
      
      public static function showAwardDialog(param1:String = "", param2:Function = null) : void
      {
         initDialog(null,param2);
      }
      
      private static function initDialog(param1:Point = null, param2:Function = null) : void
      {
         var dragMc:SimpleButton = null;
         var okBtn:SimpleButton = null;
         var pt:Point = param1;
         var okFun:Function = param2;
         _fun = okFun;
         LevelManager.topLevel.addChild(dialogMC);
         DisplayUtil.align(dialogMC,null,AlignType.MIDDLE_CENTER,pt);
         LevelManager.closeMouseEvent();
         dragMc = dialogMC["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            dialogMC.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            dialogMC.stopDrag();
         });
         okBtn = dialogMC["okBtn"];
         okBtn.addEventListener(MouseEvent.CLICK,onRemove);
      }
      
      public static function showTaskAwardDialog(param1:String = "", param2:DisplayObject = null, param3:Point = null, param4:Function = null) : void
      {
         var dragMc:SimpleButton = null;
         var txt:TextField = null;
         var okBtn:SimpleButton = null;
         var remove:Function = null;
         var str:String = param1;
         var awardImg:DisplayObject = param2;
         var pt:Point = param3;
         var okFun:Function = param4;
         okBtn = null;
         remove = null;
         remove = function(param1:MouseEvent):void
         {
            LevelManager.openMouseEvent();
            okBtn.removeEventListener(MouseEvent.CLICK,remove);
            DisplayUtil.removeForParent(taskAwardDialog);
            awardImg = null;
            taskAwardDialog = null;
            dragMc = null;
            if(okFun != null)
            {
               okFun();
            }
         };
         if(pt == null)
         {
            pt = new Point(55,52);
         }
         taskAwardDialog = UIManager.getMovieClip("taskAwardDialog");
         if(Boolean(awardImg))
         {
            awardImg.x = pt.x;
            awardImg.y = pt.y;
            taskAwardDialog.addChild(awardImg);
         }
         LevelManager.topLevel.addChild(taskAwardDialog);
         DisplayUtil.align(taskAwardDialog,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         dragMc = taskAwardDialog["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            taskAwardDialog.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            taskAwardDialog.stopDrag();
         });
         txt = taskAwardDialog["txt"];
         txt.htmlText = str;
         okBtn = taskAwardDialog["okBtn"];
         okBtn.addEventListener(MouseEvent.CLICK,remove);
      }
   }
}

