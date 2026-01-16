package com.robot.app.task.books
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MimiCard
   {
      
      private static var mc:MovieClip;
      
      private static var PATH:String = "resource/book/mimicard.swf";
      
      public function MimiCard()
      {
         super();
      }
      
      public static function loadPanel() : void
      {
         var _loc1_:MCLoader = null;
         if(!mc)
         {
            _loc1_ = new MCLoader(PATH,LevelManager.topLevel,1,"正在打开米米卡手册");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoad);
            _loc1_.doLoad();
         }
         else
         {
            mc.gotoAndStop(1);
            show();
         }
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         mc = param1.getContent() as MovieClip;
         show();
      }
      
      private static function show() : void
      {
         DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mc);
         var _loc1_:SimpleButton = mc["closeBtn"];
         _loc1_.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
         mc = null;
      }
   }
}

