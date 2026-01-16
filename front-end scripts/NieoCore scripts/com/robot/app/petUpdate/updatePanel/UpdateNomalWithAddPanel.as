package com.robot.app.petUpdate.updatePanel
{
   import com.robot.app.petUpdate.PetUpdatePropController;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.config.xml.PetXMLInfo;
   import com.robot.core.info.pet.PetInfo;
   import com.robot.core.info.pet.update.UpdatePropInfo;
   import com.robot.core.manager.UIManager;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.manager.ResourceManager;
   
   public class UpdateNomalWithAddPanel extends UpdateNomalPanel
   {
      
      public function UpdateNomalWithAddPanel()
      {
         super();
      }
      
      override protected function initUI() : void
      {
         panel = UIManager.getMovieClip("ui_PetUpdateNormalWithAddPanel");
         iconMC = new Sprite();
         iconMC.x = 188;
         iconMC.y = 170;
         iconMC.scaleX = iconMC.scaleY = 0.9;
         panel.addChild(iconMC);
         addChild(panel);
         btn = panel["okBtn"];
         btn.addEventListener(MouseEvent.CLICK,clickHandler);
      }
      
      override public function setInfo(param1:UpdatePropInfo, param2:PetInfo) : void
      {
         if(PetUpdatePropController.addPer == 10)
         {
            panel["txt"].text = "赛尔精灵获得经验：";
            panel["txt1"].text = "NoNo加成经验：";
            panel["txt2"].text = "离升级还需经验：";
            panel["nonoMC"].gotoAndStop(2);
         }
         else
         {
            panel["txt"].text = "赛尔精灵获得经验：";
            panel["txt1"].text = "超能NoNo加成经验：";
            panel["txt2"].text = "离升级还需经验：";
            panel["nonoMC"].gotoAndStop(1);
         }
         var _loc3_:Number = PetUpdatePropController.addition;
         var _loc4_:uint = Math.floor((param1.exp - param2.exp) / (1 + _loc3_));
         panel["add_txt"].text = "EXP+" + PetUpdatePropController.addPer + "%";
         panel["seer_exp_txt"].text = _loc4_.toString();
         panel["nono_exp_txt"].text = param1.exp - param2.exp - _loc4_;
         panel["up_exp_txt"].text = param1.nextLvExp - param1.exp;
         panel["total_exp_txt"].text = param1.exp - param2.exp;
         panel["name_txt"].text = PetXMLInfo.getName(param2.id);
         ResourceManager.getResource(ClientConfig.getPetSwfPath(param1.id),onLevelComplete,"pet");
      }
   }
}

