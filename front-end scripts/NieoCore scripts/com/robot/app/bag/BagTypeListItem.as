package com.robot.app.bag
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.system.ApplicationDomain;
   import flash.text.TextField;
   import org.taomee.utils.DisplayUtil;
   
   public class BagTypeListItem extends Sprite
   {
      
      private var _width:Number;
      
      private var _id:int = 0;
      
      private var _txt:TextField;
      
      private var _bgMC:MovieClip;
      
      public function BagTypeListItem(param1:ApplicationDomain)
      {
         super();
         mouseChildren = false;
         buttonMode = true;
         this._bgMC = new (param1.getDefinition("ListItemMc") as Class)() as MovieClip;
         this._bgMC.gotoAndStop(1);
         addChild(this._bgMC);
         this._txt = this._bgMC["txt"];
         visible = true;
         this.width = 80;
      }
      
      override public function set width(param1:Number) : void
      {
         this._width = param1;
         this._bgMC.width = param1;
      }
      
      override public function get width() : Number
      {
         return this._width;
      }
      
      public function setInfo(param1:int, param2:String) : void
      {
         this._id = param1;
         this._txt.text = param2;
         visible = true;
      }
      
      public function get id() : int
      {
         return this._id;
      }
      
      public function set select(param1:Boolean) : void
      {
         if(param1)
         {
            this._bgMC.gotoAndStop(2);
         }
         else
         {
            this._bgMC.gotoAndStop(1);
         }
      }
      
      public function clear() : void
      {
         this._txt.text = "";
         visible = false;
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeAllChild(this);
         this._txt = null;
      }
   }
}

