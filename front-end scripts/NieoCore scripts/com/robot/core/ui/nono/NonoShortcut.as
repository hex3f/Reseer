package com.robot.core.ui.nono
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.MapXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.ModuleManager;
   import com.robot.core.manager.NonoManager;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alert;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.effect.ColorFilter;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class NonoShortcut
   {
      
      private static var _mainUI:Sprite;
      
      private static var _bgmc:Sprite;
      
      private static var _cureBtn:SimpleButton;
      
      private static var _fhBtn:SimpleButton;
      
      private static var _jnBtn:SimpleButton;
      
      private static var _powerBtn:SimpleButton;
      
      private static var _petStorageBtn:SimpleButton;
      
      private static var _petDiscoverBtn:SimpleButton;
      
      private static var _appModel:AppModel;
      
      private static var _nonoPanel:AppModel;
      
      private static var _nonoInfoPanel:AppModel;
      
      private static var _info:NonoInfo;
      
      private static var _flag:Boolean;
      
      private static var _canShowA:Array;
      
      private static var _tipA:Array;
      
      private static var _handlerFunA:Array;
      
      private static var _itemA:Array;
      
      private static var _petStorage:AppModel;
      
      private static const _length:uint = 8;
      
      private static var _newShowA:Array = ["700011","700015","700017"];
      
      private static var _newTipA:Array = ["精灵仓库","精灵追踪","飞行模式"];
      
      public function NonoShortcut()
      {
         super();
      }
      
      private static function makeAry() : void
      {
         if(MainManager.actorInfo.actionType == 0)
         {
            _newTipA[2] = "飞行模式";
         }
         else
         {
            _newTipA[2] = "飞行模式";
         }
         _canShowA = ["1","2","3","4"];
         _tipA = ["精灵治疗","跟随主人","经验分配","给NoNo充电"];
         _handlerFunA = [onCure,onFollow,onjn,onPower,hide,hide];
         if(_flag == false)
         {
            _canShowA[1] = "2";
            _tipA[1] = "跟随主人";
            if(!MainManager.actorInfo.superNono)
            {
               _canShowA[3] = "4";
               _tipA[3] = "给NoNo充电";
            }
            else
            {
               _canShowA[3] = null;
               _tipA[3] = null;
            }
         }
         else
         {
            _canShowA[1] = "2_1";
            _tipA[1] = "回家休息";
            _canShowA[3] = null;
            _tipA[3] = null;
         }
         var _loc1_:int = 0;
         while(_loc1_ < _newShowA.length)
         {
            if(Boolean(_info.func[uint(_newShowA[_loc1_]) - 700001]))
            {
               if(ItemXMLInfo.getVipOnly(uint(_newShowA[_loc1_])))
               {
                  if(MainManager.actorInfo.superNono)
                  {
                     _canShowA.push(_newShowA[_loc1_]);
                     _tipA.push(_newTipA[_loc1_]);
                  }
               }
               else if(MainManager.actorInfo.superNono)
               {
                  _canShowA.push(_newShowA[_loc1_]);
                  _tipA.push(_newTipA[_loc1_]);
               }
               else if(NonoManager.info.ai >= ItemXMLInfo.getAiLevel(uint(_newShowA[_loc1_])))
               {
                  _canShowA.push(_newShowA[_loc1_]);
                  _tipA.push(_newTipA[_loc1_]);
               }
            }
            _loc1_++;
         }
      }
      
      private static function addKeyBg() : void
      {
         var _loc1_:NonoShortcutKeyItem = null;
         if(!_itemA)
         {
            _itemA = new Array();
         }
         var _loc2_:int = 1;
         while(_loc2_ <= _length)
         {
            _loc1_ = new NonoShortcutKeyItem();
            _mainUI["key" + _loc2_].addChild(_loc1_);
            _itemA.push(_loc1_);
            _loc2_++;
         }
      }
      
      private static function clearKeyBg() : void
      {
         var _loc1_:int = 1;
         while(_loc1_ <= _length)
         {
            (_itemA[_loc1_ - 1] as NonoShortcutKeyItem).destroy();
            _loc1_++;
         }
      }
      
      private static function setData() : void
      {
         var _loc1_:NonoShortcutKeyItem = null;
         var _loc2_:int = 1;
         while(_loc2_ <= _length)
         {
            _loc1_ = _itemA[_loc2_ - 1] as NonoShortcutKeyItem;
            if(_canShowA[_loc2_ - 1] != null)
            {
               if(_canShowA[_loc2_ - 1] != undefined)
               {
                  if(_handlerFunA[_loc2_ - 1] != undefined)
                  {
                     _loc1_.setInfo(_canShowA[_loc2_ - 1],_tipA[_loc2_ - 1],_handlerFunA[_loc2_ - 1]);
                  }
                  else
                  {
                     _loc1_.setInfo(_canShowA[_loc2_ - 1],_tipA[_loc2_ - 1]);
                  }
               }
            }
            _loc2_++;
         }
      }
      
      public static function show(param1:Point, param2:NonoInfo, param3:Boolean) : void
      {
         _info = param2;
         _flag = param3;
         makeAry();
         if(_mainUI == null)
         {
            _mainUI = TaskIconManager.getIcon("UI_NonoShortcut") as Sprite;
            addKeyBg();
         }
         clearKeyBg();
         _bgmc = _mainUI["bgmc"];
         _bgmc.buttonMode = true;
         _mainUI.x = param1.x;
         _mainUI.y = param1.y;
         LevelManager.appLevel.addChild(_mainUI);
         setData();
         _mainUI.addEventListener(MouseEvent.ROLL_OUT,onOut);
         if(MapXMLInfo.getIsLocal(MapManager.currentMap.id) == false)
         {
            _mainUI["key2"].filters = [];
            _mainUI["key2"].mouseEnabled = true;
            _mainUI["key2"].mouseChildren = true;
         }
         else
         {
            _mainUI["key2"].filters = [ColorFilter.setGrayscale()];
            _mainUI["key2"].mouseEnabled = false;
            _mainUI["key2"].mouseChildren = false;
         }
         _bgmc.addEventListener(MouseEvent.CLICK,onClick);
      }
      
      public static function hide() : void
      {
         if(Boolean(_mainUI))
         {
            clearKeyBg();
            _mainUI.removeEventListener(MouseEvent.ROLL_OUT,onOut);
            DisplayUtil.removeForParent(_mainUI);
            EventManager.dispatchEvent(new RobotEvent(RobotEvent.NONO_SHORTCUT_HIDE));
         }
      }
      
      private static function onOut(param1:MouseEvent) : void
      {
         hide();
      }
      
      private static function onCure() : void
      {
         if(_info.superNono)
         {
            PetManager.cureAll();
         }
         else
         {
            Alert.show("恢复体力需要花费50赛尔豆，你确定要为你的精灵们恢复体力吗？",function():void
            {
               PetManager.cureAll();
            });
         }
         hide();
      }
      
      private static function onFollow() : void
      {
         if(_flag)
         {
            SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,0);
         }
         else
         {
            SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,1);
         }
         hide();
      }
      
      private static function onPower() : void
      {
         if(_info.chargeTime == 0)
         {
            SocketConnection.send(CommandID.NONO_CHARGE,1);
         }
         else
         {
            SocketConnection.send(CommandID.NONO_CHARGE,0);
         }
         hide();
      }
      
      private static function onjn() : void
      {
         if(_appModel == null)
         {
            _appModel = ModuleManager.getModule(ClientConfig.getAppModule("ExpAdmPanel"),"正在打开经验分配器面板...");
            _appModel.setup();
            _appModel.sharedEvents.addEventListener(Event.CLOSE,onAppCloseHandler);
         }
         _appModel.show();
         hide();
      }
      
      private static function onAppCloseHandler(param1:Event) : void
      {
         _appModel.sharedEvents.removeEventListener(Event.CLOSE,onAppCloseHandler);
         _appModel.destroy();
         _appModel = null;
      }
      
      private static function onPetStorage() : void
      {
         if(_petStorage == null)
         {
            _petStorage = ModuleManager.getModule(ClientConfig.getAppModule("PetStorage"),"正在打开精灵仓库");
            _petStorage.setup();
         }
         _petStorage.show();
      }
      
      private static function onClick(param1:MouseEvent) : void
      {
         showNoNOPanel();
      }
      
      private static function showNoNOPanel() : void
      {
         if(_nonoPanel == null)
         {
            _nonoPanel = ModuleManager.getModule(ClientConfig.getAppModule("MachineDogPanel"),"正在打开NoNo面板...");
            _nonoPanel.setup();
            _nonoPanel.sharedEvents.addEventListener(Event.CLOSE,onNonoPanelClose);
         }
         _nonoPanel.init(_info);
         _nonoPanel.show();
      }
      
      public static function onNonoPanelClose(param1:Event) : void
      {
         if(Boolean(_nonoPanel))
         {
            _nonoPanel.sharedEvents.removeEventListener(Event.CLOSE,onNonoPanelClose);
            _nonoPanel.destroy();
         }
         _nonoPanel = null;
      }
      
      private static function onNonoInfoPanelClose(param1:Event) : void
      {
         _nonoInfoPanel.sharedEvents.removeEventListener(Event.CLOSE,onNonoInfoPanelClose);
         _nonoInfoPanel.destroy();
         _nonoInfoPanel = null;
      }
   }
}

