package com.robot.core.manager
{
   import com.robot.core.CommandID;
   import com.robot.core.aticon.FlyAction;
   import com.robot.core.aticon.PeculiarAction;
   import com.robot.core.aticon.WalkAction;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.NonoActionEvent;
   import com.robot.core.event.NonoEvent;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.EmptySkeletonStrategy;
   import com.robot.core.ui.alert.Alarm;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import org.taomee.events.SocketEvent;
   
   public class NonoManager
   {
      
      public static var info:NonoInfo;
      
      private static var _time:int;
      
      private static var instance:EventDispatcher;
      
      public static var isBeckon:Boolean = false;
      
      public function NonoManager()
      {
         super();
      }
      
      public static function getInfo(param1:Boolean = false) : void
      {
         if(param1)
         {
            SocketConnection.addCmdListener(CommandID.NONO_INFO,onSocketInfo);
            SocketConnection.send(CommandID.NONO_INFO,MainManager.actorID);
            return;
         }
         var _loc2_:int = getTimer() - _time;
         if(_time == 0 || _loc2_ > 200000)
         {
            SocketConnection.addCmdListener(CommandID.NONO_INFO,onSocketInfo);
            SocketConnection.send(CommandID.NONO_INFO,MainManager.actorID);
         }
         else
         {
            dispatchEvent(new NonoEvent(NonoEvent.GET_INFO,info));
         }
      }
      
      private static function onSocketInfo(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.NONO_INFO,onSocketInfo);
         _time = getTimer();
         info = new NonoInfo(param1.data as ByteArray);
         dispatchEvent(new NonoEvent(NonoEvent.GET_INFO,info));
      }
      
      public static function getInstance() : EventDispatcher
      {
         if(instance == null)
         {
            instance = new EventDispatcher();
         }
         return instance;
      }
      
      public static function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         getInstance().addEventListener(param1,param2,param3,param4,param5);
      }
      
      public static function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         getInstance().removeEventListener(param1,param2,param3);
      }
      
      public static function dispatchEvent(param1:Event) : void
      {
         if(hasEventListener(param1.type))
         {
            getInstance().dispatchEvent(param1);
         }
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
      
      public static function addActionListener(param1:uint, param2:Function) : void
      {
         getInstance().addEventListener(param1.toString(),param2,false,0,false);
      }
      
      public static function removeActionListener(param1:uint, param2:Function) : void
      {
         getInstance().removeEventListener(param1.toString(),param2,false);
      }
      
      public static function dispatchAction(param1:uint, param2:String, param3:Object) : void
      {
         getInstance().dispatchEvent(new NonoActionEvent(param1.toString(),param2,param3));
      }
      
      public static function hasActionListener(param1:uint) : Boolean
      {
         return getInstance().hasEventListener(param1.toString());
      }
      
      public static function nonoFlyAction(param1:uint = 0) : void
      {
         if(MainManager.actorModel.pet != null)
         {
            if(PetXMLInfo.isFlyPet(MainManager.actorModel.pet.info.petID) || PetXMLInfo.isRidePet(MainManager.actorModel.pet.info.petID))
            {
               Alarm.show("处于骑乘状态时，不能使用NONO飞行模式哦！");
               return;
            }
         }
         SocketConnection.addCmdListener(CommandID.ON_OR_OFF_FLYING,onFlyHandler);
         SocketConnection.send(CommandID.ON_OR_OFF_FLYING,param1);
      }
      
      private static function onFlyHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.ON_OR_OFF_FLYING,onFlyHandler);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         MainManager.actorInfo.actionType = _loc4_;
         MainManager.actorModel.hideNono();
         if(_loc4_ == 0)
         {
            MainManager.actorModel.walk = new WalkAction();
            MainManager.actorModel.clickMc.y = -50;
            new PeculiarAction().standUp(MainManager.actorModel.skeleton as EmptySkeletonStrategy);
         }
         else
         {
            MainManager.actorModel.walk = new FlyAction(MainManager.actorModel);
         }
         MainManager.actorModel.showNono(NonoManager.info,_loc4_);
         NonoManager.dispatchEvent(new NonoEvent(NonoEvent.FOLLOW,NonoManager.info));
      }
   }
}

