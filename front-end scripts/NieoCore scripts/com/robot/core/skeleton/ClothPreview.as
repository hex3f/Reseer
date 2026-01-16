package com.robot.core.skeleton
{
   import com.robot.core.config.xml.ItemXMLInfo;
   import com.robot.core.event.RobotEvent;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.mode.BasePeoleModel;
   import com.robot.core.mode.ISkeletonSprite;
   import com.robot.core.utils.Direction;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import org.taomee.events.DynamicEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class ClothPreview
   {
      
      public static const MODEL_PEOPLE:uint = 0;
      
      public static const MODEL_SHOW:uint = 1;
      
      public static const FLAG_TOP:String = "top";
      
      public static const FLAG_HEAD:String = "head";
      
      public static const FLAG_EYE:String = "eye";
      
      public static const FLAG_HAND:String = "hand";
      
      public static const FLAG_HAND_1:String = "hand1";
      
      public static const FLAG_WAIST:String = "waist";
      
      public static const FLAG_DECORATOR:String = "decorator";
      
      public static const FLAG_FOOT:String = "foot";
      
      public static const FLAG_BG:String = "bg";
      
      public static const FLAG_COLOR:String = "color";
      
      private static const downRenderOrder:Array = [FLAG_HAND_1,FLAG_HAND,FLAG_EYE,FLAG_HEAD,FLAG_TOP];
      
      private static const upRenderOrder:Array = [FLAG_HAND_1,FLAG_HAND,FLAG_EYE,FLAG_HEAD,FLAG_TOP];
      
      private static const rightRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      private static const rightdownRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      private static const rightupRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      private static const leftRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      private static const leftdownRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      private static const leftupRenderOrder:Array = [FLAG_EYE,FLAG_HEAD,FLAG_TOP,FLAG_HAND_1,FLAG_HAND];
      
      protected var skeletonMC:MovieClip;
      
      protected var composeMC:Sprite;
      
      protected var colorMC:MovieClip;
      
      protected var doodleMC:MovieClip;
      
      protected var people:ISkeletonSprite;
      
      protected var mcObj:Object;
      
      protected var changeClothActObj:Object;
      
      protected var flagArray:Array;
      
      protected var model:uint;
      
      public function ClothPreview(param1:Sprite, param2:ISkeletonSprite = null, param3:uint = 0)
      {
         var _loc4_:* = null;
         this.mcObj = {};
         this.changeClothActObj = {};
         super();
         this.model = param3;
         this.people = param2;
         this.flagArray = this.getFlagArray();
         this.composeMC = param1;
         this.colorMC = this.composeMC[FLAG_COLOR];
         this.colorMC.gotoAndStop(1);
         this.doodleMC = this.composeMC[FLAG_DECORATOR];
         this.doodleMC.gotoAndStop(1);
         for each(_loc4_ in this.flagArray)
         {
            this.mcObj[_loc4_] = this.composeMC[_loc4_];
         }
         this.initChangeCloth();
      }
      
      public function getClothArray() : Array
      {
         var _loc1_:ChangeClothAction = null;
         var _loc2_:Array = [];
         var _loc3_:Array = new Array();
         for each(_loc1_ in this.changeClothActObj)
         {
            if(_loc1_.getClothID() > 0)
            {
               if(_loc3_.indexOf(_loc1_.getClothID()) == -1)
               {
                  _loc3_.push(_loc1_.getClothID());
                  _loc2_.push(new PeopleItemInfo(_loc1_.getClothID(),_loc1_.getClothLevel()));
               }
            }
         }
         return _loc2_;
      }
      
      public function getClothIDs() : Array
      {
         var _loc1_:PeopleItemInfo = null;
         var _loc2_:Array = [];
         var _loc3_:Array = this.getClothArray();
         for each(_loc1_ in _loc3_)
         {
            if(_loc2_.indexOf(_loc1_.id) == -1)
            {
               _loc2_.push(_loc1_.id);
            }
         }
         return _loc2_;
      }
      
      public function getClothStr() : String
      {
         var _loc1_:PeopleItemInfo = null;
         var _loc2_:Array = this.getClothArray();
         var _loc3_:Array = [];
         for each(_loc1_ in _loc2_)
         {
            if(_loc3_.indexOf(_loc1_.id) == -1)
            {
               _loc3_.push(_loc1_.id);
            }
         }
         return _loc3_.sort().join(",");
      }
      
      public function takeOffCloth() : void
      {
         var _loc1_:ChangeClothAction = null;
         for each(_loc1_ in this.changeClothActObj)
         {
            _loc1_.takeOffCloth();
         }
         if(Boolean(this.people))
         {
            (this.people as BasePeoleModel).removeEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
         }
      }
      
      protected function getFlagArray() : Array
      {
         return new Array(FLAG_TOP,FLAG_HEAD,FLAG_EYE,FLAG_HAND,FLAG_HAND_1,FLAG_WAIST,FLAG_DECORATOR,FLAG_FOOT,FLAG_BG);
      }
      
      public function changeCloth(param1:Array) : void
      {
         var _loc2_:PeopleItemInfo = null;
         var _loc3_:String = null;
         var _loc4_:ChangeClothAction = null;
         var _loc5_:ChangeClothAction = null;
         var _loc6_:ChangeClothAction = null;
         var _loc7_:Boolean = false;
         for each(_loc2_ in param1)
         {
            _loc3_ = ClothInfo.getItemInfo(_loc2_.id).type;
            if(_loc3_ == FLAG_HAND && ItemXMLInfo.isSpecialItem(_loc2_.id) && this.model == MODEL_PEOPLE)
            {
               _loc4_ = this.changeClothActObj[FLAG_HAND];
               _loc4_.changeCloth(_loc2_,1);
               _loc5_ = this.changeClothActObj[FLAG_HAND_1];
               _loc5_.changeCloth(_loc2_,2);
               _loc7_ = true;
            }
            else
            {
               _loc6_ = this.changeClothActObj[_loc3_];
               _loc6_.changeCloth(_loc2_);
            }
         }
         if(Boolean(this.people))
         {
            if(_loc7_)
            {
               (this.people as BasePeoleModel).addEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
            }
            else
            {
               (this.people as BasePeoleModel).removeEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
            }
         }
      }
      
      public function changeColor(param1:uint, param2:Boolean = true) : void
      {
         DisplayUtil.FillColor(this.colorMC,param1);
         if(param2)
         {
            DisplayUtil.removeAllChild(this.doodleMC);
         }
      }
      
      public function changeDoodle(param1:String) : void
      {
         var url:String = param1;
         DisplayUtil.removeAllChild(this.doodleMC);
         ResourceManager.getResource(url,function(param1:DisplayObject):void
         {
            if(Boolean(people))
            {
               (param1 as MovieClip).gotoAndStop(people.direction);
            }
            if(doodleMC != null)
            {
               doodleMC.addChild(param1);
            }
         });
      }
      
      protected function initChangeCloth() : void
      {
         var _loc1_:* = null;
         var _loc2_:ChangeClothAction = null;
         for each(_loc1_ in this.flagArray)
         {
            _loc2_ = new ChangeClothAction(this.people,this.mcObj[_loc1_],_loc1_,this.model);
            this.changeClothActObj[_loc1_] = _loc2_;
         }
      }
      
      private function onChangeDirHandler(param1:DynamicEvent) : void
      {
         switch(this.people.direction)
         {
            case Direction.DOWN:
               this.changeDeep(downRenderOrder);
               break;
            case Direction.UP:
               this.changeDeep(upRenderOrder);
               break;
            case Direction.RIGHT:
               this.changeDeep(rightRenderOrder);
               break;
            case Direction.RIGHT_DOWN:
               this.changeDeep(rightdownRenderOrder);
               break;
            case Direction.RIGHT_UP:
               this.changeDeep(rightupRenderOrder);
               break;
            case Direction.LEFT:
               this.changeDeep(leftRenderOrder);
               break;
            case Direction.LEFT_DOWN:
               this.changeDeep(leftdownRenderOrder);
               break;
            case Direction.LEFT_UP:
               this.changeDeep(leftupRenderOrder);
         }
      }
      
      private function changeDeep(param1:Array) : void
      {
         var _loc3_:Sprite = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = this.composeMC[param1[_loc2_]];
            this.composeMC.addChild(_loc3_);
            _loc2_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:ChangeClothAction = null;
         if(Boolean(this.people))
         {
            (this.people as BasePeoleModel).removeEventListener(RobotEvent.CHANGE_DIRECTION,this.onChangeDirHandler);
         }
         for each(_loc1_ in this.changeClothActObj)
         {
            _loc1_.destroy();
         }
         this.skeletonMC = null;
         this.composeMC = null;
         this.colorMC = null;
         this.doodleMC = null;
         this.people = null;
         this.mcObj = null;
         this.changeClothActObj = null;
      }
   }
}

