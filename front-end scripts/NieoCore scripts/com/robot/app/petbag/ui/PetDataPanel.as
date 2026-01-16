package com.robot.app.petbag.ui
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.NatureXMLInfo;
   import com.robot.core.config.xml.PetEffectXMLInfo;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.pet.PetEffectInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.manager.UIManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.pet.PetGenderIconManager;
   import com.robot.core.ui.skillBtn.NormalSkillBtn;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   import org.taomee.utils.StringUtil;
   
   public class PetDataPanel
   {
      
      private static const MAX:int = 4;
      
      private var skillBtnArray:Array = [];
      
      private var _mainUI:Sprite;
      
      private var _numTxt:TextField;
      
      private var _nameTxt:TextField;
      
      private var _levelTxt:TextField;
      
      private var _dvTxt:TextField;
      
      private var _upExpTxt:TextField;
      
      private var _charaTxt:TextField;
      
      private var _effectTxt:TextField;
      
      private var _getTimeTxt:TextField;
      
      private var _showMc:MovieClip;
      
      private var _attackTxt:TextField;
      
      private var _defenceTxt:TextField;
      
      private var _saTxt:TextField;
      
      private var _sdTxt:TextField;
      
      private var _speedTxt:TextField;
      
      private var _hpTxt:TextField;
      
      private var ev_attackTxt:TextField;
      
      private var ev_defenceTxt:TextField;
      
      private var ev_saTxt:TextField;
      
      private var ev_sdTxt:TextField;
      
      private var ev_speedTxt:TextField;
      
      private var ev_hpTxt:TextField;
      
      private var _id:uint;
      
      private var _petInfo:PetInfo;
      
      private var attMc:SimpleButton;
      
      private var _generIcon:MovieClip;
      
      private var des1:String = "<font color=\'#ffff00\'>";
      
      private var des3:String = "<font color=\'#ff0000\'>";
      
      private var des2:String = "</font>";
      
      public function PetDataPanel(param1:Sprite)
      {
         super();
         this._mainUI = param1;
         this._numTxt = this._mainUI["numTxt"];
         this._nameTxt = this._mainUI["nameTxt"];
         this._levelTxt = this._mainUI["levelTxt"];
         this._dvTxt = this._mainUI["dvTxt"];
         this._upExpTxt = this._mainUI["upExpTxt"];
         this._charaTxt = this._mainUI["charaTxt"];
         this._effectTxt = this._mainUI["effectTxt"];
         this._getTimeTxt = this._mainUI["getTimeTxt"];
         this._attackTxt = this._mainUI["attackTxt"];
         this._defenceTxt = this._mainUI["defenceTxt"];
         this._saTxt = this._mainUI["saTxt"];
         this._sdTxt = this._mainUI["sdTxt"];
         this._speedTxt = this._mainUI["speedTxt"];
         this._hpTxt = this._mainUI["hpTxt"];
         this.ev_attackTxt = this._mainUI["ev_attackTxt"];
         this.ev_defenceTxt = this._mainUI["ev_defenceTxt"];
         this.ev_saTxt = this._mainUI["ev_saTxt"];
         this.ev_sdTxt = this._mainUI["ev_sdTxt"];
         this.ev_speedTxt = this._mainUI["ev_speedTxt"];
         this.ev_hpTxt = this._mainUI["ev_hpTxt"];
         this._generIcon = this._mainUI["gener_icon"];
         this._generIcon.visible = false;
         this.addEffectBg();
         var _loc2_:Number = 0;
         while(_loc2_ < 6)
         {
            ToolTipManager.add(this._mainUI["icon_" + _loc2_],"学习力");
            _loc2_++;
         }
         SocketConnection.addCmdListener(CommandID.EAT_SPECIAL_MEDICINE,this.onEatSplItem);
      }
      
      public function clearInfo() : void
      {
         this._numTxt.text = "";
         this._nameTxt.text = "";
         this._levelTxt.text = "";
         this._dvTxt.text = "";
         this._upExpTxt.text = "";
         this._charaTxt.text = "";
         this._getTimeTxt.text = "";
         this._attackTxt.text = "";
         this._defenceTxt.text = "";
         this._saTxt.text = "";
         this._sdTxt.text = "";
         this._speedTxt.text = "";
         this._hpTxt.text = "";
         ToolTipManager.remove(this._charaTxt);
         this._effectTxt.text = "";
         ToolTipManager.remove(this._effectTxt);
         if(this._id != 0)
         {
            ResourceManager.cancel(ClientConfig.getPetSwfPath(this._petInfo.skinID != 0 ? uint(this._petInfo.skinID) : uint(this._id)),this.onShowComplete);
         }
         if(Boolean(this._showMc))
         {
            DisplayUtil.removeForParent(this._showMc);
            this._showMc = null;
         }
         if(Boolean(this.skillBtnArray))
         {
            this.clearOldBtn();
         }
         PetGenderIconManager.hideIcon(this._mainUI);
      }
      
      public function show(param1:PetInfo) : void
      {
         var bit:int;
         var effectInfo:PetEffectInfo;
         var highlightDefence:Boolean;
         var highlightSd:Boolean;
         var highlightAttack:Boolean;
         var highlightSa:Boolean;
         var highlightSpeed:Boolean;
         var k:int;
         var i:int;
         var itemid:uint = 0;
         var info:PetInfo = param1;
         var skillBtn:NormalSkillBtn = null;
         var str:String = "";
         var s:Array = ["<font color=\'#00ff00\' size=\'18\'>","<font color=\'#0000ff\' size=\'18\'>","<font color=\'#800080\' size=\'18\'>","<font color=\'#ffd700\' size=\'18\'>","<font color=\'#ff0000\' size=\'18\'>"];
         this._petInfo = info;
         if(this._petInfo.generation > 0)
         {
            this._generIcon.visible = true;
         }
         else
         {
            this._generIcon.visible = false;
         }
         bit = 4;
         while(bit >= 0)
         {
            if(Boolean(info.dv >> bit & 1))
            {
               str += s[bit] + "◆" + this.des2;
            }
            else
            {
               str += "<font color=\'#000000\' size=\'18\'>" + "◇" + this.des2;
            }
            bit--;
         }
         this._numTxt.htmlText = "序号:" + this.des1 + StringUtil.renewZero(info.id.toString(),3) + this.des2;
         this._nameTxt.htmlText = "名字:" + this.des1 + PetXMLInfo.getName(info.id) + this.des2;
         this._levelTxt.htmlText = "等级:" + this.des1 + info.level.toString() + this.des2;
         this._dvTxt.htmlText = "个体:" + this.des1 + info.dv.toString() + this.des2;
         ToolTipManager.add(this._dvTxt,str);
         this._upExpTxt.htmlText = "升级所需经验值:" + this.des1 + (info.nextLvExp - info.exp).toString() + this.des2;
         effectInfo = info.effectList[0];
         this._charaTxt.htmlText = "性格:" + this.des1 + NatureXMLInfo.getName(info.nature) + this.des2;
         ToolTipManager.remove(this._charaTxt);
         ToolTipManager.add(this._charaTxt,NatureXMLInfo.getDesc(info.nature));
         ToolTipManager.remove(this._effectTxt);
         this._effectTxt.htmlText = "";
         if(Boolean(effectInfo))
         {
            if(effectInfo.itemId > 1005 && effectInfo.itemId <= 1045)
            {
               this._effectTxt.htmlText = "特性:" + this.des1 + PetEffectXMLInfo.getEffect(effectInfo.itemId) + this.des2;
               ToolTipManager.add(this._effectTxt,PetEffectXMLInfo.getDes2(effectInfo.itemId));
            }
         }
         else
         {
            this._effectTxt.htmlText = "";
         }
         this._getTimeTxt.htmlText = "获得时间:" + this.des1 + StringUtil.timeFormat(info.catchTime) + this.des2;
         this.showIcon(info.effectList.filter(function(param1:PetEffectInfo, param2:int, param3:Array):Boolean
         {
            return param1.status == 2;
         },info.effectList));
         if(Boolean(this.attMc))
         {
            DisplayUtil.removeForParent(this.attMc);
            this.attMc = null;
         }
         this.attMc = UIManager.getButton("Icon_PetType_" + PetXMLInfo.getType(info.id));
         if(Boolean(this.attMc))
         {
            this.attMc.x = this._nameTxt.x + this._nameTxt.textWidth + 10;
            this.attMc.y = this._nameTxt.y;
            DisplayUtil.uniformScale(this.attMc,20);
            this._mainUI.addChild(this.attMc);
            PetGenderIconManager.addIcon(this._mainUI,new Point(this.attMc.x + 20,this.attMc.y),PetXMLInfo.getPetGender(this._petInfo.id));
         }
         else
         {
            PetGenderIconManager.hideIcon(this._mainUI);
         }
         if(this._id != 0)
         {
            ResourceManager.cancel(ClientConfig.getPetSwfPath(this._petInfo.skinID != 0 ? uint(this._petInfo.skinID) : uint(this._id)),this.onShowComplete);
         }
         if(Boolean(this._showMc))
         {
            DisplayUtil.removeForParent(this._showMc);
            this._showMc = null;
         }
         this._id = info.id;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this._petInfo.skinID != 0 ? uint(this._petInfo.skinID) : uint(this._id)),this.onShowComplete,"pet");
         highlightDefence = false;
         highlightSd = false;
         highlightAttack = false;
         highlightSa = false;
         highlightSpeed = false;
         k = 0;
         while(k < info.effectList.length)
         {
            itemid = uint(info.effectList[k].itemId);
            highlightDefence ||= itemid == 300030 || itemid == 300045;
            highlightSd ||= itemid == 300031 || itemid == 300046;
            highlightAttack ||= itemid == 300032 || itemid == 300047;
            highlightSa ||= itemid == 300033 || itemid == 300048;
            highlightSpeed ||= itemid == 300034 || itemid == 300049;
            k++;
         }
         this._attackTxt.htmlText = "攻击:" + (highlightAttack ? this.des3 : this.des1) + info.attack.toString() + this.des2;
         this._defenceTxt.htmlText = "防御:" + (highlightDefence ? this.des3 : this.des1) + info.defence.toString() + this.des2;
         this._saTxt.htmlText = "特攻:" + (highlightSa ? this.des3 : this.des1) + info.s_a.toString() + this.des2;
         this._sdTxt.htmlText = "特防:" + (highlightSd ? this.des3 : this.des1) + info.s_d.toString() + this.des2;
         this._speedTxt.htmlText = "速度:" + (highlightSpeed ? this.des3 : this.des1) + info.speed.toString() + this.des2;
         this._hpTxt.htmlText = "体力:" + this.des1 + info.hp.toString() + this.des2;
         this.ev_attackTxt.htmlText = this.des1 + info.ev_attack.toString() + this.des2;
         this.ev_defenceTxt.htmlText = this.des1 + info.ev_defence.toString() + this.des2;
         this.ev_saTxt.htmlText = this.des1 + info.ev_sa.toString() + this.des2;
         this.ev_sdTxt.htmlText = this.des1 + info.ev_sd.toString() + this.des2;
         this.ev_speedTxt.htmlText = this.des1 + info.ev_sp.toString() + this.des2;
         this.ev_hpTxt.htmlText = this.des1 + info.ev_hp.toString() + this.des2;
         this.clearOldBtn();
         i = 0;
         while(i < MAX)
         {
            if(i < info.skillNum)
            {
               skillBtn = new NormalSkillBtn(info.skillArray[i].id,info.skillArray[i].pp);
            }
            else
            {
               skillBtn = new NormalSkillBtn();
            }
            skillBtn.x = 18 + (skillBtn.width + 10) * (i % 2);
            skillBtn.y = 218 + (skillBtn.height + 8) * Math.floor(i / 2);
            this.skillBtnArray.push(skillBtn);
            this._mainUI.addChild(skillBtn);
            i++;
         }
         this._mainUI.visible = true;
      }
      
      private function addEffectBg() : void
      {
         var _loc1_:PetEffectIcon = null;
         var _loc2_:int = 0;
         while(_loc2_ < 5)
         {
            _loc1_ = new PetEffectIcon();
            _loc1_.name = "icon" + _loc2_;
            this._mainUI.addChild(_loc1_);
            _loc1_.x = 7 + (_loc1_.width + 3) * _loc2_;
            _loc1_.y = 116;
            _loc2_++;
         }
      }
      
      private function showIcon(param1:Array) : void
      {
         var _loc2_:PetEffectIcon = null;
         var _loc3_:int = 0;
         while(_loc3_ < 5)
         {
            _loc2_ = this._mainUI.getChildByName("icon" + _loc3_) as PetEffectIcon;
            _loc2_.clear();
            if(_loc3_ < param1.length)
            {
               _loc2_.show(param1[_loc3_] as PetEffectInfo);
            }
            _loc3_++;
         }
      }
      
      private function clearOldBtn() : void
      {
         var _loc1_:NormalSkillBtn = null;
         for each(_loc1_ in this.skillBtnArray)
         {
            _loc1_.destroy();
            _loc1_ = null;
         }
         this.skillBtnArray = [];
      }
      
      public function hide() : void
      {
         this._mainUI.visible = false;
      }
      
      private function onShowComplete(param1:DisplayObject) : void
      {
         this._showMc = param1 as MovieClip;
         if(Boolean(this._showMc))
         {
            DisplayUtil.stopAllMovieClip(this._showMc);
            this._showMc.scaleX = 1.5;
            this._showMc.scaleY = 1.5;
            this._showMc.x = 70;
            this._showMc.y = 110;
            this._mainUI.addChild(this._showMc);
         }
      }
      
      private function onEatSplItem(param1:SocketEvent) : void
      {
         var evt:SocketEvent = param1;
         SocketConnection.addCmdListener(CommandID.GET_PET_INFO,function(param1:SocketEvent):void
         {
            SocketConnection.removeCmdListener(CommandID.GET_PET_INFO,arguments.callee);
            PetManager.upDate();
         });
         SocketConnection.send(CommandID.GET_PET_INFO,this._petInfo.catchTime);
      }
   }
}

