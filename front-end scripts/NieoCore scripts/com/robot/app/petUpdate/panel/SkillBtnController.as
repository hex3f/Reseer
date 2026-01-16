package com.robot.app.petUpdate.panel
{
   import com.robot.core.info.pet.PetSkillInfo;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   
   public class SkillBtnController extends EventDispatcher
   {
      
      public static const CLICK:String = "click";
      
      private var mc:Sprite;
      
      private var _skillID:uint;
      
      private var redFilter:GlowFilter = new GlowFilter(16711680,0.8,5,5,2);
      
      public function SkillBtnController(param1:Sprite, param2:PetSkillInfo)
      {
         super();
         this.mc = param1;
         this._skillID = param2.id;
         param1.addEventListener(MouseEvent.CLICK,this.clickHandler);
      }
      
      public function get skillID() : uint
      {
         return this._skillID;
      }
      
      public function checkIsOwner(param1:SkillBtnController) : void
      {
         if(param1 == this)
         {
            this.mc.filters = [this.redFilter];
         }
         else
         {
            this.mc.filters = [];
         }
      }
      
      private function clickHandler(param1:MouseEvent) : void
      {
         dispatchEvent(new Event(CLICK));
      }
   }
}

