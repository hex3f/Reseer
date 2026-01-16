package com.robot.app.mapProcess
{
   import com.robot.app.darkPortal.DarkPortalModel;
   import com.robot.app.toolBar.ToolBarController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import org.taomee.manager.ResourceManager;
   import org.taomee.manager.ToolTipManager;
   import org.taomee.utils.DisplayUtil;
   
   public class MapProcess_509 extends BaseMapProcess
   {
      
      private var _petMc:MovieClip;
      
      private var _point:Point = new Point(477,280);
      
      private var _scaleNum:Number = 1.8;
      
      public function MapProcess_509()
      {
         super();
      }
      
      override protected function init() : void
      {
         DarkPortalModel.showPetEnrichBlood();
         ToolBarController.panel.hide();
         LevelManager.iconLevel.visible = false;
         conLevel["sMc"].gotoAndStop(DarkPortalModel.doorIndex + 1);
         ToolTipManager.add(conLevel["door_0"],"暗黑武斗场");
         ResourceManager.getResource(ClientConfig.getPetSwfPath(DarkPortalModel.curBossId),this.comHandler,"pet");
      }
      
      private function comHandler(param1:DisplayObject) : void
      {
         if(Boolean(param1))
         {
            this._petMc = param1 as MovieClip;
            this.depthLevel.addChild(this._petMc);
            this._petMc.x = this._point.x;
            this._petMc.y = this._point.y;
            this._petMc.scaleX = this._scaleNum;
            this._petMc.scaleY = this._scaleNum;
            this._petMc.buttonMode = true;
            ToolTipManager.add(this._petMc,PetXMLInfo.getName(DarkPortalModel.curBossId));
            this._petMc.addEventListener(MouseEvent.CLICK,this.onPetClickHandler);
         }
      }
      
      private function onPetClickHandler(param1:MouseEvent) : void
      {
         var t:uint = 0;
         t = 0;
         var e:MouseEvent = param1;
         this._petMc.removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
         t = setTimeout(function():void
         {
            if(Boolean(_petMc))
            {
               _petMc.addEventListener(MouseEvent.CLICK,onPetClickHandler);
            }
            clearTimeout(t);
         },1000);
         DarkPortalModel.fightDarkProtal();
      }
      
      override public function destroy() : void
      {
         DarkPortalModel.des();
         ToolBarController.panel.show();
         LevelManager.iconLevel.visible = true;
         if(Boolean(this._petMc))
         {
            ToolTipManager.remove(this._petMc);
            this._petMc.removeEventListener(MouseEvent.CLICK,this.onPetClickHandler);
            DisplayUtil.removeForParent(this._petMc);
            this._petMc = null;
         }
         ToolTipManager.remove(conLevel["door_0"]);
      }
      
      public function onLeaveHandler() : void
      {
         DarkPortalModel.leaveDarkProtal();
      }
   }
}

