package com.robot.core.ui.skillBtn
{
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   
   public class BlackSkillBtn extends NormalSkillBtn
   {
      
      public function BlackSkillBtn(param1:uint = 0, param2:int = -1)
      {
         super(param1,param2);
      }
      
      override protected function getMC() : MovieClip
      {
         return UIManager.getMovieClip("ui_PetUpdate_PetSkillBtn");
      }
   }
}

