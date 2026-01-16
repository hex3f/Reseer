package com.robot.app.mapProcess
{
   import com.robot.app.task.control.TaskController_131;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.AppModel;
   import com.robot.core.mode.PetModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class MapProcess_100 extends BaseMapProcess
   {
      
      private var talkNpc:Boolean;
      
      private var _teamApp:AppModel;
      
      public function MapProcess_100()
      {
         super();
      }
      
      private function initTask131() : void
      {
         if(TasksManager.getTaskStatus(TaskController_131.TASK_ID) == TasksManager.ALR_ACCEPT)
         {
            TasksManager.getProStatusList(TaskController_131.TASK_ID,function(param1:Array):void
            {
               if(Boolean(param1[0]))
               {
                  talkNpc = false;
               }
               else
               {
                  talkNpc = true;
                  conLevel["guide_mc"].visible = true;
               }
            });
         }
      }
      
      override protected function init() : void
      {
         conLevel["guide_mc"].visible = false;
         ToolTipManager.add(conLevel["teamBtn"],"队长实用手册");
         conLevel["teamBtn"].addEventListener(MouseEvent.CLICK,this.onTeamBookHandler);
         conLevel["ai_mc"].addEventListener(MouseEvent.CLICK,this.onAiJieLaDeHandler);
         conLevel["donghua"].gotoAndStop(1);
         conLevel["donghua"].visible = false;
         this.initTask131();
      }
      
      private function onTeamBookHandler(param1:MouseEvent) : void
      {
         if(!this._teamApp)
         {
            this._teamApp = new AppModel(ClientConfig.getBookModule("GroupTeamBook"),"正在打开");
            this._teamApp.setup();
         }
         this._teamApp.show();
      }
      
      private function onAiJieLaDeHandler(param1:MouseEvent) : void
      {
         var _loc2_:* = 0;
         if(Boolean(MainManager.actorModel.pet))
         {
            _loc2_ = uint(MainManager.actorModel.pet.info.petID);
            if(_loc2_ == 398 || _loc2_ == 397 || _loc2_ == 432)
            {
               EventManager.addEventListener(RobotEvent.ERROR_103303,this.onError103303);
               SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onTakeCate);
               SocketConnection.send(CommandID.TALK_CATE,26);
            }
            else
            {
               Alarm.show("必须把杰拉德带在身边才能启动装置！");
            }
         }
      }
      
      private function onError103303(param1:RobotEvent) : void
      {
         NpcDialog.show(NPC.JUNTUAN,["今天的训练课程已经完毕，请明天再来！"],["知道了！"]);
      }
      
      private function onTakeCate(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onTakeCate);
         var _loc2_:PetModel = MainManager.actorModel.pet;
         conLevel["donghua"].visible = true;
         conLevel["donghua"].gotoAndPlay(1);
         conLevel["donghua"].addEventListener(Event.ENTER_FRAME,this.onDonghuaHandler);
         conLevel["ai_mc"].visible = false;
      }
      
      private function onDonghuaHandler(param1:Event) : void
      {
         var event:Event = param1;
         if(conLevel["donghua"].currentFrame == conLevel["donghua"].totalFrames)
         {
            conLevel["ai_mc"].visible = true;
            conLevel["donghua"].removeEventListener(Event.ENTER_FRAME,this.onDonghuaHandler);
            conLevel["donghua"].gotoAndStop(1);
            conLevel["donghua"].visible = false;
            Alarm.show("<font color=\'#ff0000\'>3000积累经验</font>已经存入你的经验分配器中。",function():void
            {
               NpcDialog.show(NPC.JUNTUAN,["火星港训练计划的特别程序已经输入完成，你的精灵能力已得到全面提升！"],["太棒了！"]);
            });
         }
      }
      
      public function onAIClick() : void
      {
         if(this.talkNpc)
         {
            conLevel["guide_mc"].visible = false;
            NpcDialog.show(NPC.LEGION,["你好，我是英佩恩堡垒的智能AI。为了辨识，我还给自己取了另一个名字叫“军团”，因为我是英佩恩堡垒上1183个AI系统的意识。"],["真是奇怪的名字！"],[function():void
            {
               NpcDialog.show(NPC.SEER,["贾斯汀站长叫我来这里接受一个关于编队训练项目，咦？那我现在应该做些什么呢？？#7"],["我是来接受下一步指示的！"],[function():void
               {
                  NpcDialog.show(NPC.LEGION,["这是整个堡垒的控制中心，你从这里就可以达到两侧的训练室。既然是贾斯汀准将让你来的，我想你应该去训练室里，到了那里我会给你下一步的指示。"],["明白！"],[function():void
                  {
                     TasksManager.complete(TaskController_131.TASK_ID,0);
                  }]);
               }]);
            }]);
         }
      }
      
      override public function destroy() : void
      {
         EventManager.removeEventListener(RobotEvent.ERROR_103303,this.onError103303);
         conLevel["donghua"].removeEventListener(Event.ENTER_FRAME,this.onDonghuaHandler);
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onTakeCate);
         this.talkNpc = false;
         ToolTipManager.remove(conLevel["teamBtn"]);
         conLevel["teamBtn"].removeEventListener(MouseEvent.CLICK,this.onTeamBookHandler);
         if(Boolean(this._teamApp))
         {
            this._teamApp.destroy();
            this._teamApp = null;
         }
         conLevel["ai_mc"].removeEventListener(MouseEvent.CLICK,this.onAiJieLaDeHandler);
      }
   }
}

