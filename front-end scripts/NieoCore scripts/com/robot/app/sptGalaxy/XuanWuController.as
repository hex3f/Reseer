package com.robot.app.sptGalaxy
{
   import com.robot.app.mapProcess.MapProcess_401;
   import com.robot.core.*;
   import com.robot.core.animate.AnimateManager;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MapEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.*;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.TasksManager;
   import com.robot.core.net.*;
   import com.robot.core.npc.NPC;
   import com.robot.core.npc.NpcDialog;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   
   public class XuanWuController
   {
      
      private static var _door:MovieClip;
      
      private static var _mapIndex:int;
      
      private static var _spt:Array = [301,302,303,305,307,308];
      
      private static var _map:Array = [30,20,15,25,105,47,40,51,54];
      
      private static var _pos:Array = [[550,450],[650,450],[430,300],[450,150],[280,200],[460,410],[430,450],[490,440],[480,400],[490,190]];
      
      public function XuanWuController()
      {
         super();
      }
      
      public static function setup() : void
      {
         _mapIndex = int(Math.random() * _map.length);
         MapManager.addEventListener(MapEvent.MAP_SWITCH_COMPLETE,onMapOpenHandler);
      }
      
      private static function onMapOpenHandler(param1:MapEvent) : void
      {
         var _loc2_:MapEvent = param1;
         if(_loc2_.mapModel.id == _map[_mapIndex])
         {
            SocketConnection.addCmdListener(CommandID.SYSTEM_TIME,showdoor);
            SocketConnection.send(CommandID.SYSTEM_TIME);
         }
      }
      
      private static function showdoor(param1:SocketEvent) : void
      {
         var systemTime:SystemTimeInfo;
         var TimeData:Date;
         var _arg_1:SocketEvent = param1;
         SocketConnection.removeCmdListener(CommandID.SYSTEM_TIME,showdoor);
         systemTime = _arg_1.data as SystemTimeInfo;
         TimeData = systemTime.date;
         if(TimeData.getMinutes() >= 50)
         {
            ResourceManager.getResource(ClientConfig.getAppRes("GuardBeastPortal"),function(param1:DisplayObject):void
            {
               _door = param1 as MovieClip;
               _door.x = _pos[_mapIndex][0];
               _door.y = _pos[_mapIndex][1];
               _door.buttonMode = true;
               _door["mc"].gotoAndStop(1);
               _door.addEventListener(MouseEvent.CLICK,onDoorClick);
               ToolTipManager.add(_door,"玄武空间传送阵");
               MapManager.currentMap.controlLevel.addChild(_door);
            },"SptGalaxyDoor_UI");
         }
      }
      
      private static function onDoorClick(param1:MouseEvent) : void
      {
         MainManager.actorModel.walkAction(new Point(_door.x,_door.y));
         MainManager.actorModel.addEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
      }
      
      private static function onWalkEnterFrame(param1:RobotEvent) : void
      {
         if(Point.distance(MainManager.actorModel.pos,new Point(_door.x,_door.y)) < 20)
         {
            MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
            MainManager.actorModel.stop();
            check();
         }
      }
      
      public static function check(param1:Boolean = false) : void
      {
         var b:Boolean = param1;
         if(b || isReady())
         {
            NpcDialog.show(NPC.KONGJIANSHIZHE,["我是空间使者，玄武空间是帕诺星系最神秘的地方，你已具备了进入空间的实力，我现在可以让你传送过去。"],["我决定进去一探究竟。","我还是下次再来吧。"],[function():void
            {
               if(Boolean(_door))
               {
                  AnimateManager.playMcAnimate(_door,1,"mc",function():void
                  {
                     enter();
                  });
               }
               else
               {
                  enter();
               }
            }]);
         }
         else
         {
            NpcDialog.show(NPC.KONGJIANSHIZHE,["我是空间使者，玄武空间是帕诺星系最神秘的地方，你只有战胜了0xff0000蘑菇怪、钢牙鲨、里奥斯、提亚斯、纳多雷0xffffff和0xff0000雷纳多0xffffff，我才会让你进去。"],["我还是下次再来吧。"]);
         }
      }
      
      private static function enter() : void
      {
         MapProcess_401.xuanWuStatus = 0;
         MapManager.changeMap(401);
      }
      
      private static function isReady() : Boolean
      {
         var _loc1_:int = int(_spt.length);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_)
         {
            if(TasksManager.getTaskStatus(_spt[_loc2_]) != TasksManager.COMPLETE)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      private static function onMapDestroyHandler(param1:MapEvent) : void
      {
         if(_door != null)
         {
            _door.removeEventListener(MouseEvent.CLICK,onDoorClick);
            ToolTipManager.remove(_door);
            _door = null;
            MainManager.actorModel.removeEventListener(RobotEvent.WALK_ENTER_FRAME,onWalkEnterFrame);
         }
      }
   }
}

