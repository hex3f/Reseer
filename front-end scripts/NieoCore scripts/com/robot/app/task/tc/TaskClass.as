package com.robot.app.task.tc
{
   import com.robot.app.task.control.TasksController;
   import com.robot.app.tasksRecord.TasksRecordConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.controller.GetPetController;
   import com.robot.core.info.task.novice.NoviceFinishInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.ItemInBagAlert;
   import com.robot.core.utils.TextFormatUtil;
   
   public class TaskClass
   {
      
      private var _noshow:Array;
      
      private var _arrayItem:Array;
      
      private var _info:NoviceFinishInfo;
      
      public function TaskClass(param1:NoviceFinishInfo)
      {
         var _loc2_:Object = null;
         this._noshow = [85,86,87,88];
         this._arrayItem = [];
         super();
         this._info = param1;
         if(this._noshow.indexOf(param1.taskID) != -1)
         {
            if(Boolean(this._info.petID) && Boolean(this._info.captureTm))
            {
               PetManager.setIn(this._info.captureTm,1);
            }
            return;
         }
         if(Boolean(this._info))
         {
            for each(_loc2_ in this._info.monBallList)
            {
               if(Boolean(_loc2_))
               {
                  this._arrayItem.push([_loc2_["itemID"],_loc2_["itemCnt"]]);
               }
            }
            this.loop();
         }
      }
      
      private function loop() : void
      {
         this.getItem(this._arrayItem);
      }
      
      private function getItem(param1:Array) : void
      {
         var item:Array = null;
         var id:uint = 0;
         var count:uint = 0;
         var str:String = null;
         var array:Array = param1;
         if(array.length == 0)
         {
            if(Boolean(this._info.petID) && Boolean(this._info.captureTm))
            {
               GetPetController.getPet(this._info.petID,this._info.captureTm,function():void
               {
                  if(TasksRecordConfig.getAllTasksId().indexOf(_info.taskID) != -1)
                  {
                     TasksController.taskCompleteUI();
                  }
               });
            }
            else if(TasksRecordConfig.getAllTasksId().indexOf(this._info.taskID) != -1)
            {
               TasksController.taskCompleteUI();
            }
         }
         else
         {
            item = array.shift();
            id = uint(item[0]);
            count = uint(item[1]);
            if(id == 1)
            {
               MainManager.actorInfo.coins += count;
               Alarm.show("你获得了" + TextFormatUtil.getRedTxt(count.toString()) + "赛尔豆！",this.loop);
            }
            else if(id == 3)
            {
               Alarm.show("你获得了" + TextFormatUtil.getRedTxt(count.toString()) + "点积累经验！",this.loop);
            }
            else
            {
               str = "";
               if(id >= 500001 && id <= 600000)
               {
                  str = count + "个<font color=\'#FF0000\'>" + ItemXMLInfo.getName(id) + "</font>已经放入了你的基地仓库！";
               }
               else if(id >= 600001 && id <= 700000)
               {
                  str = count + "个<font color=\'#FF0000\'>" + ItemXMLInfo.getName(id) + "</font>已经放入了你的投掷道具栏！";
               }
               else
               {
                  str = count + "个<font color=\'#FF0000\'>" + ItemXMLInfo.getName(id) + "</font>已经放入了你的储存箱！";
               }
               ItemInBagAlert.show(id,str,this.loop);
            }
         }
      }
   }
}

