package com.robot.petFightModule.ui.controlPanel.petItem.category
{
   import com.robot.core.CommandID;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.net.SocketConnection;
   import com.robot.petFightModule.control.FighterModeFactory;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import com.robot.petFightModule.view.BaseFighterPetWin;
   import flash.events.MouseEvent;
   import org.taomee.effect.ColorFilter;
   
   public class CatchPetItemCategory extends AbstractPetItemCategory implements IPetItemCategory
   {
      
      public function CatchPetItemCategory(param1:uint)
      {
         super(param1);
         var _loc2_:BaseFighterMode = FighterModeFactory.enemyMode;
         if(!_loc2_.catchable)
         {
            _sprite.filters = [ColorFilter.setGrayscale()];
            _sprite.mouseEnabled = false;
            _sprite.mouseChildren = false;
         }
      }
      
      override protected function useItem(param1:MouseEvent) : void
      {
         super.useItem(param1);
         SocketConnection.send(CommandID.CATCH_MONSTER,_itemID);
         BaseFighterPetWin.itemID = _itemID;
         --_itemNum;
         --ItemManager.getCollectionInfo(_itemID).itemNum;
         refreshInfo();
      }
   }
}

