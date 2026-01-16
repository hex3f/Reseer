package component.toolTip
{
   import flash.accessibility.AccessibilityProperties;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   
   public class ToolTip extends Sprite
   {
      
      private static var instance:ToolTip = null;
      
      private var label:TextField;
      
      private var area:DisplayObject;
      
      public function ToolTip()
      {
         super();
         this.label = new TextField();
         this.label.autoSize = TextFieldAutoSize.LEFT;
         this.label.selectable = false;
         this.label.multiline = false;
         this.label.wordWrap = false;
         this.label.defaultTextFormat = new TextFormat("宋体",12,6710886);
         this.label.text = "提示信息";
         this.label.x = 5;
         this.label.y = 2;
         addChild(this.label);
         this.redraw();
         visible = false;
         mouseEnabled = mouseChildren = false;
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         if(instance == null)
         {
            instance = new ToolTip();
            param1.addChild(instance);
         }
      }
      
      public static function register(param1:DisplayObject, param2:String) : void
      {
         var _loc3_:AccessibilityProperties = null;
         if(instance != null)
         {
            _loc3_ = new AccessibilityProperties();
            _loc3_.description = param2;
            param1.accessibilityProperties = _loc3_;
            param1.addEventListener(MouseEvent.MOUSE_OVER,instance.handler);
         }
      }
      
      public static function unregister(param1:DisplayObject) : void
      {
         if(instance != null)
         {
            param1.removeEventListener(MouseEvent.MOUSE_OVER,instance.handler);
         }
      }
      
      public function move(param1:Point) : void
      {
         var _loc2_:Point = this.parent.globalToLocal(param1);
         this.x = _loc2_.x - 6;
         this.y = _loc2_.y - this.label.height - 12;
         if(!visible)
         {
            visible = true;
         }
      }
      
      public function hide() : void
      {
         this.area.removeEventListener(MouseEvent.MOUSE_OUT,this.handler);
         this.area.removeEventListener(MouseEvent.MOUSE_MOVE,this.handler);
         this.area = null;
         visible = false;
      }
      
      private function redraw() : void
      {
         var _loc1_:Number = 10 + this.label.width;
         var _loc2_:Number = 4 + this.label.height;
         this.graphics.clear();
         this.graphics.beginFill(0,0.4);
         this.graphics.drawRoundRect(3,3,_loc1_,_loc2_,5,5);
         this.graphics.moveTo(6,3 + _loc2_);
         this.graphics.lineTo(12,3 + _loc2_);
         this.graphics.lineTo(9,8 + _loc2_);
         this.graphics.lineTo(6,3 + _loc2_);
         this.graphics.endFill();
         this.graphics.beginFill(16777215);
         this.graphics.drawRoundRect(0,0,_loc1_,_loc2_,5,5);
         this.graphics.moveTo(3,_loc2_);
         this.graphics.lineTo(9,_loc2_);
         this.graphics.lineTo(6,5 + _loc2_);
         this.graphics.lineTo(3,_loc2_);
         this.graphics.endFill();
      }
      
      private function handler(param1:MouseEvent) : void
      {
         switch(param1.type)
         {
            case MouseEvent.MOUSE_OUT:
               this.hide();
               break;
            case MouseEvent.MOUSE_MOVE:
               this.move(new Point(param1.stageX,param1.stageY));
               break;
            case MouseEvent.MOUSE_OVER:
               this.show(param1.target as DisplayObject);
               this.move(new Point(param1.stageX,param1.stageY));
         }
      }
      
      public function show(param1:DisplayObject) : void
      {
         this.area = param1;
         this.area.addEventListener(MouseEvent.MOUSE_OUT,this.handler);
         this.area.addEventListener(MouseEvent.MOUSE_MOVE,this.handler);
         this.label.text = param1.accessibilityProperties.description;
         this.redraw();
      }
   }
}

