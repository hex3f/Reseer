package com.robot.app.fightLevel
{
   import org.taomee.utils.DisplayUtil;
   
   public class FightPetBagController
   {
      
      private static var _panel:FightPetBagPanel;
      
      public function FightPetBagController()
      {
         super();
      }
      
      public static function get panel() : FightPetBagPanel
      {
         if(_panel == null)
         {
            _panel = new FightPetBagPanel();
         }
         return _panel;
      }
      
      public static function show() : void
      {
         if(DisplayUtil.hasParent(panel))
         {
            panel.hide();
         }
         else
         {
            panel.show();
         }
      }
      
      public static function destroy() : void
      {
         if(Boolean(_panel))
         {
            _panel.destroy();
            _panel = null;
         }
      }
   }
}

