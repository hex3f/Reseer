package com.robot.petFightModule.ui
{
   public class FightToolSubject
   {
      
      private var array:Array = [];
      
      public function FightToolSubject()
      {
         super();
      }
      
      public function showFightPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.showFight();
         }
      }
      
      public function openPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.open();
         }
      }
      
      public function showItemPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.showItem();
         }
      }
      
      public function showCatchItemPanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.showCatchItem();
         }
      }
      
      public function showPetPanel(param1:Boolean = false) : void
      {
         var _loc2_:IFightToolPanel = null;
         for each(_loc2_ in this.array)
         {
            _loc2_.showPet(param1);
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.destroy();
         }
         this.array = [];
      }
      
      public function del(param1:IFightToolPanel) : void
      {
         var _loc2_:int = int(this.array.indexOf(param1));
         if(_loc2_ != -1)
         {
            this.array.splice(_loc2_,1);
         }
      }
      
      public function closePanel() : void
      {
         var _loc1_:IFightToolPanel = null;
         for each(_loc1_ in this.array)
         {
            _loc1_.close();
         }
      }
      
      public function registe(... rest) : void
      {
         var _loc2_:IFightToolPanel = null;
         for each(_loc2_ in rest)
         {
            this.array.push(_loc2_);
         }
      }
   }
}

