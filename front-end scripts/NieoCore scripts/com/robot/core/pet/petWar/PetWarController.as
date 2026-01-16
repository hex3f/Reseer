package com.robot.core.pet.petWar
{
   import com.robot.core.CommandID;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.info.fightInfo.PetWarInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   
   public class PetWarController
   {
      
      private static var _allPetA:Array = [];
      
      private static var _allPetMc:Array = [];
      
      public static var allPetIdA:Array = [];
      
      public static var myCapA:Array = [];
      
      public static var myPetInfoA:Array = [];
      
      public function PetWarController()
      {
         super();
      }
      
      public static function start(param1:Function = null) : void
      {
         if(PetManager.getBagMap().length < 3)
         {
            if(param1 != null)
            {
               param1();
            }
            Alarm.show("你需要带上3只以上的精灵才能参加精灵大乱斗哦。");
            return;
         }
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         EventManager.addEventListener(PetFightEvent.GET_FIGHT_INFO_SUCCESS,onGetInfoSuceessHandler);
         EventManager.addEventListener(PetFightEvent.ALARM_CLICK,onClickHandler);
         SocketConnection.send(CommandID.START_PET_WAR);
         SocketConnection.addCmdListener(CommandID.START_PET_WAR,onStartHandler);
         PetFightModel.mode = PetFightModel.PET_MELEE;
      }
      
      private static function onClickHandler(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.ALARM_CLICK,onClickHandler);
         PetFightModel.mode = PetFightModel.SINGLE_MODE;
      }
      
      private static function onExpHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.PET_WAR_EXP_NOTICE,onExpHandler);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         Alarm.show("祝贺你得到了 " + TextFormatUtil.getRedTxt(_loc3_.toString()) + " 点积累经验!");
      }
      
      public static function onStartHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.START_PET_WAR,onStartHandler);
      }
      
      public static function onGetInfoSuceessHandler(param1:PetFightEvent) : void
      {
         EventManager.removeEventListener(PetFightEvent.GET_FIGHT_INFO_SUCCESS,onGetInfoSuceessHandler);
         var _loc2_:PetWarInfo = param1.dataObj as PetWarInfo;
         allPetIdA = _loc2_.myPetA.concat(_loc2_.otherPetA);
      }
      
      public static function destroy() : void
      {
      }
      
      public static function set allPetA(param1:Array) : void
      {
         _allPetA = param1;
      }
      
      public static function get allPetA() : Array
      {
         return _allPetA;
      }
      
      public static function getPetInfo(param1:Number) : PetInfo
      {
         var _loc2_:PetInfo = null;
         for each(_loc2_ in _allPetA)
         {
            if(_loc2_.catchTime == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getMyPet(param1:uint) : PetInfo
      {
         if(param1 >= myPetInfoA.length)
         {
            return null;
         }
         return myPetInfoA[param1];
      }
   }
}

