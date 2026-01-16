package com.robot.app.bag
{
   import com.robot.core.config.xml.DoodleXMLInfo;
   import com.robot.core.info.clothInfo.PeopleItemInfo;
   import com.robot.core.info.item.ClothData;
   import com.robot.core.info.item.ClothInfo;
   import com.robot.core.mode.ISkeletonSprite;
   import com.robot.core.skeleton.ClothPreview;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.DisplayUtil;
   
   public class BagClothPreview extends ClothPreview
   {
      
      public function BagClothPreview(param1:Sprite, param2:ISkeletonSprite = null, param3:uint = 0)
      {
         super(param1,param2,param3);
      }
      
      override protected function initChangeCloth() : void
      {
         var _loc1_:* = null;
         var _loc2_:BagChangeClothAction = null;
         for each(_loc1_ in flagArray)
         {
            _loc2_ = new BagChangeClothAction(people,mcObj[_loc1_],_loc1_,model);
            changeClothActObj[_loc1_] = _loc2_;
         }
      }
      
      public function showCloth(param1:uint, param2:uint) : void
      {
         var _loc3_:BagChangeClothAction = null;
         var _loc4_:ClothData = ClothInfo.getItemInfo(param1);
         _loc3_ = changeClothActObj[_loc4_.type];
         _loc3_.changeClothByPath(param1,_loc4_.getPrevUrl(param2));
      }
      
      public function showCloths(param1:Array) : void
      {
         var _loc2_:PeopleItemInfo = null;
         takeOffCloth();
         for each(_loc2_ in param1)
         {
            this.showCloth(_loc2_.id,_loc2_.level);
         }
      }
      
      public function getChangeClothAct(param1:String) : BagChangeClothAction
      {
         return changeClothActObj[param1];
      }
      
      public function showDoodle(param1:uint) : void
      {
         var url:String = null;
         var texture:uint = param1;
         DisplayUtil.removeAllChild(doodleMC);
         url = DoodleXMLInfo.getPrevURL(texture);
         if(url == "")
         {
            return;
         }
         ResourceManager.getResource(url,function(param1:DisplayObject):void
         {
            param1.x = 3;
            param1.y = 14;
            doodleMC.addChild(param1);
         });
      }
   }
}

