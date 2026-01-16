package com.robot.core.display.tree
{
   import com.robot.core.effect.GlowTween;
   import com.robot.core.manager.*;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import org.taomee.component.control.MLoadPane;
   import org.taomee.manager.ResourceManager;
   
   public class TreeItem extends Sprite
   {
      
      private static var glowTween:GlowTween;
      
      private static var _addGlow:Boolean = false;
      
      public function TreeItem()
      {
         super();
      }
      
      private static function setTaskState(param1:*, param2:MovieClip) : void
      {
         var _loc3_:Number = 0;
         if(param1.isVip == "1")
         {
            _loc3_ = 4;
         }
         if(TasksManager.getTaskStatus(uint(param1.id)) == TasksManager.COMPLETE)
         {
            param2["taskstate"].gotoAndStop(4 + _loc3_);
         }
         else if(param1.newOnline == "1")
         {
            if(TasksManager.getTaskStatus(uint(param1.id)) == TasksManager.ALR_ACCEPT)
            {
               param2["taskstate"].gotoAndStop(2 + _loc3_);
            }
            else
            {
               param2["taskstate"].gotoAndStop(1 + _loc3_);
            }
         }
         else if(param1.offline == "1")
         {
            param2["taskstate"].gotoAndStop(3 + _loc3_);
         }
         else if(TasksManager.getTaskStatus(uint(param1.id)) == TasksManager.UN_ACCEPT)
         {
            param2["taskstate"].gotoAndStop(9);
         }
         else
         {
            param2["taskstate"].gotoAndStop(2 + _loc3_);
         }
      }
      
      public static function createItem(param1:*, param2:Boolean) : MovieClip
      {
         var _loc3_:MovieClip = null;
         _addGlow = param2;
         switch(uint(param1.itemtype))
         {
            case 1:
               _loc3_ = AssetsManager.getMovieClip("item1");
               break;
            case 2:
               _loc3_ = AssetsManager.getMovieClip("item2");
               break;
            case 3:
               _loc3_ = AssetsManager.getMovieClip("item3");
               setInfo3(_loc3_,param1);
               break;
            case 4:
               _loc3_ = AssetsManager.getMovieClip("item4");
               setInfo4(_loc3_,param1);
               setTaskState(param1,_loc3_);
               break;
            case 5:
               _loc3_ = AssetsManager.getMovieClip("item5");
               setInfo5(_loc3_,param1);
               setTaskState(param1,_loc3_);
               break;
            default:
               _loc3_ = AssetsManager.getMovieClip("item5");
               setInfo5(_loc3_,param1);
         }
         (_loc3_["bg"] as MovieClip).gotoAndStop(1);
         return _loc3_;
      }
      
      private static function setInfo3(param1:MovieClip, param2:*) : void
      {
         getStarIconByID(param2.starid,param1["icon"] as MovieClip);
         (param1["bg"] as MovieClip).gotoAndStop(1);
         (param1["titlename"] as TextField).htmlText = param2.name;
         (param1["star"] as MovieClip).gotoAndStop(uint(param2.starlevel) + 1);
         (param1["leveltxt"] as TextField).htmlText = param2.spanlevel;
         if(_addGlow)
         {
            param1["tip_mc"].visible = true;
         }
         else
         {
            param1["tip_mc"].visible = false;
         }
      }
      
      private static function setInfo4(param1:MovieClip, param2:*) : void
      {
         makeTaskIcon(param2.id,param1["icon"] as MovieClip);
         (param1["titletxt"] as TextField).htmlText = param2.name;
         (param1["star"] as MovieClip).gotoAndStop(uint(param2.starlevel) + 1);
         (param1["taskstate"] as MovieClip).gotoAndStop(1);
      }
      
      private static function setInfo5(param1:MovieClip, param2:*) : void
      {
         makeTaskIcon(param2.id,param1["icon"] as MovieClip);
         (param1["titletxt"] as TextField).htmlText = param2.name;
      }
      
      public static function getStarIconByID(param1:String, param2:MovieClip) : void
      {
         var _url:String = null;
         var id:String = param1;
         var iconContainer:MovieClip = param2;
         iconContainer.scaleX = 1;
         iconContainer.scaleY = 1;
         _url = "resource/planet/icon/" + id + ".swf";
         ResourceManager.getResource(_url,function(param1:DisplayObject):void
         {
            var _loc2_:MLoadPane = null;
            if(Boolean(param1))
            {
               _loc2_ = new MLoadPane(param1);
               if(param1.width > param1.height)
               {
                  _loc2_.fitType = MLoadPane.FIT_WIDTH;
               }
               else
               {
                  _loc2_.fitType = MLoadPane.FIT_HEIGHT;
               }
               _loc2_.setSizeWH(40,40);
               iconContainer.addChild(_loc2_);
            }
         },"star");
      }
      
      private static function makeTaskIcon(param1:String, param2:MovieClip) : void
      {
         var taskID:String = param1;
         var iconContainer:MovieClip = param2;
         var url:String = "resource/task/icon/" + taskID + ".swf";
         ResourceManager.getResource(url,function(param1:DisplayObject):void
         {
            if(Boolean(param1))
            {
               param1.scaleX = 0.5;
               param1.scaleY = 0.5;
               iconContainer.addChild(param1);
            }
         },"item");
      }
   }
}

