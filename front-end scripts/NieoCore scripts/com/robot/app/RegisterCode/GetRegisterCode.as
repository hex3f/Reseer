package com.robot.app.RegisterCode
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class GetRegisterCode
   {
      
      private static var code:uint;
      
      private static var codeMC:MovieClip;
      
      private static var curUserId:uint;
      
      public function GetRegisterCode()
      {
         super();
      }
      
      public static function getCode() : void
      {
         code = MainManager.actorInfo.userID + 1321047;
         Alarm.show("点右上角星际联络官图标后可得到邀请码");
      }
      
      public static function count() : void
      {
         if(MapManager.currentMap.id > 50000)
         {
            code = MapManager.currentMap.id + 1321047;
            curUserId = MapManager.currentMap.id;
         }
         else
         {
            code = MainManager.actorInfo.userID + 1321047;
            curUserId = MainManager.actorInfo.userID;
         }
         SocketConnection.addCmdListener(CommandID.REQUEST_COUNT,onCount);
         SocketConnection.send(CommandID.REQUEST_COUNT,curUserId);
      }
      
      private static function onCount(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.REQUEST_COUNT,onCount);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         codeMC = UIManager.getMovieClip("requestCodePanel");
         LevelManager.appLevel.addChild(codeMC);
         DisplayUtil.align(codeMC,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         (codeMC["codeTxt"] as TextField).text = code.toString();
         (codeMC["countTxt"] as TextField).text = _loc4_.toString();
         codeMC.addEventListener(MouseEvent.CLICK,remove);
      }
      
      private static function remove(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(codeMC);
         LevelManager.openMouseEvent();
         codeMC.removeEventListener(MouseEvent.CLICK,remove);
         codeMC = null;
      }
      
      public static function get getRegCode() : uint
      {
         return MainManager.actorInfo.userID + 1321047;
      }
   }
}

