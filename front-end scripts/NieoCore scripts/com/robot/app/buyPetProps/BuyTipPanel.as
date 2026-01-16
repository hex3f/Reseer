package com.robot.app.buyPetProps
{
   import com.robot.app.buyItem.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.ui.alert.*;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.*;
   import flash.geom.Point;
   import flash.text.*;
   import org.taomee.utils.*;
   
   public class BuyTipPanel
   {
      
      private static var okBtn:SimpleButton;
      
      private static var cancelBtn:SimpleButton;
      
      private static var preBtn:SimpleButton;
      
      private static var nextBtn:SimpleButton;
      
      private static var numTxt:TextField;
      
      private static var itemId:uint;
      
      private static var mianMc:MovieClip;
      
      private static var itemName:String;
      
      private static var itemPrice:uint;
      
      private static var iconLoader:Loader;
      
      private static var sigInfo:SingleItemInfo;
      
      private static var _listPet:ListPetProps;
      
      private static var dragMC:SimpleButton;
      
      private static var curPropsCount:uint = 0;
      
      public function BuyTipPanel()
      {
         super();
      }
      
      public static function initPanel(param1:MovieClip, param2:uint, param3:MovieClip, param4:Point, param5:ListPetProps) : void
      {
         var mc:MovieClip = param1;
         var _itemId:uint = param2;
         var iconMC:MovieClip = param3;
         var point:Point = param4;
         var listPet:ListPetProps = param5;
         itemName = PetShopXMLInfo.getNameByItemID(_itemId);
         itemPrice = PetShopXMLInfo.getPriceByItemID(_itemId);
         okBtn = mc["okBtn"];
         cancelBtn = mc["cancelBtn"];
         preBtn = mc["preBtn"];
         nextBtn = mc["nextBtn"];
         numTxt = mc["numTxt"];
         dragMC = mc["dragMC"];
         dragMC.addEventListener(MouseEvent.MOUSE_DOWN,function():void
         {
            mc.startDrag();
         });
         dragMC.addEventListener(MouseEvent.MOUSE_UP,function():void
         {
            mc.stopDrag();
         });
         numTxt.text = "1";
         mc["propTxt"].text = "    1个" + itemName + "需花费" + itemPrice.toString() + "个赛尔豆，你现在拥有" + MainManager.actorInfo.coins + "个赛尔豆，要确认购买吗？";
         numTxt.addEventListener(Event.CHANGE,onChangeTxt);
         okBtn.addEventListener(MouseEvent.CLICK,onBuy);
         cancelBtn.addEventListener(MouseEvent.CLICK,onExit);
         preBtn.addEventListener(MouseEvent.CLICK,onPre);
         nextBtn.addEventListener(MouseEvent.CLICK,onNext);
         itemId = _itemId;
         mianMc = mc;
         if(Boolean(mianMc.getChildByName("itemIcon")))
         {
            mianMc.removeChild(mianMc.getChildByName("itemIcon"));
         }
         iconMC.x = point.x;
         iconMC.y = point.y;
         iconMC.name = "itemIcon";
         mianMc.addChild(iconMC);
         LevelManager.closeMouseEvent();
         LevelManager.topLevel.addChild(mianMc);
         DisplayUtil.align(mianMc,null,AlignType.MIDDLE_CENTER);
         sigInfo = ItemManager.getCollectionInfo(_itemId);
         if(Boolean(sigInfo))
         {
            curPropsCount = sigInfo.itemNum;
         }
         _listPet = listPet;
      }
      
      private static function onChangeTxt(param1:Event) : void
      {
         var _loc2_:uint = uint(numTxt.text);
         if(_loc2_ > Math.floor(MainManager.actorInfo.coins / itemPrice))
         {
            Alarm.show("你的赛尔豆不足",okFun);
            numTxt.type = TextFieldType.DYNAMIC;
            numTxt.text = Math.floor(MainManager.actorInfo.coins / itemPrice).toString();
         }
         mianMc["propTxt"].text = "    " + uint(numTxt.text) + "个" + itemName + "需花费" + itemPrice * uint(numTxt.text) + "个赛尔豆，你现在拥有" + MainManager.actorInfo.coins + "个赛尔豆，要确认购买吗？";
      }
      
      private static function okFun() : void
      {
         numTxt.type = TextFieldType.INPUT;
         LevelManager.closeMouseEvent();
      }
      
      private static function onBuy(param1:MouseEvent) : void
      {
         var _loc2_:uint = uint(numTxt.text);
         if(_loc2_ > Math.floor(MainManager.actorInfo.coins / itemPrice))
         {
            Alarm.show("你的赛尔豆不足");
            return;
         }
         ItemAction.buyItem(itemId,false,_loc2_);
         remove();
      }
      
      private static function remove() : void
      {
         DisplayUtil.removeForParent(mianMc);
         LevelManager.openMouseEvent();
         _listPet.destroy();
      }
      
      private static function onExit(param1:MouseEvent) : void
      {
         remove();
      }
      
      private static function onPre(param1:MouseEvent) : void
      {
         changeNum("0");
      }
      
      private static function changeNum(param1:String) : void
      {
         var _loc2_:uint = uint(numTxt.text);
         if(param1 == "0" && _loc2_ <= uint(MainManager.actorInfo.coins / itemPrice) && _loc2_ > 1)
         {
            _loc2_ -= 1;
         }
         else if(param1 == "1" && _loc2_ < uint(MainManager.actorInfo.coins / itemPrice) && _loc2_ >= 1)
         {
            _loc2_ += 1;
         }
         numTxt.text = _loc2_.toString();
         mianMc["propTxt"].text = "    " + _loc2_ + "个" + itemName + "需花费" + itemPrice * _loc2_ + "个赛尔豆，你现在拥有" + MainManager.actorInfo.coins + "个赛尔豆，要确认购买吗？";
      }
      
      private static function onNext(param1:MouseEvent) : void
      {
         changeNum("1");
      }
   }
}

