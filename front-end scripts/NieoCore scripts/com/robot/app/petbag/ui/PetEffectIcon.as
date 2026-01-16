package com.robot.app.petbag.ui
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.config.xml.PetEffectXMLInfo;
   import com.robot.core.info.pet.PetEffectInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class PetEffectIcon extends Sprite
   {
      
      private var _bgMc:Sprite;
      
      private var _itemId:uint;
      
      private var _path:String = "resource/item/petItem/effectIcon/";
      
      private var _iconMc:MovieClip;
      
      private var _info:PetEffectInfo;
      
      private var _tipMC:MovieClip;
      
      private var _txt:String;
      
      public function PetEffectIcon()
      {
         super();
         this._bgMc = new Sprite();
         this._bgMc.graphics.lineStyle(1,0,1);
         this._bgMc.graphics.beginFill(0,1);
         this._bgMc.graphics.drawRect(0,0,45.5,26);
         this._bgMc.graphics.endFill();
         this._bgMc.alpha = 0;
         this.addChild(this._bgMc);
         this._tipMC = UIManager.getMovieClip("ui_SkillTipPanel");
      }
      
      public function show(param1:PetEffectInfo) : void
      {
         this._info = param1;
         this._itemId = this._info.itemId;
         if(this._itemId > 1005 && this._itemId <= 1045)
         {
            return;
         }
         ResourceManager.getResource(this._path + this._itemId + ".swf",this.onLoadComHandler);
      }
      
      private function onLoadComHandler(param1:DisplayObject) : void
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(Boolean(param1))
         {
            this._iconMc = param1 as MovieClip;
            this.addChild(this._iconMc);
            this._iconMc["txt"].text = this._info.leftCount.toString();
            _loc2_ = ItemXMLInfo.getName(this._itemId);
            _loc3_ = "剩余使用次数:" + this._info.leftCount.toString();
            _loc4_ = PetEffectXMLInfo.getDes(this._itemId);
            this._txt = "<font color=\'#ffff00\' size=\'15\'>" + _loc2_ + "</font>\r\r" + "<font color=\'#ff0000\'>" + _loc3_ + "</font>\r\r" + "<font color=\'#ffffff\'>" + _loc4_ + "</font>";
            this._tipMC["info_txt"].htmlText = this._txt;
            this.addEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
            this.addEventListener(MouseEvent.MOUSE_OUT,this.onOutHandler);
         }
      }
      
      private function onOverHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = this.mouseX;
         var _loc3_:Number = this.mouseY;
         var _loc4_:Point = this.localToGlobal(new Point(_loc2_,_loc3_));
         LevelManager.appLevel.addChild(this._tipMC);
         this._tipMC.x = _loc4_.x + 15;
         this._tipMC.y = _loc4_.y + 15;
         LevelManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMoveHandler);
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this._tipMC);
         LevelManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMoveHandler);
      }
      
      public function destroy() : void
      {
         this.clear();
         if(this._itemId != 0)
         {
            ResourceManager.cancelURL(this._path + this._itemId + ".swf");
         }
         this.removeChild(this._bgMc);
         this._bgMc = null;
         this._tipMC = null;
      }
      
      private function onMoveHandler(param1:MouseEvent) : void
      {
         this._tipMC.x = LevelManager.stage.mouseX + 15;
         this._tipMC.y = LevelManager.stage.mouseY + 15;
      }
      
      public function clear() : void
      {
         if(Boolean(this._iconMc))
         {
            this.removeChild(this._iconMc);
            this._iconMc = null;
         }
         this._info = null;
         this.removeEventListener(MouseEvent.MOUSE_OVER,this.onOverHandler);
         this.removeEventListener(MouseEvent.MOUSE_OUT,this.onOutHandler);
         if(Boolean(this._tipMC))
         {
            DisplayUtil.removeForParent(this._tipMC);
         }
      }
   }
}

