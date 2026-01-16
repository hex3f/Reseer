package com.robot.core.ui.mapTip
{
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   
   public class MapTipItem extends Sprite
   {
      
      private var tipMC:Sprite;
      
      private var icon:MovieClip;
      
      private var difIcon:MovieClip;
      
      private var titleTxt:TextField;
      
      private var desContainer:Sprite;
      
      private var _info:MapItemTipInfo;
      
      public function MapTipItem()
      {
         super();
         this.icon = UIManager.getMovieClip("MapTipIcon");
         this.difIcon = UIManager.getMovieClip("MapTipDifIcon");
         this.tipMC = new Sprite();
         this.addChild(this.tipMC);
      }
      
      public function set info(param1:MapItemTipInfo) : void
      {
         this._info = param1;
         this.setTitle(param1);
         this.setDes(param1);
         this.drawBg();
         if(param1.type != 0)
         {
            this.icon.gotoAndStop(param1.type);
         }
         this.icon.x = 2;
         this.tipMC.addChild(this.icon);
         this.tipMC.addChild(this.titleTxt);
         this.tipMC.addChild(this.desContainer);
         this.desContainer.x = 6;
         this.desContainer.y = this.titleTxt.height;
      }
      
      public function get info() : MapItemTipInfo
      {
         return this._info;
      }
      
      private function setTitle(param1:MapItemTipInfo) : void
      {
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.size = 14;
         if(param1.type == 0)
         {
            this.icon.visible = false;
            _loc2_.align = TextFormatAlign.CENTER;
            _loc2_.color = 16776960;
            this.titleTxt = this.getTextField(_loc2_);
            this.titleTxt.x = (160 - this.titleTxt.width) / 2;
         }
         else
         {
            _loc2_.align = TextFormatAlign.LEFT;
            _loc2_.color = 16777215;
            this.titleTxt = this.getTextField(_loc2_);
            this.titleTxt.x = this.icon.width + 8;
         }
         this.titleTxt.htmlText = param1.title;
      }
      
      private function setDes(param1:MapItemTipInfo) : void
      {
         var _loc2_:TextField = null;
         var _loc3_:TextField = null;
         var _loc4_:TextFormat = new TextFormat();
         _loc4_.size = 12;
         _loc4_.color = 16776960;
         if(param1.type == 0)
         {
            this.desContainer = new Sprite();
            if(uint(param1.content[0]) != 0)
            {
               _loc2_ = this.getTextField(_loc4_);
               _loc2_.width = 40;
               _loc2_.text = "难度:";
               this.difIcon.gotoAndStop(uint(param1.content[0]));
            }
            if(param1.content[1] != "")
            {
               _loc3_ = this.getTextField(_loc4_);
               _loc3_.text = "适合等级:" + param1.content[1];
               _loc3_.width = 120;
            }
            if(Boolean(_loc2_))
            {
               this.desContainer.addChild(_loc2_);
               this.desContainer.addChild(this.difIcon);
               this.difIcon.x = 30;
               this.difIcon.y = 2;
            }
            if(Boolean(_loc3_))
            {
               this.desContainer.addChild(_loc3_);
               _loc3_.y = 20;
            }
         }
         else
         {
            this.desContainer = this.getDesContainer(param1);
         }
      }
      
      private function drawBg() : void
      {
         var _loc1_:Number = 160;
         var _loc2_:Number = this.titleTxt.height + this.desContainer.height;
         this.tipMC.graphics.beginFill(73547,0.8);
         this.tipMC.graphics.drawRoundRect(0,0,_loc1_,_loc2_,10,10);
         this.tipMC.graphics.endFill();
      }
      
      private function getDesContainer(param1:MapItemTipInfo) : Sprite
      {
         var _loc2_:String = null;
         var _loc3_:TextField = null;
         var _loc4_:Array = null;
         var _loc5_:Sprite = new Sprite();
         var _loc6_:Array = this._info.content;
         var _loc7_:TextFormat = new TextFormat();
         _loc7_.size = 12;
         _loc7_.color = 16777215;
         var _loc8_:Number = 1;
         for each(_loc2_ in _loc6_)
         {
            if(_loc2_ != "")
            {
               _loc3_ = this.getTextField(_loc7_);
               if(_loc2_.indexOf("#") != -1)
               {
                  _loc4_ = _loc2_.split("#");
                  _loc2_ = _loc4_[1];
                  _loc3_.htmlText = "<font color=\'#ff0000\'>*" + _loc2_ + "</font>";
               }
               else
               {
                  _loc3_.htmlText = "*" + _loc2_;
               }
               if(param1.type == 2)
               {
                  if(_loc8_ > 1 && _loc8_ % 2 == 0)
                  {
                     _loc3_.x = 74;
                  }
                  else
                  {
                     _loc3_.x = 0;
                  }
                  _loc3_.y = (Math.ceil(_loc8_ / 2) - 1) * _loc3_.height;
               }
               else
               {
                  _loc3_.y = _loc3_.height * (_loc8_ - 1);
               }
               _loc5_.addChild(_loc3_);
               _loc8_++;
            }
         }
         return _loc5_;
      }
      
      private function getTextField(param1:TextFormat) : TextField
      {
         var _loc2_:TextField = new TextField();
         _loc2_.width = 80;
         _loc2_.height = 20;
         _loc2_.selectable = false;
         _loc2_.defaultTextFormat = param1;
         return _loc2_;
      }
   }
}

