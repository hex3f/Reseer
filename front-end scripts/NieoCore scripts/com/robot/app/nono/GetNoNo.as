package com.robot.app.nono
{
   import com.robot.app.mapProcess.MapProcess_107;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ToolTipManager;
   
   public class GetNoNo
   {
      
      private static var _nonoMc:MovieClip;
      
      public function GetNoNo()
      {
         super();
      }
      
      public static function startGet(param1:MovieClip) : void
      {
         _nonoMc = param1;
         ToolTipManager.add(_nonoMc as MovieClip,"NoNo领取处");
         _nonoMc.addEventListener(MouseEvent.CLICK,onClickHandler);
      }
      
      private static function onClickHandler(param1:MouseEvent) : void
      {
         if(MainManager.actorInfo.hasNono)
         {
            NpcTipDialog.show("呀~你的基地里已经有一个NoNo咯，好好照顾它吧。",null,NpcTipDialog.NONO);
         }
         else
         {
            if(TasksManager.getTaskStatus(461) == TasksManager.COMPLETE)
            {
               NpcTipDialog.show("很可惜今天你没有抽到NoNo哦，不过不要气馁！明天再来试试看吧，我们还等着你来领取呢！",null,NpcTipDialog.NONO);
               return;
            }
            NpcTipDialog.showAnswer("亲爱的小赛尔，你好！我是肖恩老师的超能NoNo侠客，你可以在我这里领取属于自己的NoNo。现在，你要把它领回去吗？",onOkHandler,null,NpcTipDialog.NONO);
         }
      }
      
      private static function onOkHandler() : void
      {
         if(TasksManager.getTaskStatus(461) == TasksManager.UN_ACCEPT)
         {
            TasksManager.accept(461,function(param1:Boolean):void
            {
               if(param1)
               {
                  showPanel();
               }
            });
            return;
         }
         if(TasksManager.getTaskStatus(461) == TasksManager.ALR_ACCEPT)
         {
            showPanel();
         }
      }
      
      private static function showPanel() : void
      {
         SocketConnection.addCmdListener(CommandID.NONO_OPEN,onGetSucHandler);
         SocketConnection.send(CommandID.NONO_OPEN,1);
      }
      
      private static function onGetSucHandler(param1:SocketEvent) : void
      {
         var by:ByteArray = null;
         var _endNum:uint = 0;
         var e:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.NONO_OPEN,onGetSucHandler);
         TasksManager.setTaskStatus(461,TasksManager.COMPLETE);
         by = e.data as ByteArray;
         _endNum = by.readUnsignedInt();
         if(_endNum == 0)
         {
            NpcTipDialog.show("呀～你已经有一只NoNo咯，好好照顾它吧。",null,NpcTipDialog.NONO);
         }
         else
         {
            MainManager.actorInfo.hasNono = true;
            NpcTipDialog.show("恭喜，你已经获得了属于自己的NoNo，在基地中可以找到，要好好待它哟。",function():void
            {
               if(TasksManager.getTaskStatus(96) == TasksManager.ALR_ACCEPT)
               {
                  TasksManager.getProStatusList(96,function(param1:Array):void
                  {
                     var _loc2_:MapProcess_107 = null;
                     if(Boolean(param1[0]) && !param1[1])
                     {
                        _loc2_ = new MapProcess_107();
                        TasksManager.complete(96,1,null,true);
                        _loc2_.hereNono.visible = false;
                     }
                  });
               }
            },NpcTipDialog.NONO);
         }
      }
      
      public static function destroy() : void
      {
         SocketConnection.removeCmdListener(CommandID.NONO_OPEN,onGetSucHandler);
         ToolTipManager.remove(_nonoMc as SimpleButton);
         _nonoMc.removeEventListener(MouseEvent.CLICK,onClickHandler);
         _nonoMc = null;
      }
   }
}

