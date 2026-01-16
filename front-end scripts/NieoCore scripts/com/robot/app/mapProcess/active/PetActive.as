package com.robot.app.mapProcess.active
{
   import com.robot.app.mapProcess.active.iActive.IPetActive;
   import flash.display.MovieClip;
   import org.taomee.utils.DisplayUtil;
   
   public class PetActive implements IPetActive
   {
      
      public var petID:uint;
      
      public var pet:MovieClip;
      
      public function PetActive()
      {
         super();
      }
      
      public function show() : void
      {
      }
      
      public function hide() : void
      {
         if(Boolean(this.pet))
         {
            DisplayUtil.removeForParent(this.pet,false);
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this.pet))
         {
            DisplayUtil.removeForParent(this.pet);
            this.pet = null;
         }
      }
   }
}

