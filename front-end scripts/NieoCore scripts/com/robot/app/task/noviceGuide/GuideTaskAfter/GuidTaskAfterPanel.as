package com.robot.app.task.noviceGuide.GuideTaskAfter
{
   import com.robot.app.task.taskUtils.manage.TaskUIManage;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class GuidTaskAfterPanel
   {
      
      private var mc:MovieClip;
      
      private var fightBtn:SimpleButton;
      
      public function GuidTaskAfterPanel()
      {
         super();
      }
      
      public function show() : void
      {
         var dragMc:SimpleButton = null;
         var closeBtn:SimpleButton = null;
         this.mc = TaskUIManage.getMovieClip("taskAfterPanel",4);
         this.fightBtn = this.mc["fightBtn"];
         DisplayUtil.align(this.mc,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.topLevel.addChild(this.mc);
         this.fightBtn.addEventListener(MouseEvent.CLICK,this.startFight);
         this.mc["okBtn"].addEventListener(MouseEvent.CLICK,this.startFight);
         dragMc = this.mc["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            mc.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            mc.stopDrag();
         });
         closeBtn = this.mc["closeBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,this.onExit);
      }
      
      private function onExit(param1:Event) : void
      {
         LevelManager.topLevel.removeChild(this.mc);
         LevelManager.openMouseEvent();
         this.fightBtn.removeEventListener(MouseEvent.CLICK,this.startFight);
         if(MapManager.currentMap.id == 8)
         {
            GuideTaskFight.fight();
         }
      }
      
      private function startFight(param1:MouseEvent) : void
      {
         LevelManager.topLevel.removeChild(this.mc);
         LevelManager.openMouseEvent();
         this.fightBtn.removeEventListener(MouseEvent.CLICK,this.startFight);
         GuideTaskFight.fight();
      }
   }
}

