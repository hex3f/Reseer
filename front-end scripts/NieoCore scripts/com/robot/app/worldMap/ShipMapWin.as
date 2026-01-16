package com.robot.app.worldMap
{
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MapManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.setTimeout;
   
   public class ShipMapWin extends Sprite
   {
      
      private var mapMC:MovieClip;
      
      private var idArray:Array = [4,5,9,7,6,1,8];
      
      public function ShipMapWin()
      {
         super();
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         LevelManager.appLevel.addChild(this);
         if(!this.mapMC)
         {
            _loc1_ = new MCLoader("resource/shipMap.swf",LevelManager.appLevel,1,"正在打开飞船地图");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
            _loc1_.doLoad();
         }
         else
         {
            setTimeout(this.initMap,200);
         }
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         this.mapMC = param1.getContent() as MovieClip;
         setTimeout(this.initMap,200);
      }
      
      private function initMap() : void
      {
         var _loc1_:SimpleButton = null;
         addChild(this.mapMC);
         var _loc2_:SimpleButton = this.mapMC["closeBtn"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.close);
         var _loc3_:int = 0;
         while(_loc3_ < 7)
         {
            _loc1_ = this.mapMC.getChildByName("btn_" + _loc3_) as SimpleButton;
            _loc1_.addEventListener(MouseEvent.CLICK,this.changeMap);
            _loc3_++;
         }
      }
      
      private function changeMap(param1:MouseEvent) : void
      {
         var _loc2_:String = SimpleButton(param1.currentTarget).name;
         var _loc3_:uint = uint(_loc2_.substr(-1,1));
         MapManager.changeMap(this.idArray[_loc3_]);
         this.close(null);
      }
      
      private function close(param1:MouseEvent) : void
      {
         this.parent.removeChild(this);
      }
   }
}

