package org.taomee.component.tips
{
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   import flash.filters.DropShadowFilter;
   import flash.text.TextFormatAlign;
   import org.taomee.component.bgFill.SoildFillStyle;
   import org.taomee.component.containers.HBox;
   import org.taomee.component.control.MLabel;
   import org.taomee.component.layout.FlowLayout;
   import org.taomee.component.manager.MComponentManager;
   import org.taomee.component.manager.PopUpManager;
   import org.taomee.ds.HashMap;
   import org.taomee.utils.DisplayUtil;
   
   public class ToolTip
   {
      
      private static var box:HBox;
      
      private static var label:MLabel;
      
      private static var _cy:Number;
      
      private static var _cx:Number;
      
      private static var _listMap:HashMap;
      
      public function ToolTip()
      {
         super();
      }
      
      public static function add(param1:InteractiveObject, param2:String) : void
      {
         param1.addEventListener(MouseEvent.ROLL_OVER,onOver);
         param1.addEventListener(MouseEvent.ROLL_OUT,onOut);
         _listMap.add(param1,param2);
      }
      
      public static function remove(param1:InteractiveObject) : void
      {
         if(_listMap.containsKey(param1))
         {
            param1.removeEventListener(MouseEvent.ROLL_OVER,onOver);
            param1.removeEventListener(MouseEvent.ROLL_OUT,onOut);
            _listMap.remove(param1);
         }
         onFinishTween();
      }
      
      private static function onOut(param1:MouseEvent) : void
      {
         onFinishTween();
      }
      
      private static function onMove(param1:MouseEvent) : void
      {
         box.x = _cx + param1.stageX;
         box.y = _cy + param1.stageY;
      }
      
      private static function onOver(param1:MouseEvent) : void
      {
         var _loc2_:InteractiveObject = param1.currentTarget as InteractiveObject;
         label.htmlText = " " + _listMap.getValue(_loc2_);
         box.setSizeWH(label.width + 10,label.height + 4);
         box.append(label);
         box.cacheAsBitmap = true;
         MComponentManager.stage.addChild(box);
         PopUpManager.showForMouse(box,PopUpManager.BOTTOM_RIGHT,-12,20);
         _cx = box.x - param1.stageX;
         _cy = box.y - param1.stageY;
         MComponentManager.stage.addEventListener(MouseEvent.MOUSE_MOVE,onMove);
      }
      
      private static function onFinishTween() : void
      {
         DisplayUtil.removeForParent(box);
         MComponentManager.stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMove);
      }
      
      public static function setup() : void
      {
         _listMap = new HashMap();
         box = new HBox();
         box.filters = [new DropShadowFilter(3,45,0,0.6)];
         box.mouseEnabled = box.mouseChildren = false;
         box.valign = FlowLayout.MIDLLE;
         box.bgFillStyle = new SoildFillStyle(16116636,1,7,7);
         label = new MLabel();
         label.fontSize = 12;
         label.align = TextFormatAlign.CENTER;
         label.autoFitWidth = true;
      }
   }
}

