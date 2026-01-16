package com.robot.app.picturebook.ui
{
   import com.robot.app.picturebook.info.*;
   import com.robot.core.*;
   import com.robot.core.config.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.pet.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.uic.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.media.*;
   import flash.net.*;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.*;
   import org.taomee.utils.*;
   
   public class PictureBookPanel extends UIPanel
   {
      
      private static const LIST_LENGTH:int = 10;
      
      private const STXT:String = "输入ID或名称";
      
      private const PATH_STR:String = "resource/pet/sound/";
      
      private var DIR_A:Array;
      
      private var _stxt:TextField;
      
      private var _ptxt:TextField;
      
      private var _showMc:MovieClip;
      
      private var _searchTxt:TextField;
      
      private var _searchBtn:SimpleButton;
      
      private var _listCon:Sprite;
      
      private var _leftBtn:SimpleButton;
      
      private var _rightBtn:SimpleButton;
      
      private var _dataList:Array;
      
      private var _len:int;
      
      private var _showMap:HashMap;
      
      private var _scrollBar:UIScrollBar;
      
      private var _soundBtn:SimpleButton;
      
      private var _sound:Sound;
      
      private var _soundC:SoundChannel;
      
      private var _url:String = "";
      
      private var _petId:uint;
      
      private var _index:uint;
      
      public function PictureBookPanel()
      {
         var _loc1_:PictureBookListItem = null;
         var _loc2_:int = 0;
         this.DIR_A = [];
         this._showMap = new HashMap();
         this.DIR_A = [Direction.DOWN,Direction.LEFT_DOWN,Direction.LEFT_UP,Direction.UP,Direction.RIGHT_UP,Direction.RIGHT_DOWN];
         super(UIManager.getSprite("PictureBookMc"));
         this._stxt = _mainUI["stxt"];
         this._ptxt = _mainUI["ptxt"];
         this._searchTxt = _mainUI["searchTxt"];
         this._searchBtn = _mainUI["searchBtn"];
         this._dataList = PetBookXMLInfo.dataList;
         this._len = this._dataList.length;
         this._leftBtn = _mainUI["leftBtn"];
         this._rightBtn = _mainUI["rightBtn"];
         this._soundBtn = _mainUI["soundBtn"];
         this._listCon = new Sprite();
         this._listCon.x = 322;
         this._listCon.y = 109;
         addChild(this._listCon);
         while(_loc2_ < LIST_LENGTH)
         {
            _loc1_ = new PictureBookListItem();
            _loc1_.index = _loc2_;
            _loc1_.id = _loc2_ + 1;
            _loc1_.text = StringUtil.renewZero(this._dataList[_loc2_].@ID.toString(),3) + ":" + "---";
            _loc1_.y = (_loc1_.height + 1) * _loc2_;
            _loc1_.addEventListener(MouseEvent.CLICK,this.onItemClick);
            this._listCon.addChild(_loc1_);
            _loc2_++;
         }
         this._scrollBar = new UIScrollBar(_mainUI["barBlock"],_mainUI["barBack"],LIST_LENGTH,_mainUI["upBtn"],_mainUI["downBtn"]);
         this._scrollBar.wheelObject = this;
         this.showInfo(this._listCon.getChildAt(0) as PictureBookListItem);
         this._searchTxt.text = this.STXT;
         this._searchTxt.textColor = 16777215;
      }
      
      public function show() : void
      {
         _show();
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(this._url != "")
         {
            ResourceManager.cancel(this._url,this.onLoadRes);
         }
         if(Boolean(this._soundC))
         {
            this._soundC.stop();
            this._soundC = null;
            this._sound = null;
         }
      }
      
      override protected function addEvent() : void
      {
         super.addEvent();
         SocketConnection.addCmdListener(CommandID.PET_BARGE_LIST,this.onPetBarge);
         SocketConnection.send(CommandID.PET_BARGE_LIST,1,this._len);
         this._searchBtn.addEventListener(MouseEvent.CLICK,this.onSearch);
         this._searchTxt.addEventListener(FocusEvent.FOCUS_IN,this.onSFin);
         this._searchTxt.addEventListener(FocusEvent.FOCUS_OUT,this.onSFout);
         this._scrollBar.addEventListener(MouseEvent.MOUSE_MOVE,this.onBarBallMove);
         this._leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRotatePetHandler);
         this._rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRotatePetHandler);
         this._soundBtn.addEventListener(MouseEvent.CLICK,this.onPlaySoundHandler);
      }
      
      private function onPlaySoundHandler(param1:MouseEvent) : void
      {
         if(Boolean(this._soundC))
         {
            this._soundC.stop();
            this._soundC = null;
            this._sound = null;
         }
         this._sound = new Sound();
         this._sound.load(new URLRequest(this.PATH_STR + this._petId + ".mp3"));
         this._soundC = this._sound.play();
      }
      
      private function onRotatePetHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(!this._showMc)
         {
            return;
         }
         this._showMc.removeEventListener(Event.ENTER_FRAME,this.onPetEnterHandler);
         var _loc3_:String = this._showMc.currentLabel;
         var _loc4_:SimpleButton = param1.currentTarget as SimpleButton;
         var _loc5_:uint = uint(this.DIR_A.indexOf(_loc3_));
         if(_loc4_ == this._leftBtn)
         {
            _loc2_ = this.DIR_A[_loc5_ + 1];
            if(_loc5_ + 1 > this.DIR_A.length)
            {
               _loc2_ = this.DIR_A[0];
            }
         }
         else
         {
            _loc2_ = this.DIR_A[_loc5_ - 1];
            if(_loc5_ - 1 < 0)
            {
               _loc2_ = this.DIR_A[this.DIR_A.length - 1];
            }
         }
         this._showMc.gotoAndStop(_loc2_);
         DisplayUtil.stopAllMovieClip(this._showMc);
         this._showMc.addEventListener(Event.ENTER_FRAME,this.onPetEnterHandler);
      }
      
      private function onPetEnterHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = this._showMc.getChildAt(0) as MovieClip;
         if(Boolean(_loc2_))
         {
            this._showMc.removeEventListener(Event.ENTER_FRAME,this.onPetEnterHandler);
            DisplayUtil.stopAllMovieClip(this._showMc);
         }
      }
      
      override protected function removeEvent() : void
      {
         super.removeEvent();
         SocketConnection.removeCmdListener(CommandID.PET_BARGE_LIST,this.onPetBarge);
         this._searchBtn.removeEventListener(MouseEvent.CLICK,this.onSearch);
         this._scrollBar.removeEventListener(MouseEvent.MOUSE_MOVE,this.onBarBallMove);
         this._leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRotatePetHandler);
         this._rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRotatePetHandler);
         this._showMc.removeEventListener(Event.ENTER_FRAME,this.onPetEnterHandler);
         this._soundBtn.removeEventListener(MouseEvent.CLICK,this.onPlaySoundHandler);
      }
      
      private function checkItem(param1:PictureBookListItem) : void
      {
         var _loc2_:PictureBookInfo = this._showMap.getValue(param1.id) as PictureBookInfo;
         if(Boolean(_loc2_))
         {
            param1.isShow = true;
            param1.hasPet(_loc2_.isCacth);
            param1.text = StringUtil.renewZero(param1.id.toString(),3) + ":" + PetBookXMLInfo.getName(param1.id);
         }
         else
         {
            param1.isShow = false;
            param1.hasPet(false);
            param1.text = StringUtil.renewZero(param1.id.toString(),3) + ":" + "— — — —";
         }
      }
      
      private function showInfo(param1:PictureBookListItem) : void
      {
         var _loc2_:String = null;
         if(this._url != "")
         {
            ResourceManager.cancel(this._url,this.onLoadRes);
         }
         this._stxt.text = "";
         this._ptxt.text = "";
         if(Boolean(this._showMc))
         {
            this._showMc.removeEventListener(Event.ENTER_FRAME,this.onPetEnterHandler);
            DisplayUtil.removeForParent(this._showMc);
            this._showMc = null;
         }
         this._petId = param1.id;
         if(param1.isShow)
         {
            this._stxt.htmlText = StringUtil.renewZero(param1.id.toString(),3) + ":" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getName(param1.id) + "</font>\n";
            this._stxt.htmlText += "属性:" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getType(param1.id) + "</font>\n";
            this._stxt.htmlText += "身高:" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getHeight(param1.id) + " cm" + "</font>\n";
            this._stxt.htmlText += "体重:" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getWeight(param1.id) + " kg" + "</font>\n";
            this._stxt.htmlText += "分布:" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getFoundin(param1.id) + "</font>\n";
            this._stxt.htmlText += "喜欢的食物:" + "<font color=\'#ffff00\'>" + PetBookXMLInfo.food(param1.id) + "</font>\n";
            if(PetBookXMLInfo.hasSound(param1.id))
            {
               this._stxt.htmlText += "声音:";
               this._soundBtn.visible = true;
            }
            else
            {
               this._soundBtn.visible = false;
            }
            this._ptxt.htmlText = "精灵简介:\n    " + "<font color=\'#ffff00\'>" + PetBookXMLInfo.getFeatures(param1.id) + "</font>\n";
            this._url = ClientConfig.getPetSwfPath(param1.id);
         }
         else
         {
            this._soundBtn.visible = false;
            _loc2_ = "<font color=\'#ffff00\'>" + "？？？" + "</font>\n";
            this._stxt.htmlText = StringUtil.renewZero(param1.id.toString(),3) + ":" + _loc2_ + "\n";
            this._stxt.htmlText += "属性:" + _loc2_ + "\n";
            this._stxt.htmlText += "身高:" + _loc2_ + "\n";
            this._stxt.htmlText += "体重:" + _loc2_ + "\n";
            this._stxt.htmlText += "分布:" + _loc2_ + "\n";
            this._ptxt.htmlText += "精灵简介:\n    " + _loc2_;
            this._url = ClientConfig.getPetSwfPath(0);
         }
         ResourceManager.getResource(this._url,this.onLoadRes,"pet");
      }
      
      private function onLoadRes(param1:DisplayObject) : void
      {
         this._showMc = param1 as MovieClip;
         this._showMc.x = 92;
         this._showMc.y = 150;
         this._showMc.scaleX = 2;
         this._showMc.scaleY = 2;
         _mainUI.addChildAt(this._showMc,_mainUI.getChildIndex(this._rightBtn));
         _mainUI.addChildAt(this._showMc,_mainUI.getChildIndex(this._leftBtn));
         MovieClipUtil.childStop(this._showMc,1);
         DisplayUtil.stopAllMovieClip(this._showMc);
      }
      
      private function onBarBallMove(param1:MouseEvent) : void
      {
         var _loc2_:PictureBookListItem = null;
         var _loc3_:int = 0;
         while(_loc3_ < LIST_LENGTH)
         {
            _loc2_ = this._listCon.getChildAt(_loc3_) as PictureBookListItem;
            _loc2_.id = _loc3_ + this._scrollBar.index + 1;
            _loc2_.index = _loc3_ + this._scrollBar.index;
            this.checkItem(_loc2_);
            _loc3_++;
         }
      }
      
      private function onPetBarge(param1:SocketEvent) : void
      {
         var _loc2_:PictureBookInfo = null;
         var _loc3_:PictureBookListItem = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         SocketConnection.removeCmdListener(CommandID.PET_BARGE_LIST,this.onPetBarge);
         this._showMap.clear();
         var _loc4_:ByteArray = (param1.data as PetBargeListInfo).data;
         var _loc5_:uint = _loc4_.readUnsignedInt();
         while(_loc6_ < _loc5_)
         {
            _loc2_ = new PictureBookInfo(_loc4_);
            this._showMap.add(_loc2_.id,_loc2_);
            _loc6_++;
         }
         this._scrollBar.totalLength = this._len;
         while(_loc7_ < LIST_LENGTH)
         {
            _loc3_ = this._listCon.getChildAt(_loc7_) as PictureBookListItem;
            this.checkItem(_loc3_);
            _loc7_++;
         }
      }
      
      private function onItemClick(param1:MouseEvent) : void
      {
         var _loc2_:PictureBookListItem = param1.currentTarget as PictureBookListItem;
         this.showInfo(_loc2_);
      }
      
      public function serachId(param1:int) : void
      {
         var _loc2_:XML = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:PictureBookListItem = null;
         var _loc7_:PictureBookListItem = null;
         var _loc8_:int = param1;
         var _loc9_:int = -1;
         if(Boolean(_loc8_))
         {
            param1 = 0;
            while(true)
            {
               if(param1 < this._len)
               {
                  _loc2_ = this._dataList[param1] as XML;
                  if(int(_loc2_.@ID) != _loc8_)
                  {
                     continue;
                  }
                  _loc9_ = int(_loc2_.@ID) - 1;
               }
               param1++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < this._len)
            {
               _loc2_ = this._dataList[_loc3_] as XML;
               if(String(_loc2_.@DefName) == this._searchTxt.text)
               {
                  _loc9_ = int(_loc2_.@ID) - 1;
                  break;
               }
               _loc3_++;
            }
         }
         if(_loc9_ != -1)
         {
            if(_loc9_ >= LIST_LENGTH)
            {
               _loc5_ = 0;
               while(_loc5_ < LIST_LENGTH)
               {
                  _loc6_ = this._listCon.getChildAt(_loc5_) as PictureBookListItem;
                  _loc6_.id = _loc5_ + _loc9_ - _loc9_ % LIST_LENGTH + 1;
                  _loc6_.index = _loc5_ + _loc9_ - _loc9_ % LIST_LENGTH;
                  this.checkItem(_loc6_);
                  _loc5_++;
               }
               this._scrollBar.index = _loc9_ - 9;
            }
            else
            {
               this._scrollBar.index = 0;
            }
            _loc4_ = 0;
            while(_loc4_ < LIST_LENGTH)
            {
               _loc7_ = this._listCon.getChildAt(_loc4_) as PictureBookListItem;
               if(_loc7_.id == _loc9_ + 1)
               {
                  _loc7_.setSelect(true);
                  this.showInfo(_loc7_);
                  return;
               }
               _loc4_++;
            }
         }
      }
      
      private function onSearch(param1:MouseEvent) : void
      {
         if(this._searchTxt.text != null)
         {
            this.serachId(parseInt(this._searchTxt.text));
         }
      }
      
      private function onSFin(param1:FocusEvent) : void
      {
         this._searchTxt.text = "";
         this._searchTxt.textColor = 16777215;
      }
      
      private function onSFout(param1:FocusEvent) : void
      {
         if(this._searchTxt.text == "")
         {
            this._searchTxt.text = this.STXT;
            this._searchTxt.textColor = 16777215;
         }
      }
   }
}

