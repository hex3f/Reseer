package com.robot.app.help
{
   import com.robot.app.newspaper.ContributeAlert;
   import com.robot.app.task.petstory.app.train.TrainGradePanel;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.HelpXMLInfo;
   import com.robot.core.manager.*;
   import com.robot.core.mode.AppModel;
   import com.robot.core.ui.alert.Alarm;
   import com.robot.core.ui.alert.Alert;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class HelpManager
   {
      
      private static var panel:AppModel;
      
      public function HelpManager()
      {
         super();
      }
      
      public static function show(param1:uint) : void
      {
         var _loc2_:Array = HelpXMLInfo.getIdList();
         if(_loc2_.indexOf(param1) < 0)
         {
            Alarm.show("帮助XML配置ID错误。");
            return;
         }
         var _loc3_:uint = uint(HelpXMLInfo.getType(param1));
         switch(_loc3_)
         {
            case 0:
               showPanel(param1);
               break;
            case 1:
               showTalk(param1);
               break;
            case 2:
               showMes(param1);
               break;
            default:
               Alarm.show("帮助XML配置类型错误。");
         }
      }
      
      private static function showMes(param1:uint) : void
      {
         var _loc2_:uint = uint(HelpXMLInfo.getComment(param1));
         switch(_loc2_)
         {
            case 1:
               ContributeAlert.show(ContributeAlert.NEWS_TYPE);
               break;
            case 2:
               ContributeAlert.show(ContributeAlert.SHIPER_TYPE);
               break;
            case 3:
               ContributeAlert.show(ContributeAlert.DOCTOR_TYPE);
               break;
            case 4:
               ContributeAlert.show(ContributeAlert.NONO);
               break;
            case 5:
               ContributeAlert.show(ContributeAlert.LYMAN);
               break;
            case 6:
               new TrainGradePanel();
               break;
            default:
               Alarm.show("帮助XML配置写信错误");
         }
      }
      
      public static function nullPanel() : void
      {
         panel = null;
      }
      
      private static function showPanel(param1:uint) : void
      {
         var _loc2_:String = HelpXMLInfo.getComment(param1);
         var _loc3_:Array = HelpXMLInfo.getItemAry(param1);
         var _loc4_:Boolean = Boolean(HelpXMLInfo.getIsBack(param1));
         var _loc5_:Object = new Object();
         _loc5_.str = _loc2_;
         _loc5_.arr = _loc3_;
         _loc5_.isBack = _loc4_;
         if(panel == null)
         {
            panel = new AppModel(ClientConfig.getHelpModule("HelpListPanel"),"正在打开帮助信息");
            panel.setup();
            panel.init(_loc5_);
            panel.show();
         }
         else
         {
            panel.hide();
            panel.init(_loc5_);
            panel.show();
         }
      }
      
      private static function enterFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.currentFrame == 70)
         {
            _loc2_.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
            LevelManager.appLevel.removeChild(_loc2_);
         }
      }
      
      private static function arrowRot(param1:MovieClip, param2:Point) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Number = param2.x;
         var _loc5_:Number = param2.y;
         var _loc6_:Number = 480;
         var _loc7_:Number = 280;
         if(!(_loc4_ > 288 && _loc4_ < 711 && _loc5_ > 167 && _loc5_ < 405))
         {
            _loc3_ = int(Math.atan2(_loc5_ - _loc7_,_loc4_ - _loc6_) * 180 / Math.PI);
            param1.rotation = _loc3_ + 90;
         }
         param1.x = _loc4_;
         param1.y = _loc5_;
      }
      
      private static function showTalk(param1:uint) : void
      {
         var mapid:uint = 0;
         var id:uint = param1;
         mapid = 0;
         var point:Point = null;
         var myArrow:MovieClip = null;
         var str:String = null;
         mapid = uint(HelpXMLInfo.getMapId(id));
         if(!mapid || mapid == MainManager.actorInfo.mapID)
         {
            point = HelpXMLInfo.getArrowPoint(id);
            myArrow = AssetsManager.getMovieClip("HelpUI_Arrow");
            LevelManager.appLevel.addChild(myArrow);
            arrowRot(myArrow,point);
            myArrow.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
         }
         else
         {
            str = HelpXMLInfo.getComment(id);
            Alert.show(str,function():void
            {
               MapManager.changeMap(mapid);
            },null);
         }
      }
      
      public static function getType(param1:uint) : uint
      {
         return HelpXMLInfo.getType(param1);
      }
      
      public static function getObj(param1:uint) : Object
      {
         var _loc2_:String = HelpXMLInfo.getComment(param1);
         var _loc3_:Array = HelpXMLInfo.getItemAry(param1);
         var _loc4_:Boolean = Boolean(HelpXMLInfo.getIsBack(param1));
         var _loc5_:Object = new Object();
         _loc5_.str = _loc2_;
         _loc5_.arr = _loc3_;
         _loc5_.isBack = _loc4_;
         return _loc5_;
      }
      
      public static function getBack(param1:uint) : Boolean
      {
         return HelpXMLInfo.getIsBack(param1);
      }
   }
}

