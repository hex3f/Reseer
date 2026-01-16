package com.robot.app.petGene
{
   import com.robot.app.panel.PetChoosePanel;
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.controller.GetPetController;
   import com.robot.core.event.*;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.CommonUI;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PetGenePanel extends Sprite
   {
      
      private var _mainUI:MovieClip;
      
      private var _closeBtn:SimpleButton;
      
      private var _choose1Btn:SimpleButton;
      
      private var _choose2Btn:SimpleButton;
      
      private var _sureBtn:SimpleButton;
      
      private var _dragBtn:SimpleButton;
      
      private var app:ApplicationDomain;
      
      private var _mainPetInfo:PetInfo;
      
      private var _subPetInfo:PetInfo;
      
      private var _mainPet:MovieClip;
      
      private var _subPet:MovieClip;
      
      private var _main_NameTxt:TextField;
      
      private var _main_dvTxt:TextField;
      
      private var _main_DnaTxt:TextField;
      
      private var _sub_NameTxt:TextField;
      
      private var _sub_dvTxt:TextField;
      
      private var _sub_DnaTxt:TextField;
      
      private var des1:String = "<font color=\'#ffff00\'>";
      
      private var des2:String = "</font>";
      
      public function PetGenePanel()
      {
         super();
      }
      
      public function setup(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this._mainUI = new (this.app.getDefinition("GeneMc") as Class)() as MovieClip;
         addChild(this._mainUI);
         CommonUI.setEnabled(this._mainUI["surebtn"],false);
         CommonUI.setEnabled(this._mainUI["choose2btn"],false);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(this);
         this._choose1Btn = this._mainUI["choose1btn"];
         this._choose2Btn = this._mainUI["choose2btn"];
         this._closeBtn = this._mainUI["closebtn"];
         this._sureBtn = this._mainUI["surebtn"];
         this._dragBtn = this._mainUI["drag"];
         this._mainPet = this._mainUI["mainpet"] as MovieClip;
         this._subPet = this._mainUI["subpet"] as MovieClip;
         this._main_NameTxt = this._mainUI["main_name"];
         this._main_dvTxt = this._mainUI["main_dv"];
         this._main_DnaTxt = this._mainUI["main_dna"];
         this._sub_NameTxt = this._mainUI["sub_name"];
         this._sub_dvTxt = this._mainUI["sub_dv"];
         this._sub_DnaTxt = this._mainUI["sub_dna"];
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.onClose);
         this._choose1Btn.addEventListener(MouseEvent.CLICK,this.onChoose1Btn);
         this._choose2Btn.addEventListener(MouseEvent.CLICK,this.onChoose2Btn);
         this._sureBtn.addEventListener(MouseEvent.CLICK,this.onSureBtn);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onDragDown);
         this._dragBtn.addEventListener(MouseEvent.MOUSE_UP,this.onDragUp);
      }
      
      private function onDragDown(param1:MouseEvent) : void
      {
         this._mainUI.startDrag();
      }
      
      private function onDragUp(param1:MouseEvent) : void
      {
         this._mainUI.stopDrag();
      }
      
      private function showPet(param1:uint, param2:uint) : void
      {
         var monID:uint = param1;
         var captTm:uint = param2;
         ResourceManager.getResource(ClientConfig.getPetSwfPath(monID),function(param1:MovieClip):void
         {
            var m:MovieClip = param1;
            m.gotoAndStop("rightdown");
            m.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = m.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  m.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               }
            });
            DisplayUtil.stopAllMovieClip(m);
            LevelManager.topLevel.addChild(m);
            DisplayUtil.align(m,null,AlignType.MIDDLE_CENTER);
            setTimeout(function():void
            {
               DisplayUtil.removeForParent(m);
               m = null;
               MainManager.actorInfo.obtainTm = 0;
               GetPetController.getPet(monID,captTm);
            },1500);
         },"pet");
      }
      
      private function onSureBtn(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         this._mainUI.mouseEnabled = false;
         this._mainUI.mouseChildren = false;
         if(MainManager.actorInfo.coins < 5000)
         {
            Alarm.show("基因重组需要花费5000赛尔豆,你的赛尔豆不够哦！",function():void
            {
               _mainUI.mouseEnabled = true;
               _mainUI.mouseChildren = true;
            });
         }
         else
         {
            Alert.show("基因重组需要花费5000赛尔豆，确定要开始重组吗？",function():void
            {
               CommonUI.setEnabled(_choose1Btn,false);
               CommonUI.setEnabled(_choose2Btn,false);
               CommonUI.setEnabled(_sureBtn,false);
               SocketConnection.addCmdListener(CommandID.PET_GENE_RECAST,function(param1:SocketEvent):void
               {
                  var data:ByteArray;
                  var flag:uint;
                  var newPetId:uint = 0;
                  var newPetCatchTime:uint = 0;
                  var mc:MovieClip = null;
                  var event:SocketEvent = param1;
                  var e:SocketEvent = event;
                  destroy();
                  SocketConnection.removeCmdListener(CommandID.PET_GENE_RECAST,arguments.callee);
                  MainManager.actorInfo.coins -= 5000;
                  data = e.data as ByteArray;
                  flag = data.readUnsignedInt();
                  if(flag == 0)
                  {
                     Alarm.show("基因重组失败,消耗5000赛尔豆！");
                     destroy();
                     return;
                  }
                  PetManager.deletePet(_mainPetInfo.catchTime);
                  PetManager.deletePet(_subPetInfo.catchTime);
                  newPetId = data.readUnsignedInt();
                  newPetCatchTime = data.readUnsignedInt();
                  mc = new (app.getDefinition("SBdToPetMC") as Class)() as MovieClip;
                  LevelManager.topLevel.addChild(mc);
                  DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
                  mc["mc"].gotoAndPlay(2);
                  mc["mc"].addEventListener(Event.ENTER_FRAME,function(param1:Event):void
                  {
                     if(mc["mc"].currentFrame == mc["mc"].totalFrames)
                     {
                        mc["mc"].removeEventListener(Event.ENTER_FRAME,arguments.callee);
                        DisplayUtil.removeForParent(mc);
                        showPet(newPetId,newPetCatchTime);
                     }
                  });
               });
               SocketConnection.send(CommandID.PET_GENE_RECAST,_mainPetInfo.catchTime,_subPetInfo.catchTime);
            },function():void
            {
               _mainUI.mouseEnabled = true;
               _mainUI.mouseChildren = true;
            });
         }
      }
      
      private function onChoose2Btn(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         if(PetManager.infos.some(function(param1:PetInfo, param2:int, param3:Array):Boolean
         {
            if(PetXMLInfo.getPetClass(param1.id) == 119 || param1.id == 315)
            {
               if(param1.catchTime == _mainPetInfo.catchTime)
               {
                  return false;
               }
               return true;
            }
            return false;
         }) == false)
         {
            Alarm.show("你的精灵背包中没有可以参与基因重组的精灵哦！");
            return;
         }
         this._mainUI.mouseEnabled = false;
         this._mainUI.mouseChildren = false;
         PetChoosePanel.show(function(param1:PetInfo):void
         {
            if(param1.catchTime == _mainPetInfo.catchTime)
            {
               _mainUI.mouseEnabled = true;
               _mainUI.mouseChildren = true;
               Alarm.show("选择的精灵不能与主宠相同！");
               return;
            }
            if(Boolean(_subPetInfo))
            {
               ResourceManager.cancelURL(ClientConfig.getPetSwfPath(_subPetInfo.id));
            }
            _subPetInfo = param1;
            loadPet(_subPetInfo.id,_subPet,"leftdown");
            CommonUI.setEnabled(_sureBtn,true);
            _mainUI.mouseEnabled = true;
            _mainUI.mouseChildren = true;
            var _loc2_:String = "";
            var _loc3_:Array = ["<font color=\'#00ff00\' size=\'15\'>","<font color=\'#0000ff\' size=\'15\'>","<font color=\'#800080\' size=\'15\'>","<font color=\'#ffd700\' size=\'15\'>","<font color=\'#ff0000\' size=\'15\'>"];
            var _loc4_:int = 4;
            while(_loc4_ >= 0)
            {
               if(Boolean(_subPetInfo.dv >> _loc4_ & 1))
               {
                  _loc2_ += _loc3_[_loc4_] + "◆" + des2;
               }
               else
               {
                  _loc2_ += "<font color=\'#000000\' size=\'15\'>" + "◇" + des2;
               }
               _loc4_--;
            }
            _sub_NameTxt.htmlText = des1 + "名字:" + PetXMLInfo.getName(_subPetInfo.id) + des2;
            _sub_dvTxt.htmlText = des1 + "个体:" + _subPetInfo.dv.toString() + des2;
            _sub_DnaTxt.htmlText = _loc2_;
         },function():void
         {
            _mainUI.mouseEnabled = true;
            _mainUI.mouseChildren = true;
         },function(param1:PetInfo):Boolean
         {
            if(PetXMLInfo.getPetClass(param1.id) == 119 || param1.id == 315)
            {
               if(param1.catchTime == _mainPetInfo.catchTime)
               {
                  return false;
               }
               return true;
            }
            return false;
         });
      }
      
      private function onChoose1Btn(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         if(PetManager.infos.some(function(param1:PetInfo, param2:int, param3:Array):Boolean
         {
            if(PetXMLInfo.getEvolvesTo(param1.id) == 0)
            {
               return true;
            }
            return false;
         }) == false)
         {
            Alarm.show("你的精灵背包中没有可以参与基因重组的精灵哦！");
            return;
         }
         this._mainUI.mouseEnabled = false;
         this._mainUI.mouseChildren = false;
         PetChoosePanel.show(function(param1:PetInfo):void
         {
            if(Boolean(_mainPetInfo) && _mainPetInfo.catchTime != param1.catchTime)
            {
               _subPetInfo = null;
               DisplayUtil.removeAllChild(_subPet);
               CommonUI.setEnabled(_sureBtn,false);
            }
            if(Boolean(_mainPetInfo))
            {
               ResourceManager.cancelURL(ClientConfig.getPetSwfPath(_mainPetInfo.id));
            }
            _mainPetInfo = param1;
            loadPet(_mainPetInfo.id,_mainPet,"rightdown");
            CommonUI.setEnabled(_choose2Btn,true);
            _mainUI.mouseEnabled = true;
            _mainUI.mouseChildren = true;
            var _loc2_:String = "";
            var _loc3_:Array = ["<font color=\'#00ff00\' size=\'15\'>","<font color=\'#0000ff\' size=\'15\'>","<font color=\'#800080\' size=\'15\'>","<font color=\'#ffd700\' size=\'15\'>","<font color=\'#ff0000\' size=\'15\'>"];
            var _loc4_:int = 4;
            while(_loc4_ >= 0)
            {
               if(Boolean(_mainPetInfo.dv >> _loc4_ & 1))
               {
                  _loc2_ += _loc3_[_loc4_] + "◆" + des2;
               }
               else
               {
                  _loc2_ += "<font color=\'#000000\' size=\'15\'>" + "◇" + des2;
               }
               _loc4_--;
            }
            _main_NameTxt.htmlText = des1 + "名字:" + PetXMLInfo.getName(_mainPetInfo.id) + des2;
            _main_dvTxt.htmlText = des1 + "个体:" + _mainPetInfo.dv.toString() + des2;
            _main_DnaTxt.htmlText = _loc2_;
         },function():void
         {
            _mainUI.mouseEnabled = true;
            _mainUI.mouseChildren = true;
         },function(param1:PetInfo):Boolean
         {
            if(PetXMLInfo.getEvolvesTo(param1.id) == 0)
            {
               return true;
            }
            return false;
         });
      }
      
      private function loadPet(param1:uint, param2:MovieClip, param3:String) : void
      {
         var con:MovieClip = null;
         var direction:String = null;
         var id:uint = param1;
         con = param2;
         direction = param3;
         DisplayUtil.removeAllChild(con);
         ResourceManager.getResource(ClientConfig.getPetSwfPath(id),function(param1:DisplayObject):void
         {
            var pet:MovieClip = null;
            pet = null;
            var o:DisplayObject = param1;
            pet = null;
            pet = o as MovieClip;
            con.addChild(pet);
            pet.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = pet.getChildAt(0) as MovieClip;
               if(Boolean(_loc2_))
               {
                  _loc2_.gotoAndStop(1);
                  pet.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  CommonUI.equalScale(pet,110,150);
                  CommonUI.centerAlign(pet,con,new Point(0,0));
               }
            });
            pet.gotoAndStop(direction);
         },"pet");
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
      
      public function destroy() : void
      {
         if(Boolean(this._mainUI))
         {
            DisplayUtil.removeAllChild(this._mainUI);
            DisplayUtil.removeForParent(this._mainUI);
         }
         this._mainUI = null;
         this._closeBtn = null;
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         if(this._mainUI == null)
         {
            _loc1_ = new MCLoader(ClientConfig.getAppModule("PetGenePanel"),this,1,"正在打开基因重组器...");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.setup);
            _loc1_.doLoad();
         }
         else
         {
            DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(this._mainUI);
         }
      }
   }
}

