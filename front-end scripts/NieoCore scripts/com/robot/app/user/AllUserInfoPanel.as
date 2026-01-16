package com.robot.app.user
{
   import com.robot.app.achieve.AchieveTitlePanelController;
   import com.robot.app.bag.*;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.AchieveXMLInfo;
   import com.robot.core.info.AchieveTitleInfo;
   import com.robot.core.info.UserInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.*;
   import flash.display.*;
   import flash.events.*;
   import flash.text.*;
   import gs.*;
   import gs.events.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class AllUserInfoPanel extends Sprite
   {
      
      private const allBossNum_uint:uint = 20;
      
      private var _allBossIdA:Array = [301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320];
      
      private var page:uint;
      
      private var curIndex:uint = 1;
      
      private var bossContainer:Sprite;
      
      private var bossMask:Sprite;
      
      private var _containerWidth2:Number;
      
      private var _containerX:Number;
      
      private var panel:MovieClip;
      
      private var userInfo:UserInfo;
      
      private var changeNick:ChangeNickName;
      
      private var tt1:TweenMax;
      
      private var tt2:TweenMax;
      
      private var extendTween:TweenMax;
      
      private var retractTween:TweenMax;
      
      private var oTherClothPrev:BagClothPreview;
      
      private var otherFaceShow:Sprite;
      
      private const move:Number = 270.6;
      
      protected var _achievementsIcon:MovieClip;
      
      protected var _achievementsTxt:TextField;
      
      protected var _achievementsTf:TextFormat;
      
      public function AllUserInfoPanel()
      {
         super();
         this.setup();
      }
      
      public function setup() : void
      {
         this.panel = this.getPanel();
         this.otherFaceShow = this.getFaceBg();
         this.oTherClothPrev = new BagClothPreview(this.otherFaceShow,null,ClothPreview.MODEL_SHOW);
         this.panel["achievement_txt"].autoSize = TextFieldAutoSize.LEFT;
         this.panel["achievement_txt"].selectable = false;
         this.panel["stageTxt"].autoSize = TextFieldAutoSize.LEFT;
         this.panel["stageTxt"].selectable = false;
         this.panel["arenaTxt"].selectable = false;
         this.panel["noBtn"].visible = false;
      }
      
      private function onchoiceTitle(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         SocketConnection.addCmdListener(CommandID.ACHIEVETITLELIST,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.ACHIEVETITLELIST,arguments.callee);
            var _loc3_:AchieveTitleInfo = param1.data as AchieveTitleInfo;
            AchieveTitlePanelController.show(_loc3_,panel);
         });
         SocketConnection.send(CommandID.ACHIEVETITLELIST);
      }
      
      public function init(param1:UserInfo) : void
      {
         this.curIndex = 1;
         this.userInfo = param1;
         UserInfoManager.upDateMoreInfo(this.userInfo,this.onUserInfoUpdataHandler);
      }
      
      public function hide() : void
      {
         this.removeEvent();
         DisplayUtil.removeForParent(this.panel);
         DisplayUtil.removeForParent(this);
         if(this.userInfo.userID != MainManager.actorInfo.userID)
         {
            AllUserInfoController.setStatus = false;
         }
      }
      
      public function show(param1:UserInfo, param2:DisplayObjectContainer) : void
      {
         this.curIndex = 1;
         this.userInfo = param1;
         if(this.allBossNum_uint % 3 == 0)
         {
            this.page = uint(this.allBossNum_uint / 3);
         }
         else
         {
            this.page = uint(this.allBossNum_uint / 3) + 1;
         }
         this.addChild(this.panel);
         if(this.userInfo.userID == MainManager.actorInfo.userID)
         {
            LevelManager.appLevel.addChild(this);
            DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER,null);
         }
         else
         {
            param2.addChildAt(this,0);
            this.x = 0;
         }
         this.panel["prevMC"].addChild(this.otherFaceShow);
         if(this.userInfo.userID == MainManager.actorInfo.userID)
         {
            this.panel["flex_mc"].visible = false;
         }
         else
         {
            this.panel["close_btn"].visible = false;
            this.panel["chNickTagBtn"].visible = false;
            this.panel["chNickBtn"].visible = false;
            this.extendTween = new TweenMax(this,0.3,{"x":this.move});
            this.extendTween.addEventListener(TweenEvent.COMPLETE,this.onExtendTweenCompleteHandler);
         }
         this.addEvent();
         this.init(this.userInfo);
      }
      
      private function onExtendTweenCompleteHandler(param1:TweenEvent) : void
      {
         this.extendTween.removeEventListener(TweenEvent.COMPLETE,this.onExtendTweenCompleteHandler);
         this.extendTween = null;
         this.panel["flex_mc"].mouseChildren = true;
         this.panel["flex_mc"].addEventListener(MouseEvent.CLICK,this.onOtherPanelFlexMcHandler);
      }
      
      private function onUserInfoUpdataHandler() : void
      {
         if(this.userInfo.userID == MainManager.actorInfo.userID)
         {
            if(!this.changeNick)
            {
               this.changeNick = new ChangeNickName();
               this.changeNick.init(this.panel);
            }
         }
         if(Boolean(this.userInfo.vip))
         {
            this.panel["noBtn"].visible = true;
         }
         var _loc1_:String = AchieveXMLInfo.getTitle(this.userInfo.curTitle);
         this.panel["title"].text = _loc1_;
         this.panel["name_txt"].text = this.userInfo.nick;
         this.panel["mimi_txt"].text = String(this.userInfo.userID);
         this.panel["arg_txt"].text = String(this.userInfo.graduationCount) + "人";
         var _loc2_:Date = new Date(this.userInfo.regTime * 1000);
         this.panel["time_txt"].text = _loc2_.getFullYear().toString() + "年" + (_loc2_.getMonth() + 1).toString() + "月" + _loc2_.getDate().toString() + "日";
         this.panel["mum_txt"].text = String(this.userInfo.petAllNum);
         this.panel["le_txt"].text = String(this.userInfo.petMaxLev);
         this.panel["achievement_txt"].text = String(this.userInfo.monKingWin) + "胜";
         this.panel["petTxt"].text = String(this.userInfo.messWin) + "胜";
         this.panel["stageTxt"].text = String(this.userInfo.maxStage) + "层";
         this.panel["arenaTxt"].text = String(this.userInfo.maxArenaWins) + "连胜";
         this.oTherClothPrev.changeColor(this.userInfo.color);
         this.oTherClothPrev.showCloths(this.userInfo.clothes);
         this.oTherClothPrev.showDoodle(this.userInfo.texture);
         this.addBossIcon();
      }
      
      private function addEvent() : void
      {
         this.panel["leftBtn"].addEventListener(MouseEvent.CLICK,this.onOtherLeftHandler);
         this.panel["rightBtn"].addEventListener(MouseEvent.CLICK,this.onOtherRightHandler);
         if(this.userInfo.userID == MainManager.actorInfo.userID)
         {
            this.panel["titleBtn"].addEventListener(MouseEvent.CLICK,this.onchoiceTitle);
            this.panel["close_btn"].addEventListener(MouseEvent.CLICK,this.onCloseHandler);
            this.panel["drag_mc"].buttonMode = true;
            this.panel["drag_mc"].addEventListener(MouseEvent.MOUSE_DOWN,this.onDownHandler);
         }
         else
         {
            this.panel["titleBtn"].visible = false;
         }
      }
      
      private function removeEvent() : void
      {
         this.panel["leftBtn"].removeEventListener(MouseEvent.CLICK,this.onOtherLeftHandler);
         this.panel["rightBtn"].removeEventListener(MouseEvent.CLICK,this.onOtherRightHandler);
         if(this.userInfo.userID == MainManager.actorInfo.userID)
         {
            this.panel["titleBtn"].removeEventListener(MouseEvent.CLICK,this.onchoiceTitle);
            this.panel["close_btn"].removeEventListener(MouseEvent.CLICK,this.onCloseHandler);
            this.panel["drag_mc"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onDownHandler);
         }
      }
      
      private function onCloseHandler(param1:MouseEvent) : void
      {
         this.hide();
      }
      
      private function onDownHandler(param1:MouseEvent) : void
      {
         this.startDrag();
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
      }
      
      private function onUpHandler(param1:MouseEvent) : void
      {
         this.stopDrag();
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onUpHandler);
      }
      
      public function destroy() : void
      {
         if(Boolean(this.extendTween))
         {
            this.extendTween.pause();
            this.extendTween.removeEventListener(TweenEvent.COMPLETE,this.onExtendTweenCompleteHandler);
            this.extendTween = null;
         }
         if(Boolean(this.retractTween))
         {
            this.retractTween.pause();
            this.retractTween.removeEventListener(TweenEvent.COMPLETE,this.onReTractCompleteHandler);
            this.retractTween = null;
         }
         if(Boolean(this.tt1))
         {
            this.tt1.pause();
            this.tt1.removeEventListener(TweenEvent.COMPLETE,this.onTT1Handler);
            this.tt1 = null;
         }
         if(Boolean(this.tt2))
         {
            this.tt2.pause();
            this.tt2.removeEventListener(TweenEvent.COMPLETE,this.onTT2Handler);
            this.tt2 = null;
         }
         if(Boolean(this.changeNick))
         {
            this.changeNick.destory();
         }
         if(this.userInfo.userID != MainManager.actorInfo.userID)
         {
            AllUserInfoController.setStatus = false;
         }
         this.removeEvent();
         DisplayUtil.removeForParent(this.panel);
         DisplayUtil.removeForParent(this);
         this.panel = null;
         this.otherFaceShow = null;
         this.oTherClothPrev = null;
         this.bossContainer = null;
         this.bossMask = null;
         this.userInfo = null;
      }
      
      public function returnFelx() : void
      {
         this.retractTween = new TweenMax(this,0.3,{"x":0});
         this.retractTween.addEventListener(TweenEvent.COMPLETE,this.onReTractCompleteHandler);
      }
      
      private function onOtherPanelFlexMcHandler(param1:MouseEvent) : void
      {
         this.returnFelx();
      }
      
      private function onReTractCompleteHandler(param1:TweenEvent) : void
      {
         this.retractTween.removeEventListener(TweenEvent.COMPLETE,this.onReTractCompleteHandler);
         this.retractTween = null;
         this.panel["flex_mc"].mouseEnabled = false;
         this.panel["flex_mc"].removeEventListener(MouseEvent.CLICK,this.onOtherPanelFlexMcHandler);
         this.hide();
      }
      
      private function onOtherLeftHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(this.curIndex > 1)
         {
            _loc2_ = this.bossContainer.x + 150;
            --this.curIndex;
            this.panel["leftBtn"].removeEventListener(MouseEvent.CLICK,this.onOtherLeftHandler);
            this.tt1 = new TweenMax(this.bossContainer,0.5,{"x":_loc2_});
            this.tt1.addEventListener(TweenEvent.COMPLETE,this.onTT1Handler);
         }
      }
      
      private function onTT1Handler(param1:TweenEvent) : void
      {
         this.tt1.removeEventListener(TweenEvent.COMPLETE,this.onTT1Handler);
         this.panel["leftBtn"].addEventListener(MouseEvent.CLICK,this.onOtherLeftHandler);
      }
      
      private function onOtherRightHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(this.curIndex < this.page)
         {
            _loc2_ = this.bossContainer.x - 150;
            ++this.curIndex;
            this.panel["rightBtn"].removeEventListener(MouseEvent.CLICK,this.onOtherRightHandler);
            this.tt2 = new TweenMax(this.bossContainer,0.5,{"x":_loc2_});
            this.tt2.addEventListener(TweenEvent.COMPLETE,this.onTT2Handler);
         }
      }
      
      private function onTT2Handler(param1:TweenEvent) : void
      {
         this.tt2.removeEventListener(TweenEvent.COMPLETE,this.onTT2Handler);
         this.panel["rightBtn"].addEventListener(MouseEvent.CLICK,this.onOtherRightHandler);
      }
      
      private function addBossIcon(param1:Array = null) : void
      {
         var _loc2_:Sprite = null;
         if(Boolean(this.bossContainer))
         {
            if(DisplayUtil.hasParent(this.bossContainer))
            {
               DisplayUtil.removeAllChild(this.bossContainer);
               DisplayUtil.removeForParent(this.bossContainer);
               this.bossContainer = null;
            }
         }
         this.bossContainer = new Sprite();
         this.panel.addChild(this.bossContainer);
         this.bossContainer.x = 62;
         this.bossContainer.y = 187;
         if(Boolean(this.bossMask))
         {
            if(DisplayUtil.hasParent(this.bossMask))
            {
               DisplayUtil.removeForParent(this.bossMask);
               this.bossMask.graphics.clear();
               this.bossMask = null;
            }
         }
         this.bossMask = new Sprite();
         this.bossMask.graphics.lineStyle(1,0,1);
         this.bossMask.graphics.beginFill(0,1);
         this.bossMask.graphics.drawRect(0,0,145,40);
         this.bossMask.graphics.endFill();
         this.panel.addChild(this.bossMask);
         this.bossMask.x = 62;
         this.bossMask.y = 175;
         this.bossContainer.mask = this.bossMask;
         this.bossContainer.y -= 12;
         var _loc3_:int = 0;
         while(_loc3_ < this.allBossNum_uint)
         {
            _loc2_ = UIManager.getSprite("Boss" + this._allBossIdA[_loc3_] + "_MC");
            this.bossContainer.addChild(_loc2_);
            _loc2_.x = (_loc2_.width + 15) * _loc3_;
            _loc2_.y = 2;
            if(this.userInfo.userID == MainManager.actorInfo.userID)
            {
               if(this.userInfo.bossAchievement[_loc3_] == true)
               {
                  _loc2_["mc1"].visible = false;
               }
            }
            else if(this.userInfo.bossAchievement[_loc3_] == true)
            {
               _loc2_["mc1"].visible = false;
            }
            _loc2_["win_mc"].visible = false;
            _loc3_++;
         }
      }
      
      private function getPanel() : MovieClip
      {
         return UIManager.getMovieClip("AllUserInfoPanel_MC");
      }
      
      private function getFaceBg() : Sprite
      {
         var _loc1_:Sprite = UIManager.getSprite("ComposeMC");
         _loc1_.mouseEnabled = false;
         _loc1_.mouseChildren = false;
         _loc1_.scaleX = _loc1_.scaleY = 0.5;
         _loc1_.x = (71 - _loc1_.width) / 2;
         return _loc1_;
      }
   }
}

