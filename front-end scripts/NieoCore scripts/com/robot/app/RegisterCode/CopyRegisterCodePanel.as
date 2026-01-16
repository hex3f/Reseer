package com.robot.app.RegisterCode
{
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.system.ApplicationDomain;
   import flash.system.System;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class CopyRegisterCodePanel
   {
      
      private static var mc:MovieClip;
      
      private static var app:ApplicationDomain;
      
      private static var closeBtn:SimpleButton;
      
      private static var copyBtn:SimpleButton;
      
      private static var exchangeBtn:SimpleButton;
      
      private static var PATH:String = "resource/module/RequestCode/registerCode.swf";
      
      public function CopyRegisterCodePanel()
      {
         super();
      }
      
      public static function loadPanel() : void
      {
         var _loc1_:MCLoader = null;
         if(!mc)
         {
            _loc1_ = new MCLoader(PATH,LevelManager.topLevel,1,"正在打开邀请码面板");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,onLoad);
            _loc1_.doLoad();
         }
         else
         {
            mc.gotoAndStop(1);
            show();
         }
      }
      
      private static function onLoad(param1:MCLoadEvent) : void
      {
         app = param1.getApplicationDomain();
         mc = new (app.getDefinition("codePanel") as Class)() as MovieClip;
         show();
      }
      
      private static function show() : void
      {
         var dragMc:SimpleButton = null;
         var codeTxt:TextField = null;
         DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mc);
         closeBtn = mc["exitBtn"];
         copyBtn = mc["copyBtn"];
         exchangeBtn = mc["exchangeBtn"];
         dragMc = mc["dragMC"];
         dragMc.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            mc.startDrag();
         });
         dragMc.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            mc.stopDrag();
         });
         codeTxt = mc["codeTxt"];
         codeTxt.text = GetRegisterCode.getRegCode.toString();
         exchangeBtn.addEventListener(MouseEvent.CLICK,getRequstAward);
         closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
         copyBtn.addEventListener(MouseEvent.CLICK,copyContent);
         SocketConnection.addCmdListener(CommandID.REQUEST_COUNT,onCount);
         SocketConnection.send(CommandID.REQUEST_COUNT,MainManager.actorID);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
         closeBtn.removeEventListener(MouseEvent.CLICK,closeHandler);
      }
      
      private static function copyContent(param1:MouseEvent) : void
      {
         var _loc2_:String = "我正在赛尔号上进行太空探险，带着我的精灵在各个星球上战斗，他们还会进化呢。快和我一起来吧，www.51seer.com 注册的邀请码是" + GetRegisterCode.getRegCode.toString() + "。我们赛尔号上见！";
         System.setClipboard(_loc2_);
      }
      
      private static function getRequstAward(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.GET_REQUEST_AWARD,onGetAward);
         SocketConnection.send(CommandID.GET_REQUEST_AWARD);
      }
      
      private static function onGetAward(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.GET_REQUEST_AWARD,onGetAward);
         NpcTipDialog.show("恭喜你成为合格的星际联络官，联络官套装已经放入了你的储存箱");
      }
      
      private static function onCount(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.REQUEST_COUNT,onCount);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         mc["countTxt"].text = _loc4_.toString();
      }
   }
}

