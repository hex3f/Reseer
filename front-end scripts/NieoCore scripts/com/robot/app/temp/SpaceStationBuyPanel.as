package com.robot.app.temp
{
   import com.robot.app.buyPetProps.ListPetProps;
   import com.robot.core.CommandID;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.FitmentInfo;
   import com.robot.core.manager.FitmentManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.utils.ByteArray;
   import org.taomee.ds.HashMap;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class SpaceStationBuyPanel extends Sprite
   {
      
      private static var propsHashMap:HashMap;
      
      private var PATH:String = "resource/module/petProps/buyPetProps2.swf";
      
      private var app:ApplicationDomain;
      
      private var mc:MovieClip;
      
      private var tipMc:MovieClip;
      
      private var buyPropsBtn:SimpleButton;
      
      private var buyPrimaryBtn:SimpleButton;
      
      private var buyMidBtn:SimpleButton;
      
      private var buyHighBtn:SimpleButton;
      
      private var propsMC:MovieClip;
      
      private var midPropsMC:MovieClip;
      
      private var primaryMC:MovieClip;
      
      private var midMC:MovieClip;
      
      private var highMC:MovieClip;
      
      private var buyPrEnergyBtn:SimpleButton;
      
      private var priEnergyMC:MovieClip;
      
      private var buyCoverBtn:SimpleButton;
      
      private var midPropsBtn:SimpleButton;
      
      public function SpaceStationBuyPanel()
      {
         super();
      }
      
      public function show() : void
      {
         var _loc1_:MCLoader = null;
         if(!this.mc)
         {
            _loc1_ = new MCLoader(this.PATH,this,1,"正在打开精灵道具列表");
            _loc1_.addEventListener(MCLoadEvent.SUCCESS,this.onLoad);
            _loc1_.doLoad();
         }
         else
         {
            DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
            LevelManager.closeMouseEvent();
            LevelManager.appLevel.addChild(this);
         }
      }
      
      private function onLoad(param1:MCLoadEvent) : void
      {
         this.app = param1.getApplicationDomain();
         this.mc = new (this.app.getDefinition("petPropsPanel") as Class)() as MovieClip;
         this.tipMc = new (this.app.getDefinition("buyTipPanel") as Class)() as MovieClip;
         this.primaryMC = new (this.app.getDefinition("primaryMC") as Class)() as MovieClip;
         this.midMC = new (this.app.getDefinition("midMC") as Class)() as MovieClip;
         this.highMC = new (this.app.getDefinition("highMC") as Class)() as MovieClip;
         this.priEnergyMC = new (this.app.getDefinition("priEnergyMC") as Class)() as MovieClip;
         addChild(this.mc);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(this);
         var _loc2_:SimpleButton = this.mc["exitBtn"];
         _loc2_.addEventListener(MouseEvent.CLICK,this.closeHandler);
         this.initPanel();
         if(propsHashMap == null)
         {
            propsHashMap = new HashMap();
            propsHashMap.add(300011,20);
            propsHashMap.add(300012,40);
            propsHashMap.add(300013,80);
            propsHashMap.add(300001,200);
            propsHashMap.add(300016,30);
            propsHashMap.add(300002,400);
         }
      }
      
      private function initPanel() : void
      {
         this.buyPrimaryBtn = this.mc["buyPrimaryBtn"] as SimpleButton;
         this.buyPrimaryBtn.addEventListener(MouseEvent.CLICK,this.showPrimaryTip);
         this.buyMidBtn = this.mc["buyMidBtn"] as SimpleButton;
         this.buyMidBtn.addEventListener(MouseEvent.CLICK,this.showMidTip);
         this.buyHighBtn = this.mc["buyHighBtn"] as SimpleButton;
         this.buyHighBtn.addEventListener(MouseEvent.CLICK,this.showHighTip);
         this.buyPrEnergyBtn = this.mc["buyPrEnergyBtn"] as SimpleButton;
         this.buyPrEnergyBtn.addEventListener(MouseEvent.CLICK,this.showPriEnergyTip);
      }
      
      private function getCover(param1:MouseEvent) : void
      {
         SocketConnection.addCmdListener(CommandID.BUY_FITMENT,this.onBuyFitment);
         SocketConnection.send(CommandID.BUY_FITMENT,500502,1);
      }
      
      private function onBuyFitment(param1:SocketEvent) : void
      {
         SocketConnection.removeCmdListener(CommandID.BUY_FITMENT,this.onBuyFitment);
         var _loc2_:ByteArray = param1.data as ByteArray;
         var _loc3_:uint = _loc2_.readUnsignedInt();
         var _loc4_:uint = _loc2_.readUnsignedInt();
         var _loc5_:uint = _loc2_.readUnsignedInt();
         MainManager.actorInfo.coins = _loc3_;
         var _loc6_:FitmentInfo = new FitmentInfo();
         _loc6_.id = _loc4_;
         FitmentManager.addInStorage(_loc6_);
         Alarm.show("精灵恢复仓已经放入你的基地仓库");
      }
      
      private function showMidPropsTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300002,this.midPropsMC,new Point(173,45));
      }
      
      private function showPropsTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300001,this.propsMC,new Point(173,45));
      }
      
      private function showPriEnergyTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300016,this.priEnergyMC,new Point(185,47));
      }
      
      private function showHighTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300013,this.highMC,new Point(182,45));
      }
      
      private function showMidTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300012,this.midMC,new Point(167,45));
      }
      
      private function showPrimaryTip(param1:MouseEvent) : void
      {
         this.showTipPanel(300011,this.primaryMC,new Point(185,45));
      }
      
      private function showTipPanel(param1:uint, param2:MovieClip, param3:Point) : void
      {
         if(MainManager.actorInfo.coins < propsHashMap.getValue(param1))
         {
            Alarm.show("你的赛尔豆不足");
            return;
         }
         DisplayUtil.removeForParent(this);
         new ListPetProps(this.tipMc,param1,param2,param3);
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
   }
}

