package com.robot.app.task.publicizeenvoy
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.system.System;
   import flash.text.TextField;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class PublicizeEnvoyPanel extends Sprite
   {
      
      private const PATH:String = "module/publicizeenvoy/PublicizeEnvoyPanel.swf";
      
      private var mainMC:MovieClip;
      
      private var alertMC:MovieClip;
      
      private var inviteCode:TextField;
      
      private var count:TextField;
      
      private var alarmtxt:TextField;
      
      private var copy:SimpleButton;
      
      private var closeBtn:SimpleButton;
      
      private var _alarmStr:String = "感谢你为赛尔号召集到这些勇士，快去<font color=\'#ff0000\' size=\'14\'>船长室</font>找<font color=\'#ff0000\'  size=\'14\'>船长</font>领取属于你的奖励吧！";
      
      private var _alarmB:Boolean = false;
      
      public function PublicizeEnvoyPanel()
      {
         super();
      }
      
      public function show(param1:Boolean) : void
      {
         this._alarmB = param1;
         if(Boolean(this.mainMC))
         {
            this.init();
         }
         else
         {
            this.loadUI();
         }
      }
      
      private function loadUI() : void
      {
         var _loc1_:String = ClientConfig.getResPath(this.PATH);
         var _loc2_:MCLoader = new MCLoader(_loc1_,LevelManager.appLevel,1,"正在打开赛尔召集令面板");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         _loc2_.doLoad();
      }
      
      private function onLoadSuccess(param1:MCLoadEvent) : void
      {
         var _loc2_:MCLoader = param1.currentTarget as MCLoader;
         _loc2_.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         var _loc3_:Class = param1.getApplicationDomain().getDefinition("PublicizeEnloyPanel") as Class;
         this.mainMC = new _loc3_() as MovieClip;
         this.alertMC = this.mainMC["alertmc"];
         this.inviteCode = this.mainMC["invitecode"];
         this.count = this.mainMC["count"];
         this.alarmtxt = this.alertMC["alarmtxt"];
         if(this._alarmB)
         {
            this.alertMC.visible = true;
            this.alarmtxt.htmlText = this._alarmStr;
         }
         else
         {
            this.alertMC.visible = false;
         }
         this.copy = this.mainMC["copybtn"];
         this.copy.addEventListener(MouseEvent.CLICK,this.copyHandler);
         this.closeBtn = this.mainMC["closebtn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.close);
         _loc2_.clear();
         this.init();
      }
      
      private function init() : void
      {
         this.inviteCode.text = this.getRegCode().toString();
         this.count.text = MainManager.actorInfo.newInviteeCnt.toString();
         this.addChild(this.mainMC);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(this);
      }
      
      private function copyHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = "我正在赛尔号上进行太空探险，带着我的精灵在各个星球上战斗，他们还会进化呢。快和我一起来吧，seer.61.com 注册的邀请码是" + this.getRegCode().toString() + "。我们赛尔号上见！";
         System.setClipboard(_loc2_);
         Alarm.show("复制成功，现在可以使用右键粘贴到QQ或者MSN聊天窗口发送给朋友，记得让你的朋友在注册时输入邀请码哦！");
         this.close(null);
      }
      
      private function close(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
      }
      
      public function getRegCode() : uint
      {
         return MainManager.actorInfo.userID + 1321047;
      }
   }
}

