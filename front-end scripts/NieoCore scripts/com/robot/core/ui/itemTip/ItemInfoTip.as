package com.robot.core.ui.itemTip
{
   import com.robot.core.config.xml.ItemTipXMLInfo;
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import org.taomee.component.UIComponent;
   import org.taomee.component.bgFill.SoildFillStyle;
   import org.taomee.component.containers.Canvas;
   import org.taomee.component.containers.HBox;
   import org.taomee.component.containers.VBox;
   import org.taomee.component.control.MLabel;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.component.control.MText;
   import org.taomee.component.layout.CenterLayout;
   import org.taomee.component.layout.FitSizeLayout;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.utils.DisplayUtil;
   
   public class ItemInfoTip
   {
      
      private static var tipMC:Canvas;
      
      private static var box:HBox;
      
      private static var txtBox:VBox;
      
      private static var iconPanel:MLoadPane;
      
      private static var _info:SingleItemInfo;
      
      public function ItemInfoTip()
      {
         super();
      }
      
      public static function show(param1:SingleItemInfo, param2:Boolean = false, param3:DisplayObjectContainer = null) : void
      {
         _info = param1;
         if(!tipMC)
         {
            tipMC = new Canvas();
            tipMC.layout = new CenterLayout();
            tipMC.bgFillStyle = new SoildFillStyle(0,0.8,20,20);
            box = new HBox(10);
            box.valign = FlowLayout.TOP;
            iconPanel = new MLoadPane(null,MLoadPane.FIT_HEIGHT);
            iconPanel.setSizeWH(80,80);
            txtBox = new VBox();
         }
         txtBox.removeAll();
         iconPanel.setIcon(ItemXMLInfo.getIconURL(param1.itemID,param1.itemLevel));
         var _loc4_:UIComponent = getTitleBox();
         var _loc5_:UIComponent = getPetBox();
         var _loc6_:UIComponent = getTeamPKBox();
         var _loc7_:UIComponent = getDesBox();
         txtBox.appendAll(_loc4_,_loc5_,_loc6_,_loc7_);
         txtBox.setSizeWH(160,_loc4_.height + _loc5_.height + _loc6_.height + _loc7_.height + 3 * box.gap);
         box.appendAll(iconPanel,txtBox);
         box.setSizeWH(240 + box.gap,Math.max(txtBox.height,iconPanel.height));
         tipMC.setSizeWH(box.width + 20,box.height + 20);
         tipMC.append(box);
         if(Boolean(param3))
         {
            param3.addChild(tipMC);
         }
         else
         {
            LevelManager.appLevel.addChild(tipMC);
         }
         tipMC.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
      }
      
      public static function hide() : void
      {
         if(Boolean(tipMC))
         {
            tipMC.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
            DisplayUtil.removeForParent(tipMC);
         }
      }
      
      private static function enterFrameHandler(param1:Event) : void
      {
         if(MainManager.getStage().mouseX + tipMC.width + 20 >= MainManager.getStageWidth())
         {
            tipMC.x = MainManager.getStageWidth() - tipMC.width - 10;
         }
         else
         {
            tipMC.x = MainManager.getStage().mouseX + 10;
         }
         if(MainManager.getStage().mouseY + tipMC.height + 20 >= MainManager.getStageHeight())
         {
            tipMC.y = MainManager.getStageHeight() - tipMC.height - 10;
         }
         else
         {
            tipMC.y = MainManager.getStage().mouseY + 20;
         }
      }
      
      private static function getTitleBox() : HBox
      {
         var _loc1_:HBox = null;
         _loc1_ = new HBox();
         var _loc2_:MLabel = new MLabel();
         _loc2_.fontSize = 14;
         var _loc3_:String = ItemXMLInfo.getName(_info.itemID);
         var _loc4_:String = ItemTipXMLInfo.getItemColor(_info.itemID);
         _loc2_.htmlText = "<font color=\'" + _loc4_ + "\'>" + _loc3_ + "</font>";
         _loc2_.width = 160;
         _loc2_.blod = true;
         _loc1_.setSizeWH(160,_loc2_.height);
         _loc1_.append(_loc2_);
         return _loc1_;
      }
      
      private static function getPetBox() : Canvas
      {
         var _loc1_:MText = null;
         _loc1_ = null;
         var _loc2_:String = ItemTipXMLInfo.getPetDes(_info.itemID,_info.itemLevel);
         var _loc3_:Canvas = new Canvas();
         _loc3_.layout = new FitSizeLayout();
         if(_loc2_ != "")
         {
            _loc1_ = new MText();
            _loc1_.fontSize = 12;
            _loc1_.width = 160;
            _loc1_.selectable = false;
            _loc1_.textColor = 16776960;
            _loc1_.text = "精灵属性：\r" + _loc2_;
            _loc3_.setSizeWH(160,_loc1_.textField.height);
            _loc3_.append(_loc1_);
         }
         return _loc3_;
      }
      
      private static function getTeamPKBox() : Canvas
      {
         var _loc1_:MText = null;
         var _loc2_:String = ItemTipXMLInfo.getTeamPKDes(_info.itemID,_info.itemLevel);
         var _loc3_:Canvas = new Canvas();
         _loc3_.layout = new FitSizeLayout();
         if(_loc2_ != "")
         {
            _loc1_ = new MText();
            _loc1_.fontSize = 12;
            _loc1_.width = 160;
            _loc1_.selectable = false;
            _loc1_.textColor = 16777215;
            _loc1_.text = "要塞保卫战：\r" + _loc2_;
            _loc3_.setSizeWH(160,_loc1_.textField.height);
            _loc3_.append(_loc1_);
         }
         return _loc3_;
      }
      
      private static function getDesBox() : Canvas
      {
         var _loc1_:MText = null;
         var _loc2_:String = ItemTipXMLInfo.getItemDes(_info.itemID);
         var _loc3_:Canvas = new Canvas();
         _loc3_.layout = new FitSizeLayout();
         if(_loc2_ != "")
         {
            _loc1_ = new MText();
            _loc1_.fontSize = 12;
            _loc1_.width = 160;
            _loc1_.selectable = false;
            _loc1_.textColor = 10092288;
            _loc1_.text = "用途：\r" + _loc2_;
            _loc3_.setSizeWH(160,_loc1_.textField.height);
            _loc3_.append(_loc1_);
         }
         return _loc3_;
      }
   }
}

