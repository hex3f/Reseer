package com.robot.app.mapProcess
{
   import com.robot.app.darkPortal.*;
   import com.robot.app.fightNote.FightInviteManager;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.fightInfo.attack.FightOverInfo;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.*;
   import flash.net.SharedObject;
   import flash.utils.*;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_110 extends BaseMapProcess
   {
      
      private const _petId:uint = 169;
      
      private var _timer:uint;
      
      private var _point:Point = new Point(479.9,335);
      
      private var _perMc:MovieClip;
      
      private var _collId:uint = 400053;
      
      private var _doorIndex:uint;
      
      private var _lenght:uint = 11;
      
      private var _tipsA:Array = ["暗黑第一门","暗黑第二门","暗黑第三门","暗黑第四门","暗黑第五门","暗黑第六门","暗黑第七门","暗黑第八门","暗黑第九门","暗黑第十门","暗黑第十一门"];
      
      private var _so:SharedObject;
      
      private var _bookApp:AppModel;
      
      private var _targetMC:MovieClip;
      
      public function MapProcess_110()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:int = 0;
         ToolTipManager.add(conLevel["monsterMc"],"试炼之门");
         conLevel["monsterMc"].gotoAndStop(1);
         conLevel["monsterMc"].visible = true;
         conLevel["monsterMc"].addEventListener(MouseEvent.CLICK,this.onClickHandler);
         conLevel["monsterMc"].addEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
         conLevel["monsterMc"].addEventListener(MouseEvent.MOUSE_OUT,this.onOutHandler);
         while(_loc1_ < this._lenght)
         {
            conLevel["darkMc_" + _loc1_].addEventListener(MouseEvent.CLICK,this.onDoorMcClickHandler);
            conLevel["darkMc_" + _loc1_].buttonMode = true;
            ToolTipManager.add(conLevel["darkMc_" + _loc1_],this._tipsA[_loc1_]);
            _loc1_++;
         }
         this._so = SOManager.getUserSO(SOManager.Is_Readed_DarkBook);
         if(this._so.data.hasOwnProperty("isShow"))
         {
            if(this._so.data["isShow"] == true)
            {
               conLevel["darkBookMc"]["mc"].gotoAndStop(1);
               conLevel["darkBookMc"]["mc"].visible = false;
            }
         }
         else
         {
            this._so.data["isShow"] = false;
            SOManager.flush(this._so);
         }
         ToolTipManager.add(conLevel["darkBookMc"],"暗黑武斗手册");
         conLevel["darkBookMc"].buttomMode = true;
         conLevel["darkBookMc"].addEventListener(MouseEvent.MOUSE_OVER,this.onBookOverHandler);
         conLevel["darkBookMc"].addEventListener(MouseEvent.MOUSE_OUT,this.onBookOutHandler);
         conLevel["darkBookMc"].addEventListener(MouseEvent.CLICK,this.onBookHandler);
      }
      
      private function onBookHandler(param1:MouseEvent) : void
      {
         this._so.data["isShow"] = true;
         SOManager.flush(this._so);
         conLevel["darkBookMc"]["mc"].visible = false;
         conLevel["darkBookMc"]["mc"].gotoAndStop(1);
         if(this._bookApp == null)
         {
            this._bookApp = new AppModel(ClientConfig.getBookModule("DarkProtalBookPanel"),"正在打开");
            this._bookApp.setup();
         }
         this._bookApp.show();
      }
      
      private function onBookOverHandler(param1:MouseEvent) : void
      {
         conLevel["darkBookMc"].gotoAndStop(2);
      }
      
      private function onBookOutHandler(param1:MouseEvent) : void
      {
         conLevel["darkBookMc"].gotoAndStop(1);
      }
      
      private function onOverHandler(param1:MouseEvent) : void
      {
         conLevel["monsterMc"].gotoAndStop(2);
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         conLevel["monsterMc"].gotoAndStop(1);
      }
      
      private function showDoor() : void
      {
         if(Boolean(this._targetMC))
         {
            this._targetMC.visible = true;
            this._targetMC = null;
         }
      }
      
      private function onDoorMcClickHandler(param1:MouseEvent) : void
      {
         this.showDoor();
         this._targetMC = param1.currentTarget as MovieClip;
         this._targetMC.visible = false;
         var _loc2_:String = param1.currentTarget.name;
         this._doorIndex = uint(_loc2_.slice(7,_loc2_.length));
         if(MainManager.actorInfo.superNono == true)
         {
            if(NonoManager.info.superLevel < this._doorIndex + 1)
            {
               NpcTipDialog.show("你的超能NoNo必须成长为超能" + TextFormatUtil.getRedTxt((this._doorIndex + 1).toString()) + "级才能帮你开启暗黑第" + (this._doorIndex + 1) + "门。",null,NpcTipDialog.NONO);
               return;
            }
            DarkPortalModel.curDoor = this._doorIndex;
            DarkPortalModel.showDoor(this._doorIndex,this.showDoor);
         }
         else
         {
            if(this._doorIndex > 0)
            {
               NpcTipDialog.show("只有" + TextFormatUtil.getRedTxt("超能NoNo") + "的帮助下，赛尔们才能进入暗黑之门，接受新的挑战。快为你的NoNo充能，让它成为超能NoNo吧！",null,NpcTipDialog.NONO);
               return;
            }
            ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,this.onList);
            ItemManager.getCollection();
         }
      }
      
      private function onList(param1:ItemEvent) : void
      {
         ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,this.onList);
         var _loc2_:SingleItemInfo = ItemManager.getCollectionInfo(this._collId);
         if(_loc2_ == null)
         {
            Alarm.show("你没有" + TextFormatUtil.getRedTxt("暗黑之钥") + "不能进入暗黑空间！");
         }
         else
         {
            DarkPortalModel.curDoor = this._doorIndex;
            DarkPortalModel.showDoor(this._doorIndex);
         }
      }
      
      private function onClickHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         NpcTipDialog.showAnswer("欢迎来到暗黑武斗场，你正在开启试炼之门，我是被赋予了反物质力量的守门精灵！你确定现在就开始接受我的试炼吗？",function():void
         {
            conLevel["monsterMc"].removeEventListener(MouseEvent.MOUSE_OVER,onOverHandler);
            conLevel["monsterMc"].removeEventListener(MouseEvent.MOUSE_OUT,onOutHandler);
            conLevel["monsterMc"].gotoAndStop(3);
            _timer = setTimeout(onTimerOutHandler,1650);
         },null,NpcTipDialog.DARKPET);
      }
      
      private function onTimerOutHandler() : void
      {
         clearTimeout(this._timer);
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this._petId),this.onPetComHandler,"pet");
      }
      
      private function onPetComHandler(param1:DisplayObject) : void
      {
         if(Boolean(param1))
         {
            this._perMc = param1 as MovieClip;
            depthLevel.addChild(this._perMc);
            this._perMc.x = this._point.x;
            this._perMc.y = this._point.y;
            this._perMc.scaleX = 1.8;
            this._perMc.scaleY = 1.8;
            ToolTipManager.add(this._perMc,PetXMLInfo.getName(this._petId));
            this._perMc.addEventListener(MouseEvent.CLICK,this.onPetClickHandler);
            this._perMc.buttonMode = true;
            conLevel["monsterMc"].removeEventListener(MouseEvent.CLICK,this.onClickHandler);
            conLevel["monsterMc"].visible = false;
         }
      }
      
      private function onPetClickHandler(param1:MouseEvent) : void
      {
         var e:MouseEvent = param1;
         this._perMc.removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
         setTimeout(function():void
         {
            if(Boolean(_perMc))
            {
               _perMc.addEventListener(MouseEvent.CLICK,onPetClickHandler);
            }
         },1000);
         EventManager.addEventListener(PetFightEvent.FIGHT_CLOSE,this.onCloseFight);
         FightInviteManager.fightWithBoss("卡特斯");
      }
      
      private function onCloseFight(param1:PetFightEvent) : void
      {
         var _loc2_:FightOverInfo = param1.dataObj["data"];
         if(_loc2_.winnerID == MainManager.actorInfo.userID)
         {
            if(MainManager.actorInfo.superNono == false)
            {
            }
         }
      }
      
      public function onEnterDoorHandler() : void
      {
         MapManager.changeLocalMap(503);
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         this._so = null;
         if(Boolean(this._perMc))
         {
            this._perMc.removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
            DisplayUtil.removeForParent(this._perMc);
            this._perMc = null;
         }
         conLevel["monsterMc"].removeEventListener(MouseEvent.CLICK,this.onClickHandler);
         while(_loc1_ < this._lenght)
         {
            conLevel["darkMc_" + _loc1_].removeEventListener(MouseEvent.CLICK,this.onDoorMcClickHandler);
            _loc1_++;
         }
         conLevel["monsterMc"].removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
         conLevel["monsterMc"].removeEventListener(MouseEvent.MOUSE_OUT,this.onOutHandler);
         ToolTipManager.remove(conLevel["monsterMc"]);
         ToolTipManager.remove(conLevel["darkMc_0"]);
         ToolTipManager.remove(conLevel["darkBookMc"]);
         conLevel["darkBookMc"].removeEventListener(MouseEvent.MOUSE_OVER,this.onBookOverHandler);
         conLevel["darkBookMc"].removeEventListener(MouseEvent.MOUSE_OUT,this.onBookOutHandler);
         if(Boolean(this._bookApp))
         {
            this._bookApp.destroy();
            this._bookApp = null;
         }
         DarkPortalModel.destroy();
      }
   }
}

