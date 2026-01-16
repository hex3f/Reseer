package com.robot.app.mapProcess
{
   import com.robot.app.petUpdate.*;
   import com.robot.app.task.taskUtils.taskDialog.*;
   import com.robot.app.vipSession.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.NonoInfo;
   import com.robot.core.info.pet.PetShowInfo;
   import com.robot.core.info.task.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.*;
   import com.robot.core.net.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.utils.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class MapProcess_56 extends BaseMapProcess
   {
      
      private var _nonoMc:MovieClip;
      
      private var _lightMc:MovieClip;
      
      private var _plantMc:MovieClip;
      
      private var _wendyMc:MovieClip;
      
      private var _hitTimer:uint;
      
      private var _type:uint;
      
      private var _remainTime:uint;
      
      private var _appModel:AppModel;
      
      private var _petName:String;
      
      private var _petInfo:PetShowInfo;
      
      private var _petMc:MovieClip;
      
      private var _isShow:Boolean;
      
      private var _npc:String;
      
      private var _info:NonoInfo;
      
      public function MapProcess_56()
      {
         super();
      }
      
      override protected function init() : void
      {
         if(MainManager.actorInfo.superNono)
         {
            this._npc = NpcTipDialog.NONO;
            this._type = 2054;
         }
         else
         {
            this._npc = NpcTipDialog.NONO_2;
            this._type = 17;
         }
         SocketConnection.addCmdListener(CommandID.TALK_COUNT,this.onGetCountHandler);
         SocketConnection.send(CommandID.TALK_COUNT,this._type);
      }
      
      private function onGetCountHandler(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.TALK_COUNT,this.onGetCountHandler);
         var _loc2_:MiningCountInfo = param1.data as MiningCountInfo;
         this._remainTime = 5 - _loc2_.miningCount;
         if(MainManager.actorInfo.superNono)
         {
            this._npc = NpcTipDialog.NONO;
         }
         else
         {
            this._npc = NpcTipDialog.NONO_2;
         }
         this._hitTimer = 0;
         this._plantMc = this.conLevel["plantMc"];
         this._plantMc.buttonMode = true;
         ToolTipManager.add(this._plantMc,"希欧珊瑚");
         this._plantMc.addEventListener(MouseEvent.CLICK,this.onPlantClickHandler);
         this._nonoMc = this.conLevel["nonoMc"];
         this._lightMc = this.conLevel["lightMc"];
         this._wendyMc = this.conLevel["wendyMc"];
         this._lightMc.buttonMode = true;
         this._lightMc.addEventListener(MouseEvent.MOUSE_OVER,this.onLightOverHandler);
         this._lightMc.addEventListener(MouseEvent.MOUSE_OUT,this.onLightOutHandler);
         this._lightMc.addEventListener(MouseEvent.CLICK,this.onLightClickHandler);
         this._wendyMc.buttonMode = true;
         this._wendyMc.addEventListener(MouseEvent.CLICK,this.onWendyClickHandler);
         ToolTipManager.add(this._wendyMc,"露希欧之洋大陆架");
      }
      
      private function onLightOutHandler(param1:MouseEvent) : void
      {
         this._lightMc.gotoAndStop(1);
      }
      
      private function onLightOverHandler(param1:MouseEvent) : void
      {
         this._lightMc.gotoAndPlay(2);
      }
      
      private function onLightClickHandler(param1:MouseEvent) : void
      {
         if(!this._appModel)
         {
            this._appModel = new AppModel("module/com/robot/module/game/kickBall/KickBallGame.swf","正在进入游戏");
         }
         this._appModel.setup();
         this._appModel.show();
         this._appModel = null;
      }
      
      private function onWendyClickHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(!MainManager.actorInfo.superNono)
         {
            DynamicNpcTipDialog.show("露希欧之洋大陆架的地表层含着丰富的能量资源，在这里精灵可以自然的吸收能量成长，不过能量的析出要用到" + TextFormatUtil.getRedTxt("超能NoNo") + "的超能力哟，快为你的NoNo充能吧！",this.url,NpcTipDialog.NONO);
            return;
         }
         if(!MainManager.actorModel.nono || !MainManager.actorModel.pet)
         {
            NpcTipDialog.show("露希欧星之洋大陆架的地表层含着丰富的能量资源，在这里" + TextFormatUtil.getRedTxt("水系精灵") + "可以自然的吸收能量成长，不过能量的析出要用到NoNo的超能力，快带上你的" + TextFormatUtil.getRedTxt("超能NoNo") + "！",null,NpcTipDialog.NONO);
            return;
         }
         if(Boolean(MainManager.actorModel.nono) && Boolean(MainManager.actorModel.pet))
         {
            this._petInfo = MainManager.actorModel.pet.info;
            this._petName = PetXMLInfo.getName(this._petInfo.petID);
            _loc2_ = PetXMLInfo.getType(this._petInfo.petID);
            if(_loc2_ == "7")
            {
               ResourceManager.getResource(ClientConfig.getPetSwfPath(this._petInfo.petID),this.onLoadPetHandler);
            }
         }
      }
      
      private function onLoadPetHandler(param1:DisplayObject) : void
      {
         var mc:DisplayObject = param1;
         if(Boolean(mc))
         {
            MainManager.actorModel.hidePet();
            this._wendyMc.gotoAndStop(2);
            this._petMc = mc as MovieClip;
            this.conLevel.addChild(this._petMc);
            this._petMc.x = 370;
            this._petMc.y = 261;
            setTimeout(function():void
            {
               MainManager.actorModel.showPet(_petInfo);
               _wendyMc.gotoAndStop(1);
               DisplayUtil.removeForParent(_petMc);
               _isShow = false;
               SocketConnection.addCmdListener(CommandID.NOTE_UPDATE_PROP,onUpdateProp);
               SocketConnection.addCmdListener(CommandID.NONO_ADD_EXP,onGetExpHandler);
               SocketConnection.send(CommandID.NONO_ADD_EXP);
            },5000);
         }
      }
      
      private function onGetExpHandler(param1:SocketEvent) : void
      {
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:int = int(_loc2_.readUnsignedInt());
         var _loc4_:String = TextFormatUtil.getRedTxt(String(_loc3_));
         var _loc5_:String = TextFormatUtil.getRedTxt(this._petName);
         if(_loc3_ < 1000)
         {
            NpcTipDialog.show("恭喜哟，经过大陆架旋风的作用" + _loc5_ + "增长了" + _loc4_ + "点经验。",this.showUp,NpcTipDialog.NONO,0,this.showUp);
         }
         if(_loc3_ >= 1000 && _loc3_ < 2000)
         {
            NpcTipDialog.show("埋进大陆架旋风，" + _loc5_ + "是最牛的精灵宝宝，吸收了" + _loc4_ + "点经验。",this.showUp,NpcTipDialog.NONO,0,this.showUp);
         }
         if(_loc3_ >= 2000 && _loc3_ < 3000)
         {
            NpcTipDialog.show(" -_- 旋风威力~~~ " + _loc5_ + "增长了" + _loc4_ + "点经验。",this.showUp,NpcTipDialog.NONO,0,this.showUp);
         }
         if(_loc3_ >= 3000)
         {
            NpcTipDialog.show("大陆架能量旋风果然了不得，" + _loc5_ + "完美的吸收能量池的能量，增长了" + _loc4_ + "点经验。",this.showUp,NpcTipDialog.NONO,0,this.showUp);
         }
      }
      
      private function onUpdateProp(param1:SocketEvent) : void
      {
         this._isShow = true;
      }
      
      private function showUp() : void
      {
         if(this._isShow)
         {
            PetUpdatePropController.owner.show(true);
            this._isShow = false;
         }
      }
      
      public function url() : void
      {
         var r:VipSession = new VipSession();
         r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
         {
         });
         r.getSession();
      }
      
      private function onPlantClickHandler(param1:MouseEvent) : void
      {
         if(this._remainTime <= 0)
         {
            NpcTipDialog.show("↖(^ω^)↗我们一定要注意能源的可持续发展哟，明天再来吧！",null,this._npc);
            return;
         }
         if(!MainManager.actorModel.nono)
         {
            NpcTipDialog.show("咦？报告，前方发现珍稀矿产！快点带上你可爱的NoNo来采集吧！",null,NpcTipDialog.NONO);
         }
         else
         {
            NpcTipDialog.show("前方发现珍稀矿产，主人，让我来帮你采集吧！我撞……",this.onHandler,this._npc);
         }
      }
      
      private function onHandler() : void
      {
         this._info = MainManager.actorModel.nono.info;
         MainManager.actorModel.hideNono();
         this._plantMc.buttonMode = false;
         this._plantMc.removeEventListener(MouseEvent.CLICK,this.onPlantClickHandler);
         DisplayUtil.FillColor(this._nonoMc,NonoManager.info.color);
         this._nonoMc.gotoAndPlay(2);
         this._nonoMc.addEventListener(Event.ENTER_FRAME,this.onNonoEnterHandler);
      }
      
      private function onNonoEnterHandler(param1:Event) : void
      {
         if(this._nonoMc.currentFrame == this._nonoMc.totalFrames)
         {
            ++this._hitTimer;
            if(this._hitTimer < 5)
            {
               this._nonoMc.gotoAndPlay(2);
               this._plantMc.gotoAndStop(this._hitTimer);
            }
            else
            {
               this._plantMc.gotoAndStop(5);
               this._nonoMc.removeEventListener(Event.ENTER_FRAME,this.onNonoEnterHandler);
               this._nonoMc.gotoAndStop(1);
               LevelManager.closeMouseEvent();
               SocketConnection.addCmdListener(CommandID.TALK_CATE,this.onGetSuccessHandler);
               SocketConnection.send(CommandID.TALK_CATE,this._type);
            }
         }
      }
      
      private function onGetSuccessHandler(param1:SocketEvent) : void
      {
         --this._remainTime;
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onGetSuccessHandler);
         NpcTipDialog.show("盐质结晶清除完毕，主人主人，那是珍贵" + TextFormatUtil.getRedTxt("希欧珊瑚") + "哦！快点收起来吧！",this.onGetStoHandler,this._npc,0,this.onGetStoHandler);
      }
      
      private function onGetStoHandler() : void
      {
         LevelManager.openMouseEvent();
         var _loc1_:uint = 1;
         if(MainManager.actorInfo.superNono)
         {
            _loc1_ = 2;
         }
         ItemInBagAlert.show(400026,_loc1_ + "块" + TextFormatUtil.getRedTxt("希欧珊瑚") + "已经放入你的储存箱中！");
         MainManager.actorModel.showNono(this._info,MainManager.actorInfo.actionType);
      }
      
      override public function destroy() : void
      {
         if(!MainManager.actorModel.nono)
         {
            MainManager.actorModel.showNono(this._info,MainManager.actorInfo.actionType);
         }
         if(Boolean(this._plantMc))
         {
            ToolTipManager.remove(this._plantMc);
            this._plantMc.removeEventListener(MouseEvent.CLICK,this.onPlantClickHandler);
         }
         if(Boolean(this._nonoMc))
         {
            this._nonoMc.removeEventListener(Event.ENTER_FRAME,this.onNonoEnterHandler);
            this._nonoMc = null;
         }
         SocketConnection.removeCmdListener(CommandID.TALK_CATE,this.onGetSuccessHandler);
         SocketConnection.removeCmdListener(CommandID.TALK_COUNT,this.onGetCountHandler);
         SocketConnection.removeCmdListener(CommandID.NOTE_UPDATE_PROP,this.onUpdateProp);
         SocketConnection.removeCmdListener(CommandID.NONO_ADD_EXP,this.onGetExpHandler);
         if(Boolean(this._wendyMc))
         {
            this._wendyMc.removeEventListener(MouseEvent.CLICK,this.onWendyClickHandler);
            ToolTipManager.remove(this._wendyMc);
         }
         if(Boolean(this._petMc))
         {
            DisplayUtil.removeForParent(this._petMc);
            this._petMc = null;
         }
         if(Boolean(this._appModel))
         {
            this._appModel.destroy();
            this._appModel = null;
         }
         if(Boolean(this._lightMc))
         {
            this._lightMc.removeEventListener(MouseEvent.MOUSE_OVER,this.onLightOverHandler);
            this._lightMc.removeEventListener(MouseEvent.MOUSE_OUT,this.onLightOutHandler);
            this._lightMc.removeEventListener(MouseEvent.CLICK,this.onLightClickHandler);
         }
      }
   }
}

