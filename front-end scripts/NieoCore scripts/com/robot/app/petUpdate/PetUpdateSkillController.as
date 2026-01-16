package com.robot.app.petUpdate
{
   import com.robot.app.petUpdate.updatePanel.UpdateSkillManager;
   import com.robot.core.event.PetFightEvent;
   import com.robot.core.info.pet.update.PetUpdateSkillInfo;
   import com.robot.core.info.pet.update.UpdateSkillInfo;
   import com.robot.core.manager.PetManager;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import org.taomee.manager.EventManager;
   import org.taomee.utils.DisplayUtil;
   
   public class PetUpdateSkillController
   {
      
      public static var infoArray:Array = [];
      
      private var panel:MovieClip;
      
      private var petIcon:Sprite;
      
      private var okBtn:SimpleButton;
      
      private var closeBtn:SimpleButton;
      
      private var filter:GlowFilter = new GlowFilter(16776960,0.8,5,5,2);
      
      private var redFilter:GlowFilter = new GlowFilter(16711680,0.8,5,5,2);
      
      private var appendIndex:uint = 0;
      
      private var btnArray:Array = [];
      
      private var appendArray:Array = [];
      
      private var activeArray:Array = [];
      
      private var appendClone:Array = [];
      
      private var activeClone:Array = [];
      
      private var selectedBtn:MovieClip;
      
      private var currentUpdateInfo:UpdateSkillInfo;
      
      private var bmp:Bitmap;
      
      private var dropArray:Array = [];
      
      private var studyArray:Array = [];
      
      public function PetUpdateSkillController()
      {
         super();
         EventManager.addEventListener(PetFightEvent.PET_UPDATE_SKILL,this.onPetUpdateSkill);
      }
      
      private function onPetUpdateSkill(param1:PetFightEvent) : void
      {
         this.bmp = param1.dataObj as Bitmap;
         if(infoArray.length > 0)
         {
            this.show();
         }
         else
         {
            if(Boolean(this.bmp))
            {
               this.bmp.parent.removeChild(this.bmp);
            }
            this.bmp = null;
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.BATTLE_OVER));
         }
      }
      
      public function setup(param1:PetUpdateSkillInfo) : void
      {
         infoArray = [];
         infoArray = infoArray.concat(param1.infoArray);
      }
      
      private function show() : void
      {
         var _loc1_:UpdateSkillInfo = infoArray.shift() as UpdateSkillInfo;
         UpdateSkillManager.update(_loc1_,this.closeHandler);
      }
      
      private function closeHandler() : void
      {
         if(infoArray.length > 0)
         {
            this.show();
         }
         else
         {
            DisplayUtil.removeForParent(this.bmp);
            PetManager.upDate();
            EventManager.dispatchEvent(new PetFightEvent(PetFightEvent.BATTLE_OVER));
            this.bmp = null;
         }
      }
   }
}

