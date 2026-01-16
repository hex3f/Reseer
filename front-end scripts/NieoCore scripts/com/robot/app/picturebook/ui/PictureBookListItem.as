package com.robot.app.picturebook.ui
{
   import com.robot.core.manager.UIManager;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public class PictureBookListItem extends Sprite
   {
      
      public var index:int;
      
      public var id:uint;
      
      private var _isShow:Boolean;
      
      private var _txt:TextField;
      
      private var _bg:Sprite;
      
      private var _color:uint;
      
      private var _props:Sprite;
      
      public function PictureBookListItem()
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         this._bg = UIManager.getSprite("List_overSkin");
         this._bg.width = 115;
         this._bg.height = 18;
         addChild(this._bg);
         this._txt = new TextField();
         this._txt.autoSize = TextFieldAutoSize.LEFT;
         this._txt.x = 4;
         addChild(this._txt);
         this._props = UIManager.getSprite("Props_Icon");
         this._props.scaleX = this._props.scaleY = 0.2;
         this._props.x = 84;
         this._props.y = 2;
         this._props.visible = false;
         addChild(this._props);
      }
      
      public function set text(param1:String) : void
      {
         this._txt.text = param1;
      }
      
      public function get text() : String
      {
         return this._txt.text;
      }
      
      public function set isShow(param1:Boolean) : void
      {
         this._isShow = param1;
         if(param1)
         {
            this._color = 13260;
         }
         else
         {
            this._color = 0;
         }
         this._txt.textColor = this._color;
      }
      
      public function get isShow() : Boolean
      {
         return this._isShow;
      }
      
      public function hasPet(param1:Boolean) : void
      {
         if(param1)
         {
            this._props.visible = true;
         }
         else
         {
            this._props.visible = false;
         }
      }
      
      public function setSelect(param1:Boolean) : void
      {
         if(param1)
         {
            this._txt.textColor = 16711680;
         }
         else
         {
            this._txt.textColor = this._color;
         }
      }
   }
}

