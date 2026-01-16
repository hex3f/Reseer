package com.robot.app.storage
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.UIManager;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class StorageListItem extends Sprite
   {
      
      private var _bg:Sprite;
      
      private var _info:FitmentInfo;
      
      private var _obj:DisplayObject;
      
      private var _txt:TextField;
      
      public function StorageListItem()
      {
         super();
         this._bg = UIManager.getSprite("Storage_ToolBar_Itembg");
         this._bg.width = 60;
         this._bg.height = 60;
         addChild(this._bg);
         this._txt = new TextField();
         this._txt.textColor = 16777215;
         this._txt.autoSize = TextFieldAutoSize.RIGHT;
         this._txt.mouseEnabled = false;
         this._txt.filters = [new GlowFilter(16750848,1,3.5,3.5,10)];
      }
      
      public function get info() : FitmentInfo
      {
         return this._info;
      }
      
      public function set info(param1:FitmentInfo) : void
      {
         this.clear();
         this._info = param1;
         if(this._info == null)
         {
            return;
         }
         ToolTipManager.add(this,ItemXMLInfo.getName(this._info.id));
         ResourceManager.getResource(ClientConfig.getFitmentIcon(this._info.id),this.onLoad);
      }
      
      public function clear() : void
      {
         if(Boolean(this._info))
         {
            ResourceManager.cancel(ClientConfig.getFitmentIcon(this._info.id),this.onLoad);
         }
         if(Boolean(this._obj))
         {
            DisplayUtil.removeForParent(this._obj);
            this._obj = null;
         }
         this._txt.text = "";
         DisplayUtil.removeForParent(this._txt);
      }
      
      public function get obj() : DisplayObject
      {
         return this._obj;
      }
      
      public function set unUsedCount(param1:uint) : void
      {
         if(this._info.unUsedCount <= 1)
         {
            this._txt.text = "";
            DisplayUtil.removeForParent(this._txt);
            return;
         }
         this._txt.text = this._info.unUsedCount.toString();
      }
      
      public function destroy() : void
      {
         this.clear();
         ToolTipManager.remove(this);
      }
      
      private function onLoad(param1:DisplayObject) : void
      {
         this._obj = param1;
         DisplayUtil.align(this._obj,new Rectangle(0,0,this._bg.width,this._bg.height),AlignType.MIDDLE_CENTER);
         addChild(this._obj);
         if(this._info.unUsedCount > 1)
         {
            this._txt.text = this._info.unUsedCount.toString();
            addChild(this._txt);
            DisplayUtil.align(this._txt,new Rectangle(85,0,this._bg.width,this._bg.height),AlignType.BOTTOM_RIGHT);
         }
      }
   }
}

