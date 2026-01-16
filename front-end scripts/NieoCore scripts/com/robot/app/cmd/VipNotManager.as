package com.robot.app.cmd
{
   import com.robot.app.mapProcess.MapProcess_107;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.SystemMsgInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.SocketConnection;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class VipNotManager
   {
      
      private var npcMC:Sprite;
      
      private var npcLink:Array = [""];
      
      private var npcName:Array = ["","船长罗杰","机械师茜茜","博士派特","导航员爱丽丝","站长贾斯汀","诺诺","发明家肖恩"];
      
      private var panel:MovieClip;
      
      private var callBtn:SimpleButton;
      
      private var continueBtn:SimpleButton;
      
      private var goNowBtn:SimpleButton;
      
      public function VipNotManager()
      {
         super();
         this.npcLink.push(NpcTipDialog.SHIPER);
         this.npcLink.push(NpcTipDialog.CICI);
         this.npcLink.push(NpcTipDialog.DOCTOR);
         this.npcLink.push(NpcTipDialog.IRIS);
         this.npcLink.push(NpcTipDialog.JUSTIN);
         this.npcLink.push(NpcTipDialog.NONO);
         this.npcLink.push(NpcTipDialog.SHAWN);
      }
      
      public function goNow(param1:SystemMsgInfo) : void
      {
         this.goNowBtn = AssetsManager.getButton("lib_goNowBtn");
         this.goNowBtn.addEventListener(MouseEvent.CLICK,this.goNowHandler);
         this.show(this.goNowBtn,param1,false);
         LevelManager.closeMouseEvent();
      }
      
      public function openAgain(param1:SystemMsgInfo) : void
      {
         this.callBtn = AssetsManager.getButton("lib_callBtn");
         this.callBtn.addEventListener(MouseEvent.CLICK,this.callHandler);
         this.show(this.callBtn,param1);
      }
      
      public function cancelHandler(param1:SystemMsgInfo) : void
      {
         this.continueBtn = AssetsManager.getButton("lib_continueBtn");
         this.continueBtn.addEventListener(MouseEvent.CLICK,this.continueHandler);
         this.show(this.continueBtn,param1);
      }
      
      private function goNowHandler(param1:MouseEvent) : void
      {
         LevelManager.openMouseEvent();
         DisplayUtil.removeForParent(this.goNowBtn);
         DisplayUtil.removeForParent(this.panel,false);
         MapProcess_107.isOpenSuperNoNo = true;
         MapManager.changeMap(107);
      }
      
      private function callHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.callBtn);
         DisplayUtil.removeForParent(this.panel,false);
         NonoManager.isBeckon = true;
         SocketConnection.send(CommandID.NONO_FOLLOW_OR_HOOM,1);
      }
      
      public function continueHandler(param1:MouseEvent) : void
      {
         var r:VipSession = null;
         var event:MouseEvent = param1;
         DisplayUtil.removeForParent(this.continueBtn);
         DisplayUtil.removeForParent(this.panel,false);
         r = new VipSession();
         r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
         {
         });
         r.getSession();
      }
      
      private function show(param1:DisplayObject, param2:SystemMsgInfo, param3:Boolean = true) : void
      {
         var date:Date = null;
         var str:String = null;
         var dis:DisplayObject = param1;
         var data:SystemMsgInfo = param2;
         var isShowClose:Boolean = param3;
         this.panel = this.getPanel(isShowClose);
         this.panel["titleTxt"].text = "亲爱的" + MainManager.actorInfo.nick;
         this.panel["msgTxt"].htmlText = data.msg;
         date = new Date(data.msgTime * 1000);
         str = this.npcName[data.npc] + "\r";
         this.panel["timeTxt"].text = str + date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate() + "日";
         ResourceManager.getResource(ClientConfig.getNpcSwfPath(this.npcLink[data.npc]),function(param1:DisplayObject):void
         {
            npcMC.addChild(param1);
         },"npc");
         LevelManager.topLevel.addChild(this.panel);
         this.panel.addChild(dis);
         DisplayUtil.align(dis,this.panel.getRect(this.panel),AlignType.BOTTOM_CENTER);
         dis.y -= 30;
      }
      
      private function getPanel(param1:Boolean = true) : MovieClip
      {
         var _loc2_:MovieClip = UIManager.getMovieClip("ui_SysMsg_Panel");
         var _loc3_:SimpleButton = _loc2_["closeBtn"];
         _loc3_.addEventListener(MouseEvent.CLICK,this.closeHandler);
         if(!param1)
         {
            DisplayUtil.removeForParent(_loc3_);
         }
         this.npcMC = new Sprite();
         this.npcMC.scaleX = this.npcMC.scaleY = 0.65;
         this.npcMC.x = 50;
         this.npcMC.y = 86;
         _loc2_.addChild(this.npcMC);
         DisplayUtil.align(_loc2_,null,AlignType.MIDDLE_CENTER);
         return _loc2_;
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this.panel,false);
         DisplayUtil.removeAllChild(this.npcMC);
      }
   }
}

