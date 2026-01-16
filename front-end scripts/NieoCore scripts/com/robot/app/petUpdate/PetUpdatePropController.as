package com.robot.app.petUpdate
{
   import com.robot.app.experienceShared.ExperienceSharedModel;
   import com.robot.app.petUpdate.updatePanel.UpdatePropManager;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.update.PetUpdatePropInfo;
   import com.robot.core.info.pet.update.UpdatePropInfo;
   import com.robot.core.manager.PetManager;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.text.TextField;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class PetUpdatePropController
   {
      
      public static var owner:PetUpdatePropController;
      
      public static var addPer:uint;
      
      public static var addition:Number;
      
      private var panel:MovieClip;
      
      private var expMC:MovieClip;
      
      private var expTxt:TextField;
      
      private var txtArray:Array = [];
      
      private var arrowArray:Array = [];
      
      private var iconMC:Sprite;
      
      private var infoArray:Array = [];
      
      private var btn:SimpleButton;
      
      private var bmp:Bitmap;
      
      public function PetUpdatePropController()
      {
         super();
         owner = this;
         EventManager.addEventListener(PetFightEvent.PET_UPDATE_PROP,this.onFightClose);
      }
      
      public function setup(param1:PetUpdatePropInfo) : void
      {
         var _loc2_:UpdatePropInfo = null;
         var _loc3_:* = 0;
         addition = param1.addition;
         addPer = param1.addPer;
         this.infoArray = param1.dataArray.slice();
         for each(_loc2_ in this.infoArray)
         {
            _loc3_ = uint(PetXMLInfo.getEvolvingLv(_loc2_.id));
            if(PetXMLInfo.getTypeCN(_loc2_.id) == "机械")
            {
               if(_loc2_.level >= _loc3_ && _loc3_ != 0)
               {
                  Alarm.show("你的精灵已经达到了进化等级，现在可以在实验室的精灵进化仓里进行进化了。");
               }
            }
         }
         if(ExperienceSharedModel.isGetExp)
         {
            this.show();
         }
         ExperienceSharedModel.isGetExp = false;
      }
      
      private function onFightClose(param1:PetFightEvent) : void
      {
         this.bmp = param1.dataObj as Bitmap;
         if(this.infoArray.length == 0)
         {
            DisplayUtil.removeForParent(this.bmp);
            this.bmp = null;
            PetManager.upDate();
            return;
         }
         this.show();
      }
      
      public function show(param1:Boolean = false, param2:Boolean = true) : void
      {
         var _loc3_:PetInfo = null;
         var _loc4_:UpdatePropInfo = this.infoArray.shift() as UpdatePropInfo;
         if(param2)
         {
            _loc3_ = PetManager.getPetInfo(_loc4_.catchTime);
         }
         else
         {
            _loc3_ = PetManager.curEndPetInfo;
         }
         UpdatePropManager.update(_loc4_,_loc3_,this.closeHandler,param1);
      }
      
      private function closeHandler() : void
      {
         if(this.infoArray.length > 0)
         {
            this.show();
         }
         else
         {
            this.infoArray = [];
            if(PetUpdateSkillController.infoArray.length > 0)
            {
               EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.PET_UPDATE_SKILL,this.bmp));
            }
            else
            {
               if(Boolean(this.bmp))
               {
               }
               DisplayUtil.removeForParent(this.bmp);
            }
            PetManager.upDate();
            this.bmp = null;
         }
      }
   }
}

