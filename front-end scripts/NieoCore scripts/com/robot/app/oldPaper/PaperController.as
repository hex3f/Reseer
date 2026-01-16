package com.robot.app.oldPaper
{
   import com.robot.core.manager.LevelManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class PaperController
   {
      
      private static var mc:MovieClip;
      
      private static var posArray:Array = [new Point(70,26),new Point(480,287),new Point(480,287),new Point(480,287),new Point(567,294),new Point(567,294),new Point(567,294),new Point(567,294)];
      
      public function PaperController()
      {
         super();
      }
      
      public static function setup(param1:ApplicationDomain, param2:uint) : void
      {
         mc = new (param1.getDefinition("timeNews") as Class)() as MovieClip;
         mc.stop();
         (mc["bookMC"] as MovieClip).stop();
         show(param2);
      }
      
      private static function show(param1:uint) : void
      {
         var _loc2_:Point = posArray[param1];
         if(!_loc2_)
         {
            _loc2_ = new Point(567,294);
         }
         mc.x = _loc2_.x;
         mc.y = _loc2_.y;
         LevelManager.closeMouseEvent();
         LevelManager.topLevel.addChild(mc);
         var _loc3_:SimpleButton = mc["exitBtn"];
         _loc3_.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
      }
   }
}

