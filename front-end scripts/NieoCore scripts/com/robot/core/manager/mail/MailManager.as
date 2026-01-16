package com.robot.core.manager.mail
{
   import com.robot.core.CommandID;
   import com.robot.core.cmd.MailCmdListener;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MailEvent;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.mail.MailListInfo;
   import com.robot.core.info.mail.SingleMailInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.TaskIconManager;
   import com.robot.core.mode.AppModel;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.loading.loadingstyle.ILoadingStyle;
   import com.robot.core.ui.loading.loadingstyle.MailLoadingStyle;
   import flash.display.InteractiveObject;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.utils.ByteArray;
   import org.taomee.component.control.MLabel;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.EventManager;
   import org.taomee.manager.ToolTipManager;
   
   public class MailManager
   {
      
      public static var total:uint;
      
      private static var unReadCount:uint;
      
      private static var unreadTxt:MLabel;
      
      private static var icon:InteractiveObject;
      
      private static var panel:AppModel;
      
      private static var loadingView:ILoadingStyle;
      
      private static var delArray:Array;
      
      private static var _instance:EventDispatcher;
      
      private static var _hashMap:HashMap = new HashMap();
      
      private static var sysMailMap:HashMap = new HashMap();
      
      public function MailManager()
      {
         super();
      }
      
      public static function setup() : void
      {
         EventManager.addEventListener(RobotEvent.BEAN_COMPLETE,onBeanComplete);
         addEventListener(MailEvent.MAIL_DELETE,onDelete);
         addEventListener(MailEvent.MAIL_CLEAR,onClear);
      }
      
      private static function onBeanComplete(param1:Event) : void
      {
         getUnRead();
      }
      
      public static function getNew() : void
      {
         getUnRead();
      }
      
      public static function showIcon() : void
      {
         icon = TaskIconManager.getIcon("mail_icon");
         icon.x = 112;
         icon.y = 24;
         LevelManager.iconLevel.addChild(icon);
         ToolTipManager.add(icon,"星际邮件");
         icon.addEventListener(MouseEvent.CLICK,showMail);
         unreadTxt = new MLabel();
         unreadTxt.mouseChildren = unreadTxt.mouseEnabled = false;
         unreadTxt.width = 50;
         unreadTxt.blod = true;
         unreadTxt.fontSize = 14;
         unreadTxt.text = "";
         unreadTxt.textColor = 13311;
         unreadTxt.filters = [new GlowFilter(16777215,1,2,2,20)];
         unreadTxt.x = icon.x + 6;
         unreadTxt.y = icon.height + icon.y - 18;
         LevelManager.iconLevel.addChild(unreadTxt);
      }
      
      private static function showMail(param1:MouseEvent) : void
      {
         if(!panel)
         {
            panel = new AppModel(ClientConfig.getAppModule("MailBox"),"正在打开邮箱");
            panel.loadingView = new MailLoadingStyle(LevelManager.appLevel);
            panel.setup();
         }
         panel.show();
      }
      
      public static function getUnRead() : void
      {
         SocketConnection.addCmdListener(CommandID.MAIL_GET_UNREAD,onGetUnRead);
         SocketConnection.send(CommandID.MAIL_GET_UNREAD);
      }
      
      private static function onGetUnRead(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.MAIL_GET_UNREAD,onGetUnRead);
         var _loc2_:ByteArray = param1.data as ByteArray;
         unReadCount = _loc2_.readUnsignedInt();
         if(unReadCount > 0)
         {
            unreadTxt.text = unReadCount.toString();
         }
         else
         {
            unreadTxt.text = "";
         }
      }
      
      public static function sendMail(param1:uint, param2:String, param3:Array) : void
      {
         var _loc4_:Number = 0;
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.writeUTFBytes(param2 + "0");
         if(_loc5_.length > 150)
         {
            Alarm.show("你输入的邮件内容过长");
            return;
         }
         if(param3.length > 10)
         {
            Alarm.show("最多只能同时给10个人发送邮件哦！");
            return;
         }
         var _loc6_:ByteArray = new ByteArray();
         for each(_loc4_ in param3)
         {
            _loc6_.writeUnsignedInt(_loc4_);
         }
         SocketConnection.send(CommandID.MAIL_SEND,param1,_loc5_.length,_loc5_,param3.length,_loc6_);
      }
      
      public static function getMailContent(param1:uint, param2:Function) : void
      {
         var id:uint = param1;
         var fun:Function = param2;
         SocketConnection.addCmdListener(CommandID.MAIL_GET_CONTENT,function(param1:SocketEvent):void
         {
            var _loc3_:SingleMailInfo = null;
            SocketConnection.removeCmdListener(CommandID.MAIL_GET_CONTENT,arguments.callee);
            var _loc4_:ByteArray = param1.data as ByteArray;
            var _loc5_:uint = _loc4_.readUnsignedInt();
            var _loc6_:uint = _loc4_.readUnsignedInt();
            var _loc7_:uint = _loc4_.readUnsignedInt();
            var _loc8_:uint = _loc4_.readUnsignedInt();
            var _loc9_:String = _loc4_.readUTFBytes(16);
            var _loc10_:Boolean = _loc4_.readUnsignedInt() == 1;
            var _loc11_:uint = _loc4_.readUnsignedInt();
            var _loc12_:String = _loc4_.readUTFBytes(_loc11_);
            if(_hashMap.containsKey(_loc5_))
            {
               _loc3_ = _hashMap.getValue(_loc5_);
            }
            else
            {
               _loc3_ = new SingleMailInfo();
               _hashMap.add(_loc5_,_loc3_);
            }
            _loc3_.template = _loc6_;
            _loc3_.time = _loc7_;
            _loc3_.fromID = _loc8_;
            _loc3_.fromNick = _loc9_;
            _loc3_.readed = _loc10_;
            _loc3_.content = _loc12_;
            if(fun != null)
            {
               fun(_loc3_);
            }
         });
         SocketConnection.send(CommandID.MAIL_GET_CONTENT,id);
      }
      
      public static function setReaded(param1:Array) : void
      {
         var _loc2_:Number = 0;
         if(param1.length == 0)
         {
            return;
         }
         var _loc3_:ByteArray = new ByteArray();
         for each(_loc2_ in param1)
         {
            _loc3_.writeUnsignedInt(_loc2_);
         }
         SocketConnection.send(CommandID.MAIL_SET_READED,param1.length,_loc3_);
      }
      
      public static function delMail(param1:Array) : void
      {
         var _loc2_:Number = 0;
         if(param1.length == 0)
         {
            return;
         }
         delArray = param1.slice();
         var _loc3_:ByteArray = new ByteArray();
         for each(_loc2_ in param1)
         {
            _loc3_.writeUnsignedInt(_loc2_);
         }
         SocketConnection.send(CommandID.MAIL_DELETE,param1.length,_loc3_);
      }
      
      public static function delAllMail() : void
      {
         SocketConnection.send(CommandID.MAIL_DEL_ALL);
      }
      
      public static function getMailList(param1:uint = 1) : void
      {
         SocketConnection.addCmdListener(CommandID.MAIL_GET_LIST,onMailList);
         SocketConnection.send(CommandID.MAIL_GET_LIST,param1);
      }
      
      private static function onMailList(param1:SocketEvent) : void
      {
         var _loc2_:SingleMailInfo = null;
         var _loc3_:MailListInfo = param1.data as MailListInfo;
         total = _loc3_.total;
         for each(_loc2_ in _loc3_.mailList)
         {
            _hashMap.add(_loc2_.id,_loc2_);
         }
         if(_loc3_.total > _hashMap.length)
         {
            getMailList(_hashMap.length + 1);
         }
         else
         {
            dispatchEvent(new MailEvent(MailEvent.MAIL_LIST));
         }
      }
      
      public static function getMailInfos() : Array
      {
         return _hashMap.getValues().sortOn("time",Array.NUMERIC | Array.DESCENDING);
      }
      
      public static function getMailIDs() : Array
      {
         return _hashMap.getKeys();
      }
      
      public static function getSingleMail(param1:uint) : SingleMailInfo
      {
         return _hashMap.getValue(param1);
      }
      
      private static function onDelete(param1:MailEvent) : void
      {
         var _loc2_:Number = 0;
         for each(_loc2_ in delArray)
         {
            _hashMap.remove(_loc2_);
         }
         dispatchEvent(new MailEvent(MailEvent.MAIL_LIST));
      }
      
      private static function onClear(param1:MailEvent) : void
      {
         _hashMap.clear();
         dispatchEvent(new MailEvent(MailEvent.MAIL_LIST));
      }
      
      public static function addSysMail(param1:uint) : void
      {
         sysMailMap.add(param1,param1);
      }
      
      public static function delSysMail() : void
      {
         MailCmdListener.isShowTip = false;
         var _loc1_:Array = sysMailMap.getKeys();
         delMail(_loc1_);
         sysMailMap.clear();
      }
      
      private static function getInstance() : EventDispatcher
      {
         if(_instance == null)
         {
            _instance = new EventDispatcher();
         }
         return _instance;
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
         getInstance().dispatchEvent(param1);
      }
      
      public static function hasEventListener(param1:String) : Boolean
      {
         return getInstance().hasEventListener(param1);
      }
   }
}

