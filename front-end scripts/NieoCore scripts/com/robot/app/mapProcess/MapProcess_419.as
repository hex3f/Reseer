package com.robot.app.mapProcess
{
   import com.robot.app.task.taskscollection.Task748;
   import com.robot.app.task.taskscollection.Task775;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UserManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.BasePeoleModel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import org.taomee.manager.EventManager;
   
   public class MapProcess_419 extends BaseMapProcess
   {
      
      private var _riverMC:MovieClip;
      
      private var _fogMC:MovieClip;
      
      public function MapProcess_419()
      {
         super();
      }
      
      override protected function init() : void
      {
         this._riverMC = conLevel["riverMC"];
         this._riverMC.addEventListener(MouseEvent.MOUSE_OVER,this.onOverRiver);
         this._riverMC.addEventListener(MouseEvent.MOUSE_OUT,this.onOutRiver);
         this._fogMC = this._riverMC["fog"];
         this._fogMC.stop();
         this._fogMC.visible = false;
         EventManager.addEventListener(RobotEvent.CREATED_MAP_USER,this.onUserHandler);
         conLevel["npcMC"].visible = false;
         Task775.initTaskForMap419(this);
         Task748.initTaskForMap419(this);
      }
      
      private function onUserHandler(param1:RobotEvent) : void
      {
         this.configModel(0.4,1.2);
      }
      
      override public function destroy() : void
      {
         if(Boolean(MainManager.actorModel.pet))
         {
            MainManager.actorModel.pet.scaleX = MainManager.actorModel.pet.scaleY = 1;
         }
         MainManager.actorModel.scaleX = MainManager.actorModel.scaleY = 1;
         EventManager.removeEventListener(RobotEvent.CREATED_MAP_USER,this.onUserHandler);
         this._riverMC.removeEventListener(MouseEvent.MOUSE_OVER,this.onOverRiver);
         this._riverMC.removeEventListener(MouseEvent.MOUSE_OUT,this.onOutRiver);
         Task775.destroy();
         Task748.destroy();
      }
      
      private function onOverRiver(param1:MouseEvent) : void
      {
         this._fogMC.visible = true;
         this._fogMC.play();
      }
      
      private function onOutRiver(param1:MouseEvent) : void
      {
         this._fogMC.visible = false;
         this._fogMC.stop();
      }
      
      private function configModel(param1:Number, param2:Number) : void
      {
         var _loc3_:BasePeoleModel = null;
         MainManager.actorModel.scaleX = MainManager.actorModel.scaleY = param1;
         if(Boolean(MainManager.actorModel.pet))
         {
            MainManager.actorModel.pet.scaleX = MainManager.actorModel.pet.scaleY = param2;
         }
         for each(_loc3_ in UserManager.getUserModelList())
         {
            if(Boolean(_loc3_))
            {
               _loc3_.scaleX = _loc3_.scaleY = param1;
               if(Boolean(_loc3_.pet))
               {
                  _loc3_.pet.scaleX = _loc3_.pet.scaleY = param2;
               }
            }
         }
      }
   }
}

