package com.robot.app.task.books
{
   import com.robot.app.task.noviceGuide.GuideTaskModel;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class MonsterBook
   {
      
      private static var mc:MovieClip;
      
      private static var app:ApplicationDomain;
      
      private static var PATH:String = "resource/book/monsterBook.swf";
      
      public function MonsterBook()
      {
         super();
      }
      
      public static function loadPanel() : void
      {
         var _loc1_:MCLoader = null;
         if(!mc)
         {
            _loc1_ = new MCLoader(PATH,LevelManager.topLevel,1,"正在打开精灵手册");
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
         app = param1.getApplicationDomain();
         mc = new (app.getDefinition("monsterBook") as Class)() as MovieClip;
         mc.x = 463;
         mc.y = 242;
         mc.cacheAsBitmap = true;
         show();
      }
      
      private static function show() : void
      {
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mc);
         var _loc1_:SimpleButton = mc["closeBtn"];
         _loc1_.addEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
         if(GuideTaskModel.bTaskDoctor)
         {
            if(!GuideTaskModel.bReadMonBook)
            {
               GuideTaskModel.bReadMonBook = true;
               GuideTaskModel.setTaskBuf("7");
            }
         }
      }
   }
}

