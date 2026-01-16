package com.robot.app.equipStrengthen
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.utils.TextFormatUtil;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   
   public class EquipStrengthenController
   {
      
      public static var _allIdA:Array;
      
      public static var _listA:Array;
      
      private static var _choicePanel:AppModel;
      
      private static var _curInfo:EquipStrengthenInfo;
      
      private static var _updataPanel:AppModel;
      
      private static const _maxLev:uint = 3;
      
      public function EquipStrengthenController()
      {
         super();
      }
      
      public static function start() : void
      {
         if(Boolean(_updataPanel))
         {
            _updataPanel.hide();
         }
         _allIdA = EquipXmlConfig.getAllEquipId();
         _listA = new Array();
         ItemManager.addEventListener(ItemEvent.CLOTH_LIST,onList);
         ItemManager.getCloth();
      }
      
      private static function onList(param1:ItemEvent) : void
      {
         var _loc2_:SingleItemInfo = null;
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,onList);
         var _loc3_:int = 0;
         while(_loc3_ < _allIdA.length)
         {
            _loc2_ = ItemManager.getClothInfo(_allIdA[_loc3_]);
            if(Boolean(_loc2_))
            {
               if(_loc2_.itemLevel < _maxLev && _loc2_.itemLevel > 0)
               {
                  _listA.push(_loc2_);
               }
            }
            _loc3_++;
         }
         if(_listA.length > 0)
         {
            showChloicePanel(_listA);
         }
         else
         {
            Alarm.show("你没有可以升级的装备哦！");
         }
      }
      
      private static function showChloicePanel(param1:Array) : void
      {
         if(!_choicePanel)
         {
            _choicePanel = new AppModel(ClientConfig.getAppModule("EquipStrengthenChoicePanel"),"正在打开");
            _choicePanel.setup();
         }
         _choicePanel.init(param1);
         _choicePanel.show();
      }
      
      public static function destory() : void
      {
         ItemManager.removeEventListener(ItemEvent.CLOTH_LIST,onList);
         if(Boolean(_choicePanel))
         {
            _choicePanel.destroy();
            _choicePanel = null;
         }
         if(Boolean(_updataPanel))
         {
            _updataPanel.destroy();
            _updataPanel = null;
         }
         SocketConnection.removeCmdListener(CommandID.EQUIP_UPDATA,onUpDataHandler);
      }
      
      public static function makeInfo(param1:SingleItemInfo) : void
      {
         _choicePanel.hide();
         EquipXmlConfig.getInfo(param1.itemID,param1.itemLevel + 1,showUpdataPanel);
      }
      
      public static function showUpdataPanel(param1:EquipStrengthenInfo) : void
      {
         if(!_updataPanel)
         {
            _updataPanel = new AppModel(ClientConfig.getAppModule("EquipStrengthenPanel"),"正在打开");
            _updataPanel.setup();
         }
         _curInfo = param1;
         _updataPanel.init(param1);
         _updataPanel.show();
      }
      
      public static function startUpdat(param1:uint) : void
      {
         SocketConnection.addCmdListener(CommandID.EQUIP_UPDATA,onUpDataHandler);
         SocketConnection.send(CommandID.EQUIP_UPDATA,param1);
      }
      
      private static function onUpDataHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.EQUIP_UPDATA,onUpDataHandler);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         if(_loc3_ != 1)
         {
            Alarm.show("升级失败！");
            return;
         }
         Alarm.show("恭喜你!" + TextFormatUtil.getRedTxt(ItemXMLInfo.getName(_curInfo.itemId)) + "强化成功了！");
      }
   }
}

