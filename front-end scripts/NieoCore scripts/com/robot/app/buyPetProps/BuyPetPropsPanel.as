package com.robot.app.buyPetProps
{
   import com.robot.core.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.event.*;
   import com.robot.core.info.*;
   import com.robot.core.manager.*;
   import com.robot.core.net.*;
   import com.robot.core.newloader.*;
   import com.robot.core.ui.alert.*;
   import com.robot.core.utils.*;
   import flash.display.*;
   import flash.events.*;
   import flash.geom.Point;
   import flash.system.ApplicationDomain;
   import flash.text.*;
   import flash.utils.*;
   import org.taomee.ds.*;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.*;
   
   public class BuyPetPropsPanel extends Sprite
   {
      
      private static var propsHashMap:HashMap;
      
      private var PATH:String = "resource/module/petProps/buyPetProps.swf";
      
      public var app:ApplicationDomain;
      
      private var mc:MovieClip;
      
      private var tipMc:MovieClip;
      
      private var _pageText:TextField;
      
      private var _preBtn:SimpleButton;
      
      private var _nextBtn:SimpleButton;
      
      public var goldCoinItemID:Number = 0;
      
      private var iconHashMap:HashMap = new HashMap();
      
      private var itemArray:Array;
      
      private var curPage:int = 0;
      
      private var totalPage:int = 1;
      
      private var itemMCHashMap:HashMap = new HashMap();
      
      private var isLoadingItem:Boolean = false;
      
      public function BuyPetPropsPanel()
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
         var closeBtn:SimpleButton;
         var event:MCLoadEvent = param1;
         this.itemArray = PetShopXMLInfo.getItemIdArray();
         this.app = event.getApplicationDomain();
         this.mc = new (this.app.getDefinition("petPropsPanel") as Class)() as MovieClip;
         this.tipMc = new (this.app.getDefinition("buyTipPanel") as Class)() as MovieClip;
         this._pageText = this.mc["pageText"] as TextField;
         this._preBtn = this.mc["preBtn"] as SimpleButton;
         this._nextBtn = this.mc["nextBtn"] as SimpleButton;
         this.totalPage = int(this.itemArray.length / 15) + 1;
         this._pageText.text = "1/" + this.totalPage.toString();
         this._nextBtn.addEventListener(MouseEvent.CLICK,this.nextPage);
         this._preBtn.addEventListener(MouseEvent.CLICK,this.prePage);
         closeBtn = this.mc["exitBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,this.closeHandler);
         addChild(this.mc);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(this);
         this.setupItemMC();
         setTimeout(function():void
         {
            showPage(0);
         },100);
      }
      
      private function setupItemMC() : void
      {
         var _loc1_:ItemMC = null;
         var _loc2_:int = 0;
         while(_loc2_ < 15)
         {
            _loc1_ = new ItemMC(this,_loc2_);
            this.itemMCHashMap.add("itemMC_" + _loc2_.toString(),_loc1_);
            this.mc.addChild(_loc1_.itemMC);
            _loc2_++;
         }
      }
      
      private function showPage(param1:int) : void
      {
         var _loc2_:ItemMC = null;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = param1 * 15;
         var _loc5_:int = (param1 + 1) * 15;
         if(_loc5_ > this.itemArray.length)
         {
            _loc5_ = int(this.itemArray.length);
         }
         var _loc6_:int = _loc5_ - _loc4_;
         for each(_loc2_ in this.itemMCHashMap.getValues())
         {
            _loc2_.visible = false;
         }
         _loc3_ = _loc4_;
         while(_loc3_ < _loc5_)
         {
            (this.itemMCHashMap.getValue("itemMC_" + _loc7_.toString()) as ItemMC).setup(this.itemArray[_loc3_]);
            (this.itemMCHashMap.getValue("itemMC_" + _loc7_.toString()) as ItemMC).visible = true;
            _loc7_++;
            _loc3_++;
         }
      }
      
      private function nextPage(param1:MouseEvent) : void
      {
         this.curPage += 1;
         if(this.curPage >= this.totalPage)
         {
            this.curPage = this.totalPage - 1;
         }
         this._pageText.text = this.curPage + 1 + "/" + this.totalPage.toString();
         this.showPage(this.curPage);
      }
      
      private function prePage(param1:MouseEvent) : void
      {
         this.curPage -= 1;
         if(this.curPage < 0)
         {
            this.curPage = 0;
         }
         this._pageText.text = this.curPage + 1 + "/" + this.totalPage.toString();
         this.showPage(this.curPage);
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
      
      public function showTipPanel(param1:uint, param2:MovieClip, param3:Point) : void
      {
         if(MainManager.actorInfo.coins < Number(PetShopXMLInfo.getPriceByItemID(param1)))
         {
            Alarm.show("你的赛尔豆不足");
            return;
         }
         new ListPetProps(this.tipMc,param1,param2,param3);
      }
      
      private function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
         LevelManager.openMouseEvent();
      }
   }
}

