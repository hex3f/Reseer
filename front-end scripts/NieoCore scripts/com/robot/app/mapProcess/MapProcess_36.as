package com.robot.app.mapProcess
{
   import com.robot.app.ogre.*;
   import com.robot.core.config.xml.*;
   import com.robot.core.effect.*;
   import com.robot.core.manager.*;
   import com.robot.core.manager.map.config.BaseMapProcess;
   import com.robot.core.mode.PetModel;
   import com.robot.core.ui.alert.*;
   import flash.display.MovieClip;
   import flash.geom.*;
   import flash.utils.*;
   
   public class MapProcess_36 extends BaseMapProcess
   {
      
      private var count:uint = 0;
      
      public function MapProcess_36()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:uint = 0;
         OgreController.isShow = false;
         while(_loc1_ < 4)
         {
            conLevel["pillar_" + _loc1_].gotoAndStop(1);
            _loc1_++;
         }
         animatorLevel["lightMC"].gotoAndStop(1);
      }
      
      override public function destroy() : void
      {
         OgreController.isShow = true;
      }
      
      public function hitPillar(param1:MovieClip) : void
      {
         var effect:LightEffect = null;
         var model:PetModel = null;
         var id:uint = 0;
         var mc:MovieClip = param1;
         model = MainManager.actorModel.pet;
         var b:Boolean = true;
         if(!model)
         {
            b = false;
         }
         else
         {
            id = uint(model.info.petID);
            if(PetXMLInfo.getType(id) != "5")
            {
               b = false;
            }
         }
         if(!b)
         {
            Alarm.show("这根柱子缺少启动电能，带上<font color=\'#ff0000\'>电系精灵</font>或许能激活它。");
            return;
         }
         mc.mouseEnabled = false;
         ++this.count;
         model.stop();
         effect = new LightEffect();
         effect.show(new Point(model.x,model.y - model.height + 2),new Point(mc.x + mc.width / 2,mc.y + mc.height - 5),false);
         setTimeout(function():void
         {
            mc.gotoAndStop(2);
         },1000);
         if(this.count >= 4)
         {
            OgreController.isShow = true;
         }
      }
   }
}

