package org.taomee.component.manager
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import org.taomee.utils.DisplayUtil;
   
   public class PopUpManager
   {
      
      public static const TOP_LEFT:int = 0;
      
      public static const TOP_RIGHT:int = 1;
      
      public static const BOTTOM_LEFT:int = 2;
      
      public static const BOTTOM_RIGHT:int = 3;
      
      public static var container:DisplayObjectContainer = MComponentManager.stage;
      
      public function PopUpManager()
      {
         super();
      }
      
      public static function showForDisplayObject(param1:DisplayObject, param2:DisplayObject, param3:int = 0, param4:Boolean = true, param5:Point = null) : void
      {
         var obj:DisplayObject = param1;
         var forObj:DisplayObject = param2;
         var align:int = param3;
         var isForObjRange:Boolean = param4;
         var offset:Point = param5;
         var p:Point = null;
         if(Boolean(offset))
         {
            p = forObj.localToGlobal(offset);
         }
         else
         {
            p = forObj.localToGlobal(new Point());
         }
         switch(align)
         {
            case TOP_LEFT:
               obj.x = p.x - obj.width;
               obj.y = p.y - obj.height;
               break;
            case TOP_RIGHT:
               if(isForObjRange)
               {
                  obj.x = p.x + forObj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               obj.y = p.y - obj.height;
               break;
            case BOTTOM_LEFT:
               obj.x = p.x - obj.width;
               if(isForObjRange)
               {
                  obj.y = p.y + forObj.height;
                  break;
               }
               obj.y = p.y;
               break;
            case BOTTOM_RIGHT:
               if(isForObjRange)
               {
                  obj.x = p.x + forObj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               if(isForObjRange)
               {
                  obj.y = p.y + forObj.height;
               }
               else
               {
                  obj.y = p.y;
               }
         }
         container.addChild(obj);
         container.stage.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):void
         {
            if(!obj.hitTestPoint(param1.stageX,param1.stageY) && !forObj.hitTestPoint(param1.stageX,param1.stageY))
            {
               container.stage.removeEventListener(MouseEvent.MOUSE_DOWN,arguments.callee);
               DisplayUtil.removeForParent(obj);
            }
         });
      }
      
      public static function showForMouse(param1:DisplayObject, param2:int = 0, param3:int = 0, param4:int = 0) : void
      {
         var obj:DisplayObject = param1;
         var align:int = param2;
         var offx:int = param3;
         var offy:int = param4;
         var p:Point = new Point(MComponentManager.stage.mouseX + offx,MComponentManager.stage.mouseY + offy);
         switch(align)
         {
            case TOP_LEFT:
               if(p.x > obj.width)
               {
                  obj.x = p.x - obj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               if(p.y > obj.height)
               {
                  obj.y = p.y - obj.height;
                  break;
               }
               obj.y = p.y;
               break;
            case TOP_RIGHT:
               if(p.x + obj.width > MComponentManager.stage.stageWidth)
               {
                  obj.x = p.x - obj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               if(p.y > obj.height)
               {
                  obj.y = p.y - obj.height;
                  break;
               }
               obj.y = p.y;
               break;
            case BOTTOM_LEFT:
               if(p.x > obj.width)
               {
                  obj.x = p.x - obj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               if(p.y + obj.height > MComponentManager.stageHeight)
               {
                  obj.y = p.y - obj.height;
                  break;
               }
               obj.y = p.y;
               break;
            case BOTTOM_RIGHT:
               if(p.x + obj.width > MComponentManager.stageWidth)
               {
                  obj.x = p.x - obj.width;
               }
               else
               {
                  obj.x = p.x;
               }
               if(p.y + obj.height > MComponentManager.stageHeight)
               {
                  obj.y = p.y - obj.height;
               }
               else
               {
                  obj.y = p.y;
               }
         }
         container.addChild(obj);
         container.stage.addEventListener(MouseEvent.MOUSE_DOWN,function(param1:MouseEvent):void
         {
            if(!obj.hitTestPoint(param1.stageX,param1.stageY))
            {
               container.stage.removeEventListener(MouseEvent.MOUSE_DOWN,arguments.callee);
               DisplayUtil.removeForParent(obj);
            }
         });
      }
   }
}

