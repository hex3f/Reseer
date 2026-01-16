package com.robot.app.bag
{
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.manager.MainManager;
   import com.robot.core.mode.ISkeletonSprite;
   import com.robot.core.skeleton.ChangeClothAction;
   import com.robot.core.skeleton.ClothPreview;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.events.DynamicEvent;
   
   public class BagChangeClothAction extends ChangeClothAction
   {
      
      public static const TAKE_OFF_CLOTH:String = "takeOffCloth";
      
      public static const REPLACE_CLOTH:String = "replaceCloth";
      
      public static const USE_CLOTH:String = "useCloth";
      
      public static const CLOTH_CHANGE:String = "bagClothChange";
      
      public function BagChangeClothAction(param1:ISkeletonSprite, param2:Sprite, param3:String, param4:uint)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function unloadCloth(param1:MouseEvent) : void
      {
         var _loc2_:* = 0;
         if(clothID == ClothInfo.DEFAULT_FOOT || clothID == ClothInfo.DEFAULT_HEAD || clothID == ClothInfo.DEFAULT_WAIST)
         {
            return;
         }
         if(Boolean(clothSWF))
         {
            clothSWF.parent.removeChild(clothSWF);
            clothSWF = null;
            MainManager.actorModel.dispatchEvent(new DynamicEvent(BagChangeClothAction.TAKE_OFF_CLOTH,clothID));
            clothID = 0;
            MainManager.actorModel.dispatchEvent(new Event(BagChangeClothAction.CLOTH_CHANGE));
         }
         if(type == ClothPreview.FLAG_HEAD)
         {
            _loc2_ = uint(ClothInfo.DEFAULT_HEAD);
         }
         else if(type == ClothPreview.FLAG_FOOT)
         {
            _loc2_ = uint(ClothInfo.DEFAULT_FOOT);
         }
         else
         {
            if(type != ClothPreview.FLAG_WAIST)
            {
               return;
            }
            _loc2_ = uint(ClothInfo.DEFAULT_WAIST);
         }
         var _loc3_:String = ClothInfo.getItemInfo(_loc2_).getPrevUrl();
         this.changeClothByPath(_loc2_,_loc3_);
      }
      
      override public function changeCloth(param1:PeopleItemInfo, param2:uint = 0) : void
      {
         if(this.clothID != 0 && this.clothID != ClothInfo.DEFAULT_FOOT && this.clothID != ClothInfo.DEFAULT_HEAD && this.clothID != ClothInfo.DEFAULT_WAIST)
         {
            if(Boolean(MainManager.actorModel))
            {
               MainManager.actorModel.dispatchEvent(new DynamicEvent(REPLACE_CLOTH,this.clothID));
            }
         }
         else if(Boolean(MainManager.actorModel))
         {
            MainManager.actorModel.dispatchEvent(new DynamicEvent(USE_CLOTH,this.clothID));
         }
         this.clothID = param1.id;
         beginLoad();
         if(Boolean(MainManager.actorModel))
         {
            MainManager.actorModel.dispatchEvent(new Event(BagChangeClothAction.CLOTH_CHANGE));
         }
      }
      
      override public function changeClothByPath(param1:int, param2:String) : void
      {
         if(!(param1 == ClothInfo.DEFAULT_FOOT || param1 == ClothInfo.DEFAULT_HEAD || param1 == ClothInfo.DEFAULT_WAIST))
         {
            if(this.clothID != 0 && this.clothID != ClothInfo.DEFAULT_FOOT && this.clothID != ClothInfo.DEFAULT_HEAD && this.clothID != ClothInfo.DEFAULT_WAIST)
            {
               if(Boolean(MainManager.actorModel))
               {
                  MainManager.actorModel.dispatchEvent(new DynamicEvent(REPLACE_CLOTH,this.clothID));
               }
            }
            else if(Boolean(MainManager.actorModel))
            {
               MainManager.actorModel.dispatchEvent(new DynamicEvent(USE_CLOTH,this.clothID));
            }
         }
         this.clothID = param1;
         beginLoad(param2);
         if(Boolean(MainManager.actorModel))
         {
            MainManager.actorModel.dispatchEvent(new Event(BagChangeClothAction.CLOTH_CHANGE));
         }
      }
   }
}

