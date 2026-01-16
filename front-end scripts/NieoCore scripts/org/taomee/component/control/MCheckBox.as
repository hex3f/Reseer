package org.taomee.component.control
{
   import com.robot.core.manager.AssetsManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextFormatAlign;
   import org.taomee.utils.DisplayUtil;
   
   public class MCheckBox extends MButton
   {
      
      private var isInitUI:Boolean = false;
      
      protected var selectedBox:Sprite;
      
      private var labelEmptyCls:Class = AssetsManager.getClass("org.taomee.component.control.MCheckBox_labelEmptyCls");
      
      protected var _selected:Boolean = false;
      
      private var labelSelectedCls:Class = AssetsManager.getClass("org.taomee.component.control.MCheckBox_labelSelectedCls");
      
      protected var gap:uint = 4;
      
      protected var emptyBox:Sprite;
      
      public function MCheckBox(param1:String = "CheckBox")
      {
         super(param1);
         offSetY = 0;
      }
      
      override protected function initUI() : void
      {
         bg = new MovieClip();
         _label.blod = false;
         _label.align = TextFormatAlign.LEFT;
         _label.textField.filters = [];
         _label.textColor = 0;
         containSprite.mouseChildren = false;
         containSprite.mouseEnabled = false;
         this.emptyBox = new this.labelEmptyCls() as Sprite;
         this.selectedBox = new this.labelSelectedCls() as Sprite;
         containSprite.addChild(this.emptyBox);
         label.x = this.emptyBox.width + this.gap;
         containSprite.addChild(label);
         var _loc1_:* = (containSprite.height - this.emptyBox.height) / 2;
         this.selectedBox.y = (containSprite.height - this.emptyBox.height) / 2;
         this.emptyBox.y = _loc1_;
         label.y = (containSprite.height - label.textField.textHeight) / 2;
         this.isInitUI = true;
         setSizeWH(containSprite.width,containSprite.height);
      }
      
      public function set selected(param1:Boolean) : void
      {
         this._selected = param1;
         if(this._selected)
         {
            containSprite.addChild(this.selectedBox);
            DisplayUtil.removeForParent(this.emptyBox);
         }
         else
         {
            containSprite.addChild(this.emptyBox);
            DisplayUtil.removeForParent(this.selectedBox);
         }
      }
      
      override protected function release() : void
      {
         this.selected = !this.selected;
         super.release();
      }
      
      override protected function revalidate() : void
      {
         var _loc1_:* = undefined;
         if(!this.isInitUI)
         {
            return;
         }
         super.revalidate();
         _loc1_ = (containSprite.height - this.emptyBox.height) / 2;
         this.selectedBox.y = (containSprite.height - this.emptyBox.height) / 2;
         this.emptyBox.y = _loc1_;
         label.y = (containSprite.height - label.textField.textHeight) / 2;
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      override public function set width(param1:Number) : void
      {
         super.width = param1;
         label.width = param1 - this.emptyBox.width - this.gap;
      }
   }
}

