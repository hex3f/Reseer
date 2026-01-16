package com.robot.core.mode.spriteModelAdditive
{
   import com.robot.core.mode.SpriteModel;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import gs.TweenLite;
   import org.taomee.utils.DisplayUtil;
   
   public class SpriteBloodBar implements ISpriteModelAdditive
   {
      
      private var _model:SpriteModel;
      
      private var barMC:MovieClip;
      
      private var tf:TextFormat;
      
      private var barMCX:Number = 0;
      
      private var barMCY:Number = 0;
      
      private var bloodTxt:TextField;
      
      public function SpriteBloodBar(param1:MovieClip, param2:Number = 0, param3:Number = 0)
      {
         super();
         this.barMC = param1;
         this.barMCX = param2;
         this.barMCY = param3;
         this.tf = new TextFormat();
         this.tf.size = 16;
         this.tf.font = "Tahoma";
         this.tf.color = 16711680;
         this.tf.bold = true;
      }
      
      public function init() : void
      {
      }
      
      public function setHp(param1:uint, param2:uint, param3:uint = 0) : void
      {
         var mc:MovieClip = null;
         var num:uint = 0;
         var txt:TextField = null;
         var t:uint = 0;
         txt = null;
         t = 0;
         var hp:uint = param1;
         var maxHp:uint = param2;
         var damage:uint = param3;
         var p:Number = hp / maxHp;
         this.bloodTxt = this.barMC["blood_txt"];
         if(Boolean(this.bloodTxt))
         {
            this.bloodTxt.text = hp + " / " + maxHp;
         }
         mc = this.barMC["barMC"];
         num = mc.totalFrames - Math.floor(mc.totalFrames * p);
         if(num == 0)
         {
            num = 1;
         }
         mc.gotoAndStop(num);
         if(damage > 0)
         {
            txt = new TextField();
            txt.autoSize = TextFieldAutoSize.LEFT;
            txt.textColor = 16711680;
            txt.filters = [new GlowFilter(16777215,1,2,2,5)];
            txt.text = "-" + damage;
            txt.setTextFormat(this.tf);
            txt.x = -txt.width / 2;
            txt.y = -this._model.height / 2;
            TweenLite.to(txt,0.5,{"y":txt.y - 20});
            this._model.addChild(txt);
            t = setTimeout(function():void
            {
               DisplayUtil.removeForParent(txt);
               clearTimeout(t);
            },2000);
         }
      }
      
      public function get model() : SpriteModel
      {
         return this._model;
      }
      
      public function set model(param1:SpriteModel) : void
      {
         this._model = param1;
      }
      
      public function show() : void
      {
         var _loc1_:Rectangle = this._model.getRect(this._model);
         this.barMC.x = this._model.width - this.barMC.width / 2;
         this.barMC.y = this.barMCY;
         this._model.addChild(this.barMC);
      }
      
      public function hide() : void
      {
         DisplayUtil.removeForParent(this.barMC);
      }
      
      public function destroy() : void
      {
         this.hide();
         this.barMC = null;
         this._model = null;
      }
   }
}

