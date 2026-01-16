package com.robot.app.mapProcess
{
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.ActorModel;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MapProcess_461 extends BaseMapProcess
   {
      
      private var model:ActorModel;
      
      private var edj_npc:MovieClip;
      
      private var treeMc:MovieClip;
      
      public function MapProcess_461()
      {
         super();
      }
      
      override protected function init() : void
      {
         ToolBarController.showOrHideAllUser(false);
         this.edj_npc = depthLevel["erdangjia"];
         this.edj_npc.visible = false;
         this.conLevel["taskMC"].visible = false;
         this.conLevel["dumpLightMc0"].visible = false;
         this.conLevel["dumpLightMc1"].visible = false;
         this.conLevel["dumpLightMc2"].visible = false;
         this.conLevel["dumpLightMc3"].visible = false;
         this.conLevel["dumpLightMc4"].visible = false;
         this.conLevel["task_561_2"].visible = false;
         this.conLevel["task_561_4"].visible = false;
         this.topLevel["task_561_1"].visible = false;
         this.treeMc = this.topLevel["tree"] as MovieClip;
         this.treeMc.stop();
         this.treeMc.addEventListener(Event.ENTER_FRAME,this.onTreeFrame);
         this.treeMc.gotoAndPlay(1);
      }
      
      private function onTreeFrame(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.currentFrame == _loc2_.totalFrames || _loc2_.currentFrame == 3)
         {
            _loc2_.gotoAndPlay(1);
         }
      }
      
      override public function destroy() : void
      {
         ToolBarController.showOrHideAllUser(true);
         if(Boolean(this.treeMc))
         {
            this.treeMc.removeEventListener(Event.ENTER_FRAME,this.onTreeFrame);
            this.treeMc = null;
         }
      }
   }
}

