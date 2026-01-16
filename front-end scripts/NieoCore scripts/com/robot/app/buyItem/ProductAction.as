package com.robot.app.buyItem
{
   import com.adobe.crypto.MD5;
   import com.robot.app.bag.BagClothPreview;
   import com.robot.app.task.taskUtils.taskDialog.NpcTipDialog;
   import com.robot.app.vipSession.VipSession;
   import com.robot.core.CommandID;
   import com.robot.core.config.xml.*;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.manager.*;
   import com.robot.core.net.SocketConnection;
   import com.robot.core.skeleton.ClothPreview;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import com.robot.core.utils.TextFormatUtil;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.ByteArray;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.events.SocketEvent;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class ProductAction
   {
      
      public static var productID:uint;
      
      private static var count:uint;
      
      private static var closeBtn:SimpleButton;
      
      private static var okBtn:SimpleButton;
      
      private static var cancelBtn:SimpleButton;
      
      private static var pswTxt:TextField;
      
      private static var contentTxt:TextField;
      
      private static var panel:MovieClip;
      
      private static var loadPanel:MLoadPane;
      
      setup();
      
      public function ProductAction()
      {
         super();
      }
      
      private static function setup() : void
      {
         SocketConnection.addCmdListener(CommandID.GOLD_CHECK_REMAIN,onCheckGold);
         SocketConnection.addCmdListener(CommandID.MONEY_CHECK_PSW,onCheckPSW);
         SocketConnection.addCmdListener(CommandID.MONEY_CHECK_REMAIN,onCheckMoney);
      }
      
      public static function buyGoldProduct(param1:uint, param2:uint = 1) : void
      {
         productID = param1;
         count = param2;
         SocketConnection.send(CommandID.GOLD_CHECK_REMAIN);
      }
      
      private static function onCheckGold(param1:SocketEvent) : void
      {
         var event:SocketEvent = param1;
         var num:Number = (event.data as ByteArray).readUnsignedInt() / 100;
         var name:String = GoldProductXMLInfo.getNameByProID(productID);
         var price:Number = Number(GoldProductXMLInfo.getPriceByProID(productID));
         if(name == "" && price == 0)
         {
            name = PetShopXMLInfo.getNameByProID(productID);
            price = Number(PetShopXMLInfo.getPriceByProID(productID));
         }
         Alert.show(TextFormatUtil.getRedTxt(name) + "需要花费" + TextFormatUtil.getRedTxt(price.toString()) + "金豆，" + "目前你拥有" + TextFormatUtil.getRedTxt(num.toString()) + "金豆，要确认购买吗？",function():void
         {
            var _loc1_:ByteArray = new ByteArray();
            _loc1_.writeShort(count);
            SocketConnection.send(CommandID.GOLD_BUY_PRODUCT,productID,_loc1_);
         });
      }
      
      public static function buyMoneyProduct(param1:uint, param2:uint = 1) : void
      {
         var proID:uint = param1;
         var cnt:uint = param2;
         if(proID == 200000 || proID == 200001 || proID == 200002)
         {
            if(!MainManager.actorInfo.vip)
            {
               NpcTipDialog.showAnswer("很抱歉哟，只有超能NoNo才能帮助金豆兑换。你想立刻拥有超能NoNo吗？",function():void
               {
                  var r:VipSession = new VipSession();
                  r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
                  {
                  });
                  r.getSession();
               },null,NpcTipDialog.ROCKY);
               return;
            }
         }
         productID = proID;
         count = cnt;
         SocketConnection.send(CommandID.MONEY_CHECK_PSW);
      }
      
      private static function onCheckPSW(param1:SocketEvent) : void
      {
         var event:SocketEvent = param1;
         var num:uint = (event.data as ByteArray).readUnsignedInt();
         if(num == 1)
         {
            SocketConnection.send(CommandID.MONEY_CHECK_REMAIN);
         }
         else
         {
            Alert.show("你的米币账户设置还没有完成，需要购买米币商品必须输入<font color=\'#ff0000\'>米币账户支付密码</font>，确定现在去进行<font color=\'#ff0000\'>米币账户支付密码</font>的设置吗？",function():void
            {
               var r:VipSession = new VipSession();
               r.addEventListener(VipSession.GET_SESSION,function(param1:Event):void
               {
               });
               r.getSession();
            });
         }
      }
      
      private static function onCheckMoney(param1:SocketEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Sprite = null;
         var _loc4_:BagClothPreview = null;
         var _loc5_:Array = null;
         var _loc6_:Number = 0;
         if(!panel)
         {
            panel = AssetsManager.getMovieClip("ui_moneyBuyPanel");
            closeBtn = panel["closeBtn"];
            okBtn = panel["okBtn"];
            cancelBtn = panel["cancelBtn"];
            pswTxt = panel["txt"];
            contentTxt = panel["content_txt"];
            closeBtn.addEventListener(MouseEvent.CLICK,closePanel);
            cancelBtn.addEventListener(MouseEvent.CLICK,closePanel);
            okBtn.addEventListener(MouseEvent.CLICK,sendPassword);
            loadPanel = new MLoadPane(null,MLoadPane.FIT_HEIGHT);
            loadPanel.isMask = false;
            loadPanel.setSizeWH(84,84);
            loadPanel.x = 56;
            loadPanel.y = 105;
            panel.addChild(loadPanel);
            DisplayUtil.align(panel,null,AlignType.MIDDLE_CENTER);
         }
         var _loc7_:Array = MoneyProductXMLInfo.getItemIDs(productID);
         if(_loc7_.length == 1)
         {
            _loc2_ = ItemXMLInfo.getIconURL(_loc7_[0]);
            loadPanel.setIcon(ItemXMLInfo.getIconURL(_loc7_[0]));
         }
         else
         {
            _loc3_ = UIManager.getSprite("ComposeMC");
            _loc4_ = new BagClothPreview(_loc3_,null,ClothPreview.MODEL_SHOW);
            _loc5_ = [];
            for each(_loc6_ in _loc7_)
            {
               _loc5_.push(new PeopleItemInfo(_loc6_));
            }
            _loc4_.changeCloth(_loc5_);
            loadPanel.setIcon(_loc3_);
         }
         pswTxt.text = "";
         var _loc8_:Number = (param1.data as ByteArray).readUnsignedInt() / 100;
         var _loc9_:String = MoneyProductXMLInfo.getNameByProID(productID);
         var _loc10_:Number = Number(MoneyProductXMLInfo.getPriceByProID(productID));
         if(Boolean(MainManager.actorInfo.vip))
         {
            _loc10_ *= MoneyProductXMLInfo.getVipByProID(productID);
         }
         if(_loc10_ <= _loc8_)
         {
            contentTxt.htmlText = "你选择了" + TextFormatUtil.getRedTxt(_loc9_) + "需要花费" + TextFormatUtil.getRedTxt(_loc10_.toString()) + "米币，" + "目前你拥有" + TextFormatUtil.getRedTxt(_loc8_.toString()) + "米币，若确认购买该物品，请输入你的<font color=\'#ff0000\'>米币账户支付密码</font>：";
            LevelManager.appLevel.addChild(panel);
         }
         else
         {
            Alarm.show("你选择了" + TextFormatUtil.getRedTxt(_loc9_) + "需要花费" + TextFormatUtil.getRedTxt(_loc10_.toString()) + "米币，" + "目前你拥有" + TextFormatUtil.getRedTxt(_loc8_.toString()) + "米币，你的米币余额不足以购买此物品！");
         }
      }
      
      private static function closePanel(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(panel);
      }
      
      private static function sendPassword(param1:MouseEvent) : void
      {
         if(pswTxt.text == "")
         {
            Alarm.show("请输入你的米币帐户密码！");
            return;
         }
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeShort(count);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(MD5.hash(pswTxt.text));
         _loc3_.length = 32;
         SocketConnection.send(CommandID.MONEY_BUY_PRODUCT,productID,_loc2_,_loc3_);
         closePanel(null);
      }
   }
}

