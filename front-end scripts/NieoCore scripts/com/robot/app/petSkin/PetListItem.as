package com.robot.app.petSkin
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.pet.PetListInfo;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.system.ApplicationDomain;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class PetListItem extends Sprite
   {
      
      private var panel:MLoadPane;
      
      private var _info:PetListInfo;
      
      private var _sbgmc:DisplayObject;
      
      private var _obj:MovieClip;
      
      private var _bgmc:DisplayObject;
      
      private var _select:Boolean;
      
      public function PetListItem(param1:ApplicationDomain)
      {
         super();
         buttonMode = true;
         mouseChildren = false;
         var _loc2_:MovieClip = new (param1.getDefinition("PetSkin_ListItem") as Class)() as MovieClip;
         addChild(_loc2_);
         this._sbgmc = _loc2_["sbgMc"];
         this._bgmc = _loc2_["bgMc"];
         this.select = false;
      }
      
      public function get select() : Boolean
      {
         return this._select;
      }
      
      public function clear() : void
      {
         if(Boolean(this._info))
         {
            ResourceManager.cancel(ClientConfig.getPetSwfPath(this._info.skinID),this.onLoadPet);
         }
         this._info = null;
         if(Boolean(this._obj))
         {
            DisplayUtil.removeForParent(this._obj);
            this._obj = null;
         }
         if(Boolean(this.panel))
         {
            this.panel.destroy();
            this.panel = null;
         }
      }
      
      private function onLoadPet(param1:DisplayObject) : void
      {
         this._obj = param1 as MovieClip;
         DisplayUtil.stopAllMovieClip(this._obj);
         this.panel = new MLoadPane(this._obj,MLoadPane.FIT_NONE);
         this.panel.setSizeWH(this._bgmc.width,this._bgmc.height);
         this.panel.x = this._bgmc.x;
         this.panel.y = this._bgmc.y;
         addChild(this.panel);
      }
      
      public function get info() : PetListInfo
      {
         return this._info;
      }
      
      public function set info(param1:PetListInfo) : void
      {
         if(Boolean(this._info))
         {
            ResourceManager.cancel(ClientConfig.getPetSwfPath(this._info.skinID),this.onLoadPet);
         }
         this._info = param1;
         if(Boolean(this._obj))
         {
            DisplayUtil.removeForParent(this._obj);
            this._obj = null;
         }
         ResourceManager.getResource(ClientConfig.getPetSwfPath(this._info.skinID),this.onLoadPet,"pet");
      }
      
      public function set select(param1:Boolean) : void
      {
         this._select = param1;
         if(this._select)
         {
            this._sbgmc.visible = true;
         }
         else
         {
            this._sbgmc.visible = false;
         }
      }
   }
}

