package com.robot.core.manager
{
   import com.robot.core.aticon.FlyAction;
   import com.robot.core.aticon.WalkAction;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.UserInfo;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.manager.bean.BeanManager;
   import com.robot.core.mode.ActorModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.IDataInput;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.TaomeeManager;
   
   public class MainManager
   {
      
      public static var isClothHalfDay:Boolean;
      
      public static var isRoomHalfDay:Boolean;
      
      public static var iFortressHalfDay:Boolean;
      
      public static var isHQHalfDay:Boolean;
      
      private static var _isMember:Boolean;
      
      private static var _actorInfo:UserInfo;
      
      private static var _actorModel:ActorModel;
      
      private static var _uiLoader:MCLoader;
      
      public static var actorID:uint;
      
      public static var serverID:uint;
      
      public static const DfSpeed:Number = 4.6;
      
      private static const UI_PATH:String = "resource/ui.swf";
      
      private static const ICON_PATH:String = "resource/taskIcon.swf";
      
      private static const AIMAT_PATH:String = "resource/aimat/aimatUI.swf";
      
      public static var CHANNEL:uint = 0;
      
      public static var _ExchangeInfoList:Array = [];
      
      public function MainManager()
      {
         super();
      }
      
      public static function get ExchangeInfoList() : Array
      {
         return _ExchangeInfoList;
      }
      
      public static function setup(param1:Object) : void
      {
         _actorInfo = new UserInfo();
         UserInfo.setForLoginInfo(_actorInfo,param1 as IDataInput);
         SocketConnection.mainSocket.userID = _actorInfo.userID;
         TaomeeManager.initFightSpeed();
         loaderUILib();
      }
      
      public static function creatActor() : void
      {
         _actorModel = new ActorModel(_actorInfo);
         if(_actorInfo.actionType == 1)
         {
            _actorModel.walk = new FlyAction(_actorModel);
         }
         else
         {
            _actorModel.walk = new WalkAction();
         }
         EventManager.dispatchEvent(new RobotEvent(RobotEvent.CREATED_ACTOR));
      }
      
      private static function loaderUILib() : void
      {
         _uiLoader = new MCLoader(UI_PATH,MainManager.getStage(),1,"正在加载星球");
         _uiLoader.setIsShowClose(false);
         _uiLoader.addEventListener(MCLoadEvent.SUCCESS,onLoadUI);
         _uiLoader.addEventListener(MCLoadEvent.ERROR,onFailLoadUI);
         _uiLoader.doLoad();
      }
      
      private static function onLoadUI(param1:MCLoadEvent) : void
      {
         var loader:MCLoader = null;
         var event:MCLoadEvent = param1;
         UIManager.setup(event.getLoader());
         loader = new MCLoader(ICON_PATH,MainManager.getStage(),1,"正在加载任务信息");
         loader.addEventListener(MCLoadEvent.SUCCESS,onLoadIcon);
         loader.addEventListener(MCLoadEvent.ERROR,function(param1:MCLoadEvent):void
         {
            throw new Error("ICON加载出错");
         });
         loader.doLoad();
      }
      
      private static function onLoadIcon(param1:MCLoadEvent) : void
      {
         var loader:MCLoader = null;
         var event:MCLoadEvent = param1;
         TaskIconManager.setup(event.getLoader());
         loader = new MCLoader(AIMAT_PATH,MainManager.getStage(),1,"正在加载任务信息");
         loader.addEventListener(MCLoadEvent.SUCCESS,onLoadAimat);
         loader.addEventListener(MCLoadEvent.ERROR,function(param1:MCLoadEvent):void
         {
            throw new Error("AIMAT加载出错");
         });
         loader.doLoad();
      }
      
      private static function onLoadAimat(param1:MCLoadEvent) : void
      {
         AimatUIManager.setup(param1.getLoader());
         initBean();
      }
      
      private static function initBean() : void
      {
         creatActor();
         EventManager.addEventListener(RobotEvent.BEAN_COMPLETE,onAllBeanComplete);
         BeanManager.start();
      }
      
      private static function onAllBeanComplete(param1:Event) : void
      {
         if(checkIsNovice())
         {
            if(!TasksManager.isComNoviceTask())
            {
               MapManager.changeLocalMap(515);
            }
            else
            {
               MapManager.changeMap(MainManager.actorInfo.mapID);
            }
         }
         else
         {
            MapManager.changeMap(MainManager.actorInfo.mapID);
         }
         NonoManager.getInfo();
         RelationManager.setup();
      }
      
      public static function checkIsNovice() : Boolean
      {
         var _loc1_:Number = MainManager.actorInfo.regTime * 1000;
         var _loc2_:Boolean = true;
         var _loc3_:Date = new Date(_loc1_);
         var _loc4_:String = _loc3_.getFullYear().toString();
         var _loc5_:String = (_loc3_.getMonth() + 1).toString();
         if(_loc5_.length == 1)
         {
            _loc5_ = "0" + _loc5_;
         }
         var _loc6_:String = _loc3_.getDate().toString();
         if(_loc6_.length == 1)
         {
            _loc6_ = "0" + _loc6_;
         }
         var _loc7_:String = _loc3_.getHours().toString();
         if(_loc7_.length == 1)
         {
            _loc7_ = "0" + _loc7_;
         }
         var _loc8_:String = _loc3_.getMinutes().toString();
         if(_loc8_.length == 1)
         {
            _loc8_ = "0" + _loc8_;
         }
         var _loc9_:Number = Number(_loc4_ + _loc5_ + _loc6_ + _loc7_ + _loc8_);
         if(_loc9_ < 201003112359)
         {
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      public static function get isMember() : Boolean
      {
         return _isMember;
      }
      
      public static function get actorInfo() : UserInfo
      {
         return _actorInfo;
      }
      
      public static function get actorClothStr() : String
      {
         var _loc1_:PeopleItemInfo = null;
         var _loc2_:Array = actorInfo.clothes;
         var _loc3_:Array = [];
         for each(_loc1_ in _loc2_)
         {
            _loc3_.push(_loc1_.id);
         }
         return _loc3_.sort().join(",");
      }
      
      public static function get actorModel() : ActorModel
      {
         return _actorModel;
      }
      
      public static function upDateForPeoleInfo(param1:UserInfo) : void
      {
         _actorInfo.sysTime = param1.sysTime;
         _actorInfo.userID = param1.userID;
         _actorInfo.nick = param1.nick;
         _actorInfo.color = param1.color;
         _actorInfo.texture = param1.texture;
         _actorInfo.vip = param1.vip;
         _actorInfo.action = param1.action;
         _actorInfo.direction = param1.direction;
         _actorInfo.spiritID = param1.spiritID;
         _actorInfo.fightFlag = param1.fightFlag;
         _actorInfo.teacherID = param1.teacherID;
         _actorInfo.studentID = param1.studentID;
         _actorInfo.nonoState = param1.nonoState.slice();
         _actorInfo.nonoColor = param1.nonoColor;
         _actorInfo.nonoNick = param1.nonoNick;
         _actorInfo.superNono = param1.superNono;
         _actorInfo.clothes = param1.clothes.slice();
         SystemTimerManager.setTime(_actorInfo.sysTime);
      }
      
      public static function getRoot() : Sprite
      {
         return LevelManager.root;
      }
      
      public static function getStage() : Stage
      {
         return LevelManager.stage;
      }
      
      public static function getStageWidth() : int
      {
         return TaomeeManager.stageWidth;
      }
      
      public static function getStageHeight() : int
      {
         return TaomeeManager.stageHeight;
      }
      
      public static function getStageCenterPoint() : Point
      {
         return new Point(TaomeeManager.stageWidth / 2,TaomeeManager.stageHeight / 2);
      }
      
      public static function getStageMousePoint() : Point
      {
         return new Point(getStage().mouseX,getStage().mouseY);
      }
      
      private static function onFailLoadUI(param1:MCLoadEvent) : void
      {
         throw new Error("UI/Icon资源加载错误");
      }
   }
}

