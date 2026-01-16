package com.robot.app.taskPanel
{
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.manager.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.effect.ColorFilter;
   
   public class TaskListItem extends Sprite
   {
      
      private var mc:MovieClip;
      
      private var _id:uint;
      
      private var _status:uint;
      
      public function TaskListItem(param1:uint)
      {
         var _loc2_:* = 0;
         super();
         this._id = param1;
         this.mc = AssetsManager.getMovieClip("ui_listItemMC");
         this.mc["bgMC"].gotoAndStop(1);
         addChild(this.mc);
         var _loc3_:TextField = this.mc["txt"];
         _loc3_.text = TasksXMLInfo.getName(param1);
         this.mouseChildren = false;
         this.buttonMode = true;
         this.addEventListener(MouseEvent.MOUSE_OVER,this.overHandler);
         this.addEventListener(MouseEvent.MOUSE_OUT,this.outHandler);
         if(this.id == 1 || this._id == 2 || this._id == 3 || this._id == 4)
         {
            _loc2_ = uint(TasksManager.ALR_ACCEPT);
            if(TasksManager.getTaskStatus(1) == _loc2_ || TasksManager.getTaskStatus(2) == _loc2_ || TasksManager.getTaskStatus(3) == _loc2_ || TasksManager.getTaskStatus(4) == _loc2_)
            {
               this._status = TasksManager.ALR_ACCEPT;
            }
         }
         else
         {
            this._status = TasksManager.getTaskStatus(param1);
         }
         if(this._status == TasksManager.ALR_ACCEPT)
         {
            this.filters = [ColorFilter.setHue(180),ColorFilter.setContrast(30)];
         }
      }
      
      public function get status() : uint
      {
         return this._status;
      }
      
      public function get id() : uint
      {
         return this._id;
      }
      
      private function overHandler(param1:MouseEvent) : void
      {
         this.mc["bgMC"].gotoAndStop(2);
      }
      
      private function outHandler(param1:MouseEvent) : void
      {
         this.mc["bgMC"].gotoAndStop(1);
      }
      
      public function destroy() : void
      {
         this.removeEventListener(MouseEvent.MOUSE_OVER,this.overHandler);
         this.removeEventListener(MouseEvent.MOUSE_OUT,this.outHandler);
         this.mc = null;
      }
   }
}

