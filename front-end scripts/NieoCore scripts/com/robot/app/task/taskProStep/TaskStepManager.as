package com.robot.app.task.taskProStep
{
   import com.robot.app.fightNote.*;
   import com.robot.app.task.control.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.app.tasksRecord.*;
   import com.robot.core.animate.*;
   import com.robot.core.config.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.*;
   import com.robot.core.mode.*;
   import flash.display.*;
   import flash.events.*;
   import flash.net.*;
   import org.taomee.ds.*;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.*;
   
   public class TaskStepManager
   {
      
      private static var panel:AppModel;
      
      public static var taskStepMap:HashMap = new HashMap();
      
      public static var stepMap:HashMap = new HashMap();
      
      public static var optionID:uint = 0;
      
      private static var taskList:Array = [];
      
      private static var PATH:String = "resource/task/xml/task_";
      
      private static var taskCnt:uint = 0;
      
      private static var taskMapList:Array = [];
      
      private static var count:uint = 0;
      
      private static var isNowAccept:Boolean = false;
      
      public function TaskStepManager()
      {
         super();
      }
      
      public static function setup() : void
      {
         var _loc1_:uint = 0;
         var _loc2_:uint = 0;
         var _loc3_:Array = [];
         for each(_loc1_ in TasksRecordConfig.getAllTasksId())
         {
            if(!TasksRecordConfig.getTaskOffLineForId(_loc1_))
            {
               _loc3_.push(_loc1_);
            }
         }
         for each(_loc2_ in _loc3_)
         {
            if(TasksManager.getTaskStatus(_loc2_) == TasksManager.ALR_ACCEPT)
            {
               loadTaskStepXml(_loc2_);
               taskList.push(_loc2_);
            }
         }
      }
      
      public static function addTaskStepMap(param1:uint, param2:XML) : void
      {
         taskStepMap.add(param1,param2);
      }
      
      public static function removeTaskStepMap(param1:uint) : void
      {
         taskStepMap.remove(param1);
      }
      
      public static function loadTaskStepXml(param1:uint, param2:Boolean = false) : void
      {
         var _loc3_:String = PATH + param1 + ".xml";
         var _loc4_:URLRequest = new URLRequest(_loc3_);
         var _loc5_:URLLoader = new URLLoader();
         _loc5_.addEventListener(Event.COMPLETE,onLoadedXML(param1));
         _loc5_.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
         _loc5_.load(_loc4_);
         isNowAccept = param2;
      }
      
      private static function onLoadedXML(param1:uint) : Function
      {
         var taskID:uint = param1;
         var func:Function = function(param1:Event):void
         {
            var _loc2_:URLLoader = param1.currentTarget as URLLoader;
            var _loc3_:XML = XML(_loc2_.data);
            if(!taskStepMap.containsKey(taskID))
            {
               taskStepMap.add(taskID,_loc3_);
            }
            ++taskCnt;
            if(isNowAccept)
            {
               setupTask();
            }
            else if(taskCnt == taskList.length)
            {
               setupTask();
               taskCnt = 0;
            }
         };
         return func;
      }
      
      private static function onIOError(param1:IOErrorEvent) : void
      {
         throw new Error(param1.text);
      }
      
      private static function setupTask() : void
      {
         var tasksArr:Array = null;
         var index:uint = 0;
         tasksArr = null;
         index = 0;
         var addTaskStepInfo:Function = function(param1:uint):void
         {
            var id:uint = param1;
            TasksManager.getProStatusList(id,function(param1:Array):void
            {
               var _loc2_:uint = 0;
               var _loc3_:uint = 0;
               var _loc4_:XML = null;
               var _loc5_:TaskStepInfo = null;
               while(_loc2_ < param1.length)
               {
                  if(param1[_loc2_] == false)
                  {
                     TaskStepXMLInfo.setup(taskStepMap.getValue(id));
                     _loc3_ = TaskStepXMLInfo.getProMapID(_loc2_);
                     _loc4_ = TaskStepXMLInfo.getStepXML(_loc2_,0);
                     _loc5_ = new TaskStepInfo(id,_loc2_,_loc3_,_loc4_);
                     if(!stepMap.containsKey(id))
                     {
                        stepMap.add(id,_loc5_);
                     }
                     ++count;
                     if(count == taskList.length)
                     {
                        MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onChangeMap);
                        count = 0;
                     }
                     ++index;
                     if(index == tasksArr.length)
                     {
                        return;
                     }
                     addTaskStepInfo(tasksArr[index]);
                     if(_loc3_ == 0 || _loc4_ == null)
                     {
                     }
                     return;
                  }
                  _loc2_++;
               }
            });
         };
         tasksArr = taskStepMap.getKeys();
         index = 0;
         if(taskStepMap.length > 0)
         {
            addTaskStepInfo(tasksArr[index]);
         }
      }
      
      private static function onChangeMap(param1:MapEvent) : void
      {
         var _loc2_:TaskStepInfo = null;
         var _loc3_:uint = uint(param1.mapModel.id);
         for each(_loc2_ in stepMap.getValues())
         {
            if(_loc3_ == _loc2_.mapID)
            {
               startDoTask(_loc2_);
            }
         }
      }
      
      public static function doTaskProStep(param1:uint, param2:uint, param3:uint) : void
      {
         TaskStepXMLInfo.setup(taskStepMap.getValue(param1));
         var _loc4_:uint = TaskStepXMLInfo.getProMapID(param2);
         var _loc5_:XML = TaskStepXMLInfo.getStepXML(param2,param3);
         var _loc6_:TaskStepInfo = new TaskStepInfo(param1,param2,_loc4_,_loc5_);
         startDoTask(_loc6_);
      }
      
      private static function startDoTask(param1:TaskStepInfo) : void
      {
         TaskStepXMLInfo.setup(taskStepMap.getValue(param1.taskID));
         var _loc2_:XML = TaskStepXMLInfo.getStepXML(param1.pro,param1.stepID);
         switch(param1.stepType)
         {
            case 0:
               chooseOptions(param1);
               return;
            case 1:
               talkWithNpc(param1);
               return;
            case 2:
               playSceenMovie(param1);
               return;
            case 3:
               playFullMovie(param1);
               return;
            case 4:
               game(param1);
               return;
            case 5:
               fight(param1);
               return;
            case 6:
               showPanel(param1);
               return;
            case 7:
               mcAction(param1);
         }
      }
      
      private static function chooseOptions(param1:TaskStepInfo) : void
      {
         TaskStepXMLInfo.setup(taskStepMap.getValue(param1.taskID));
         var _loc2_:uint = TaskStepXMLInfo.getStepOptionCnt(param1.pro,param1.stepID);
         var _loc3_:Array = TaskStepXMLInfo.getStepOptionGoto(param1.pro,param1.stepID,optionID);
         var _loc4_:String = TaskStepXMLInfo.getStepOptionDes(param1.pro,param1.stepID,optionID);
         var _loc5_:uint = uint(_loc3_[0]);
         var _loc6_:uint = uint(_loc3_[1]);
         var _loc7_:XML = TaskStepXMLInfo.getStepXML(_loc5_,_loc6_);
         var _loc8_:uint = TaskStepXMLInfo.getProMapID(_loc5_);
         var _loc9_:TaskStepInfo = new TaskStepInfo(param1.taskID,_loc5_,_loc8_,_loc7_);
         startDoTask(_loc9_);
      }
      
      private static function talkWithNpc(param1:TaskStepInfo) : void
      {
         var talkMcName:String = null;
         var talkMc:MovieClip = null;
         var npcName:String = null;
         var array:Array = null;
         var func:String = null;
         var info:TaskStepInfo = param1;
         npcName = null;
         array = null;
         func = null;
         var showStep:Function = function():void
         {
            var reg:RegExp = null;
            var str:String = null;
            var npcStr:String = null;
            var tempstr:String = null;
            if(array.length > 1)
            {
               reg = /&[a-zA-Z][a-zA-Z0-9_]*&/;
               str = array.shift().toString();
               if(str.search(reg) != -1)
               {
                  npcStr = str.match(reg)[0].toString();
                  tempstr = str.replace(reg,"");
                  NpcTipDialog.show(tempstr,function():void
                  {
                     showStep();
                  },npcStr.substring(1,npcStr.length - 1));
               }
               else
               {
                  NpcTipDialog.show(str,function():void
                  {
                     showStep();
                  },npcName);
               }
            }
            else
            {
               NpcTipDialog.show(array.shift().toString(),function():void
               {
                  checkStep(info,func);
               },npcName);
            }
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         npcName = TaskStepXMLInfo.getStepTalkNpc(info.pro,info.stepID);
         talkMcName = TaskStepXMLInfo.getStepTalkMC(info.pro,info.stepID);
         talkMc = MapManager.currentMap.depthLevel.getChildByName(talkMcName) as MovieClip;
         array = TaskStepXMLInfo.getStepTalkDes(info.pro,info.stepID).split("$$");
         func = TaskStepXMLInfo.getStepTalkFunc(info.pro,info.stepID);
         if(Boolean(talkMc))
         {
            talkMc.buttonMode = true;
            talkMc.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               showStep();
            });
         }
         else
         {
            showStep();
         }
      }
      
      private static function playSceenMovie(param1:TaskStepInfo) : void
      {
         var sparkMC:MovieClip = null;
         var sceneMC:MovieClip = null;
         var frame:uint = 0;
         var childMcName:String = null;
         var func:String = null;
         var info:TaskStepInfo = param1;
         sparkMC = null;
         sceneMC = null;
         frame = 0;
         childMcName = null;
         func = null;
         var next:Function = function():void
         {
            checkStep(info,func);
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         sparkMC = MapManager.currentMap.controlLevel.getChildByName(TaskStepXMLInfo.getStepSmSparkMC(info.pro,info.stepID)) as MovieClip;
         sceneMC = MapManager.currentMap.animatorLevel.getChildByName(TaskStepXMLInfo.getStepSmPlaySceenMC(info.pro,info.stepID)) as MovieClip;
         frame = TaskStepXMLInfo.getStepSmPlayMcFrame(info.pro,info.stepID);
         childMcName = TaskStepXMLInfo.getStepSmPlayMcChild(info.pro,info.stepID);
         func = TaskStepXMLInfo.getStepSmFunc(info.pro,info.stepID);
         if(Boolean(sparkMC))
         {
            sparkMC.buttonMode = true;
            sparkMC.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               var evt:MouseEvent = param1;
               sparkMC.buttonMode = false;
               sparkMC.removeEventListener(MouseEvent.CLICK,arguments.callee);
               if(sceneMC != null && frame != 0)
               {
                  AnimateManager.playMcAnimate(sceneMC,frame,childMcName,function():void
                  {
                     next();
                  });
               }
            });
         }
         else if(sceneMC != null && frame != 0)
         {
            if(childMcName != "" && childMcName != null)
            {
               AnimateManager.playMcAnimate(sceneMC,frame,childMcName,function():void
               {
                  next();
               });
            }
            else
            {
               sceneMC.gotoAndStop(frame);
               next();
            }
         }
      }
      
      private static function playFullMovie(param1:TaskStepInfo) : void
      {
         var sparkMC:MovieClip = null;
         var swfUrl:String = null;
         var func:String = null;
         var info:TaskStepInfo = param1;
         swfUrl = null;
         func = null;
         var playMC:Function = function():void
         {
            AnimateManager.playFullScreenAnimate(swfUrl,function():void
            {
               checkStep(info,func);
            });
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         sparkMC = MapManager.currentMap.controlLevel.getChildByName(TaskStepXMLInfo.getStepSmSparkMC(info.pro,info.stepID)) as MovieClip;
         swfUrl = TaskStepXMLInfo.getStepFullMovieUrl(info.pro,info.stepID);
         func = TaskStepXMLInfo.getStepFmFunc(info.pro,info.stepID);
         if(Boolean(sparkMC))
         {
            sparkMC.buttonMode = true;
            sparkMC.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               playMC();
            });
         }
         else
         {
            playMC();
         }
      }
      
      private static function game(param1:TaskStepInfo) : void
      {
         var sparkMC:MovieClip = null;
         var gameUrl:String = null;
         var gamePassFunc:String = null;
         var gameLossFunc:String = null;
         var info:TaskStepInfo = param1;
         sparkMC = null;
         gameUrl = null;
         gamePassFunc = null;
         gameLossFunc = null;
         var playGame:Function = function():void
         {
            GamePlatformManager.join(gameUrl,false);
            GamePlatformManager.addEventListener(GamePlatformEvent.GAME_WIN,function(param1:GamePlatformEvent):void
            {
               var _local_4:* = undefined;
               var evt:GamePlatformEvent = param1;
               GamePlatformManager.removeEventListener(GamePlatformEvent.GAME_WIN,arguments.callee);
               try
               {
                  _local_4 = MapProcessConfig.currentProcessInstance;
                  _local_4[gamePassFunc]();
               }
               catch(e:Error)
               {
                  throw new Error("找不到函数!");
               }
            });
            GamePlatformManager.addEventListener(GamePlatformEvent.GAME_LOST,function(param1:GamePlatformEvent):void
            {
               var _local_4:* = undefined;
               var evt:GamePlatformEvent = param1;
               GamePlatformManager.removeEventListener(GamePlatformEvent.GAME_LOST,arguments.callee);
               try
               {
                  _local_4 = MapProcessConfig.currentProcessInstance;
                  _local_4[gameLossFunc]();
               }
               catch(e:Error)
               {
                  throw new Error("找不到函数!");
               }
            });
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         sparkMC = MapManager.currentMap.controlLevel.getChildByName(TaskStepXMLInfo.getStepGmSparkMC(info.pro,info.stepID)) as MovieClip;
         gameUrl = TaskStepXMLInfo.getStepGameUrl(info.pro,info.stepID);
         gamePassFunc = TaskStepXMLInfo.getStepGamePassFunc(info.pro,info.stepID);
         gameLossFunc = TaskStepXMLInfo.getStepGameLossFunc(info.pro,info.stepID);
         if(Boolean(sparkMC))
         {
            sparkMC.buttonMode = true;
            sparkMC.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               sparkMC.buttonMode = false;
               sparkMC.removeEventListener(MouseEvent.CLICK,arguments.callee);
               playGame();
            });
         }
         else
         {
            playGame();
         }
      }
      
      private static function fight(param1:TaskStepInfo) : void
      {
         var sparkMC:MovieClip = null;
         var bossName:String = null;
         var bossID:uint = 0;
         var fightSucsFunc:String = null;
         var fightLossFunc:String = null;
         var info:TaskStepInfo = param1;
         bossName = null;
         bossID = 0;
         fightSucsFunc = null;
         fightLossFunc = null;
         var fightBoss:Function = function():void
         {
            FightInviteManager.fightWithBoss(bossName,bossID);
            EventManager.addEventListener(PetFightEvent.FIGHT_RESULT,function(param1:PetFightEvent):void
            {
               var fightData:FightOverInfo = null;
               var _local_4:* = undefined;
               var evt:PetFightEvent = param1;
               EventManager.removeEventListener(PetFightEvent.FIGHT_CLOSE,arguments.callee);
               fightData = evt.dataObj["data"];
               if(fightData.winnerID == MainManager.actorInfo.userID)
               {
                  try
                  {
                     _local_4 = MapProcessConfig.currentProcessInstance;
                     _local_4[fightSucsFunc]();
                  }
                  catch(e:Error)
                  {
                     throw new Error("找不到函数!");
                  }
               }
               else
               {
                  try
                  {
                     _local_4 = MapProcessConfig.currentProcessInstance;
                     _local_4[fightLossFunc]();
                  }
                  catch(e:Error)
                  {
                     throw new Error("找不到函数!");
                  }
               }
            });
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         sparkMC = MapManager.currentMap.controlLevel.getChildByName(TaskStepXMLInfo.getStepFtSparkMC(info.pro,info.stepID)) as MovieClip;
         bossName = TaskStepXMLInfo.getStepFtBossName(info.pro,info.stepID);
         bossID = TaskStepXMLInfo.getStepFtBossID(info.pro,info.stepID);
         fightSucsFunc = TaskStepXMLInfo.getStepFtSuccessFunc(info.pro,info.stepID);
         fightLossFunc = TaskStepXMLInfo.getStepFtLossFunc(info.pro,info.stepID);
      }
      
      private static function showPanel(param1:TaskStepInfo) : void
      {
         var sparkMC:MovieClip = null;
         var className:String = null;
         var func:String = null;
         var info:TaskStepInfo = param1;
         sparkMC = null;
         className = null;
         func = null;
         var show:Function = function():void
         {
            var showComplete:Function = null;
            var showPause:Function = null;
            showComplete = null;
            showPause = null;
            showComplete = function(param1:DynamicEvent):void
            {
               EventManager.removeEventListener(TasksController.TASKPANEL_SHOW_COMPLETE,showComplete);
               checkStep(info,func);
            };
            showPause = function(param1:DynamicEvent):void
            {
               EventManager.removeEventListener(TasksController.TASKPANEL_SHOW_PAUSE,showPause);
               doTaskProStep(info.taskID,info.pro,info.stepID);
            };
            if(Boolean(panel))
            {
               panel.destroy();
               panel = null;
            }
            panel = new AppModel(ClientConfig.getTaskModule(className),"正在加载面板");
            panel.setup();
            panel.show();
            EventManager.removeEventListener(TasksController.TASKPANEL_SHOW_COMPLETE,showComplete);
            EventManager.removeEventListener(TasksController.TASKPANEL_SHOW_PAUSE,showPause);
            EventManager.addEventListener(TasksController.TASKPANEL_SHOW_COMPLETE,showComplete);
            EventManager.addEventListener(TasksController.TASKPANEL_SHOW_PAUSE,showPause);
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         sparkMC = MapManager.currentMap.controlLevel.getChildByName(TaskStepXMLInfo.getStepPanelSparkMC(info.pro,info.stepID)) as MovieClip;
         className = TaskStepXMLInfo.getStepPanelClass(info.pro,info.stepID);
         func = TaskStepXMLInfo.getStepPanelFunc(info.pro,info.stepID);
         if(Boolean(sparkMC))
         {
            sparkMC.buttonMode = true;
            sparkMC.addEventListener(MouseEvent.CLICK,function(param1:MouseEvent):void
            {
               sparkMC.buttonMode = false;
               sparkMC.removeEventListener(MouseEvent.CLICK,arguments.callee);
               show();
            });
         }
         else
         {
            show();
         }
      }
      
      private static function mcAction(param1:TaskStepInfo) : void
      {
         var _loc2_:MovieClip = null;
         TaskStepXMLInfo.setup(taskStepMap.getValue(param1.taskID));
         var _loc3_:uint = TaskStepXMLInfo.getStepMcType(param1.pro,param1.stepID);
         var _loc4_:String = TaskStepXMLInfo.getStepMcName(param1.pro,param1.stepID);
         var _loc5_:uint = TaskStepXMLInfo.getStepMcFrame(param1.pro,param1.stepID);
         var _loc6_:String = TaskStepXMLInfo.getStepMcFunc(param1.pro,param1.stepID);
         switch(_loc3_)
         {
            case 0:
               break;
            case 1:
               _loc2_ = MapManager.currentMap.animatorLevel.getChildByName(_loc4_) as MovieClip;
               break;
            case 2:
               _loc2_ = MapManager.currentMap.controlLevel.getChildByName(_loc4_) as MovieClip;
               break;
            case 3:
               _loc2_ = MapManager.currentMap.depthLevel.getChildByName(_loc4_) as MovieClip;
               break;
            case 4:
               _loc2_ = MapManager.currentMap.btnLevel.getChildByName(_loc4_) as MovieClip;
               break;
            case 5:
               _loc2_ = MapManager.currentMap.spaceLevel.getChildByName(_loc4_) as MovieClip;
               break;
            case 6:
               _loc2_ = MapManager.currentMap.topLevel.getChildByName(_loc4_) as MovieClip;
         }
         if(Boolean(_loc2_))
         {
            _loc2_.visible = TaskStepXMLInfo.getStepMcVisible(param1.pro,param1.stepID);
            if(_loc2_.visible)
            {
               _loc2_.gotoAndStop(_loc5_);
            }
         }
         checkStep(param1,_loc6_);
      }
      
      private static function checkStep(param1:TaskStepInfo, param2:String = "") : void
      {
         var isCompletePro:Boolean = false;
         var taskPanelClose:Function = null;
         var _local_4:* = undefined;
         var info:TaskStepInfo = param1;
         var func:String = param2;
         taskPanelClose = null;
         taskPanelClose = function(param1:Event):void
         {
            EventManager.removeEventListener(TasksController.TASKPANEL_CLOSE,taskPanelClose);
            nextStep(info);
         };
         TaskStepXMLInfo.setup(taskStepMap.getValue(info.taskID));
         isCompletePro = TaskStepXMLInfo.getStepIsComplete(info.pro,info.stepID);
         if(isCompletePro)
         {
            TasksManager.complete(info.taskID,info.pro,function(param1:Boolean):void
            {
               var _loc2_:uint = 0;
               var _loc3_:XML = null;
               var _loc4_:TaskStepInfo = null;
               if(param1)
               {
                  EventManager.removeEventListener(TasksController.TASKPANEL_CLOSE,taskPanelClose);
                  EventManager.addEventListener(TasksController.TASKPANEL_CLOSE,taskPanelClose);
                  _loc2_ = TaskStepXMLInfo.getProMapID(_loc4_.pro + 1);
                  _loc3_ = TaskStepXMLInfo.getStepXML(_loc4_.pro + 1,0);
                  _loc4_ = new TaskStepInfo(_loc4_.taskID,_loc4_.pro + 1,_loc2_,_loc3_);
                  stepMap.add(_loc4_.taskID,_loc4_);
               }
            },true);
         }
         else if(func != "" && func != null)
         {
            try
            {
               _local_4 = MapProcessConfig.currentProcessInstance;
               _local_4[func]();
            }
            catch(e:Error)
            {
               throw new Error("找不到函数!");
            }
         }
         else
         {
            nextStep(info);
         }
      }
      
      private static function nextStep(param1:TaskStepInfo) : void
      {
         var _loc2_:uint = 0;
         TaskStepXMLInfo.setup(taskStepMap.getValue(param1.taskID));
         var _loc3_:Boolean = TaskStepXMLInfo.getStepIsComplete(param1.pro,param1.stepID);
         var _loc4_:Array = TaskStepXMLInfo.getStepGoto(param1.pro,param1.stepID);
         var _loc5_:uint = uint(_loc4_[0]);
         var _loc6_:uint = uint(_loc4_[1]);
         var _loc7_:XML = TaskStepXMLInfo.getStepXML(_loc5_,_loc6_);
         var _loc8_:uint = TaskStepXMLInfo.getProMapID(_loc5_);
         var _loc9_:TaskStepInfo = new TaskStepInfo(param1.taskID,_loc5_,_loc8_,_loc7_);
         if(param1.pro == TaskStepXMLInfo.proCnt - 1 && _loc3_)
         {
            if(param1.pro == _loc5_ && param1.stepID == _loc6_)
            {
               stepMap.remove(param1.taskID);
               taskStepMap.remove(param1.taskID);
               _loc2_ = 0;
               while(_loc2_ < taskList.length)
               {
                  if(param1.taskID == taskList[_loc2_])
                  {
                     taskList.splice(_loc2_,1);
                  }
                  _loc2_++;
               }
            }
         }
         else
         {
            startDoTask(_loc9_);
         }
      }
   }
}

