package com.robot.app.taskPanel
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.TasksXMLInfo;
   import com.robot.core.event.NpcEvent;
   import com.robot.core.info.NpcTaskInfo;
   import com.robot.core.manager.*;
   import com.robot.core.mode.NpcModel;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcController;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.DisplayObject;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class TaskListPanel extends Sprite
   {
      
      private static const PATH:String = "com.robot.app.task.control";
      
      private var _info:NpcTaskInfo;
      
      private var npcType:String;
      
      private var bgMC:Sprite;
      
      private var closeBtn:SimpleButton;
      
      private var itemContainer:Sprite;
      
      private var npcIcon:Sprite;
      
      private var listArray:Array = [];
      
      private var npcModel:NpcModel;
      
      public function TaskListPanel()
      {
         super();
         this.bgMC = AssetsManager.getSprite("ui_TaskListPanel");
         addChild(this.bgMC);
         this.closeBtn = this.bgMC["closeBtn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.closeHandler);
         this.npcIcon = new Sprite();
         this.npcIcon.x = 37;
         this.npcIcon.y = 65;
         this.itemContainer = new Sprite();
         this.itemContainer.x = 170;
         this.itemContainer.y = 78;
         this.bgMC.addChild(this.itemContainer);
         this.bgMC.addChild(this.npcIcon);
      }
      
      public function show() : void
      {
         if(this._info.acceptList.length == 1)
         {
            return;
         }
         LevelManager.appLevel.addChild(this);
      }
      
      public function setInfo(param1:NpcModel) : void
      {
         var count:uint = 0;
         var item:TaskListItem = null;
         var model:NpcModel = param1;
         item = null;
         var i:uint = 0;
         var proStr:String = null;
         var arr:Array = null;
         this.npcModel = model;
         this._info = model.taskInfo;
         this.npcType = model.type;
         if(this._info.acceptList.length == 1)
         {
            item = new TaskListItem(this._info.acceptList[0]);
            if(Boolean(this._info.relateIDs.containsKey(item.id)) || item.id == 4)
            {
               this.npcModel.dispatchEvent(new NpcEvent(NpcEvent.NPC_CLICK,this.npcModel,item.id));
            }
            else if(item.status == TasksManager.ALR_ACCEPT)
            {
               proStr = TasksXMLInfo.getProDes(item.id);
               arr = this.getNpcDialogArr(proStr);
               NpcDialog.show(NpcController.curNpc.npc.id,arr[0],arr[1]);
            }
            else if(TasksXMLInfo.getIsCondition(item.id))
            {
               if(TaskConditionManager.getConditionStep(item.id) == TaskConditionManager.NPC_CLICK)
               {
                  if(TaskConditionManager.conditionTask(item.id,this.npcModel.type))
                  {
                     this.showTaskDes(item.id);
                  }
               }
               else
               {
                  this.showTaskDes(item.id);
               }
            }
            else
            {
               this.showTaskDes(item.id);
            }
            return;
         }
         this.clearOld();
         DisplayUtil.removeAllChild(this.itemContainer);
         DisplayUtil.removeAllChild(this.npcIcon);
         ResourceManager.getResource(ClientConfig.getNpcSwfPath(model.type),function(param1:DisplayObject):void
         {
            param1.scaleX = param1.scaleY = 0.6;
            npcIcon.addChild(param1);
         },"npc");
         this.bgMC["npcNameTxt"].text = model.name;
         count = 0;
         for each(i in this._info.acceptList)
         {
            item = new TaskListItem(i);
            item.buttonMode = true;
            item.y = (item.height + 5) * count;
            item.addEventListener(MouseEvent.CLICK,this.showTaskAlert);
            this.itemContainer.addChild(item);
            this.listArray.push(item);
            count++;
         }
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(this);
      }
      
      private function showTaskAlert(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:TaskListItem = param1.currentTarget as TaskListItem;
         this.hide();
         if(Boolean(this._info.relateIDs.containsKey(_loc4_.id)) || _loc4_.id == 4)
         {
            this.npcModel.dispatchEvent(new NpcEvent(NpcEvent.NPC_CLICK,this.npcModel,_loc4_.id));
         }
         else if(_loc4_.status == TasksManager.ALR_ACCEPT)
         {
            _loc2_ = TasksXMLInfo.getProDes(_loc4_.id);
            _loc3_ = this.getNpcDialogArr(_loc2_);
            NpcDialog.show(NpcController.curNpc.npc.id,_loc3_[0],_loc3_[1]);
         }
         else if(TasksXMLInfo.getIsCondition(_loc4_.id))
         {
            if(TaskConditionManager.getConditionStep(_loc4_.id) == TaskConditionManager.NPC_CLICK)
            {
               if(TaskConditionManager.conditionTask(_loc4_.id,this.npcModel.type))
               {
                  this.showTaskDes(_loc4_.id);
               }
            }
            else
            {
               this.showTaskDes(_loc4_.id);
            }
         }
         else
         {
            this.showTaskDes(_loc4_.id);
         }
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         this.hide();
      }
      
      private function clearOld() : void
      {
         var _loc1_:TaskListItem = null;
         for each(_loc1_ in this.listArray)
         {
            _loc1_.removeEventListener(MouseEvent.CLICK,this.showTaskAlert);
         }
         this.listArray = [];
      }
      
      private function showTaskDes(param1:uint) : void
      {
         var name:String = null;
         var array:Array = null;
         var id:uint = param1;
         array = null;
         var showStep:Function = function():void
         {
            var reg:RegExp = null;
            var str:String = null;
            var npcID:uint = 0;
            var arr:Array = null;
            var npcStr:String = null;
            var eArr:Array = null;
            if(array.length > 1)
            {
               reg = /&[0-9]*&/;
               str = array.shift().toString();
               npcID = uint(NPC.SHIPER);
               if(str.search(reg) != -1)
               {
                  npcStr = str.match(reg)[0];
                  npcID = uint(npcStr.substring(1,npcStr.length - 1));
                  str = str.replace(reg,"");
               }
               else
               {
                  npcID = uint(NpcController.curNpc.npc.id);
               }
               arr = getNpcDialogArr(str);
               NpcDialog.show(npcID,arr[0],arr[1],[function():void
               {
                  showStep();
               }]);
            }
            else
            {
               eArr = getNpcDialogArr(array.shift().toString());
               NpcDialog.show(NpcController.curNpc.npc.id,eArr[0],eArr[1],[function():void
               {
                  if(checkCondition(id))
                  {
                     TasksManager.accept(id,function(param1:Boolean):void
                     {
                        var _loc2_:* = undefined;
                        if(param1)
                        {
                           TasksManager.setTaskStatus(id,TasksManager.ALR_ACCEPT);
                           NpcController.refreshTaskInfo();
                           _loc2_ = getDefinitionByName(PATH + "::TaskController_" + id);
                           _loc2_.start();
                        }
                        else
                        {
                           Alarm.show("接受任务失败，请稍后再试！");
                        }
                     });
                  }
               }]);
            }
         };
         if(TasksXMLInfo.getEspecial(id))
         {
            NpcTaskManager.dispatchEvent(new Event(id.toString()));
            return;
         }
         name = TasksXMLInfo.getName(id);
         array = TasksXMLInfo.getTaskDes(id).split("$$");
         if(TasksXMLInfo.getTaskDes(id) == "")
         {
            this.npcModel.dispatchEvent(new NpcEvent(NpcEvent.TASK_WITHOUT_DES,this.npcModel,id));
            return;
         }
         showStep();
      }
      
      private function getNpcDialogArr(param1:String) : Array
      {
         var _loc2_:Array = param1.split("@");
         var _loc3_:Array = [];
         var _loc4_:Array = [];
         _loc3_.push(_loc2_[0]);
         _loc4_.push(_loc2_[1]);
         if(Boolean(_loc2_[2]))
         {
            _loc4_.push(_loc2_[2]);
         }
         return [_loc3_,_loc4_];
      }
      
      private function checkCondition(param1:uint) : Boolean
      {
         if(TasksXMLInfo.getIsCondition(param1))
         {
            if(TaskConditionManager.getConditionStep(param1) == TaskConditionManager.BEFOR_ACCEPT)
            {
               return TaskConditionManager.conditionTask(param1,this.npcModel.type);
            }
            return true;
         }
         return true;
      }
   }
}

