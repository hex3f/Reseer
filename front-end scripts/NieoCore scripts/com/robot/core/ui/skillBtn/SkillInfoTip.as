package com.robot.core.ui.skillBtn
{
   import com.robot.core.config.xml.SkillXMLInfo;
   import com.robot.core.info.skillEffectInfo.EffectInfoManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.Timer;
   import org.taomee.utils.DisplayUtil;
   
   public class SkillInfoTip
   {
      
      private static var tipMC:MovieClip;
      
      private static var timer:Timer;
      
      setup();
      
      public function SkillInfoTip()
      {
         super();
      }
      
      private static function setup() : void
      {
         timer = new Timer(5000,1);
         timer.addEventListener(TimerEvent.TIMER,timerHandler);
      }
      
      public static function show(param1:uint) : void
      {
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:TextField = null;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:String = null;
         if(!tipMC)
         {
            tipMC = UIManager.getMovieClip("ui_SkillTipPanel");
            tipMC.mouseChildren = false;
            tipMC.mouseEnabled = false;
         }
         timer.stop();
         timer.reset();
         var _loc8_:String = SkillXMLInfo.getName(param1);
         var _loc9_:uint = uint(SkillXMLInfo.getCategory(param1));
         var _loc10_:Array = SkillXMLInfo.getSideEffects(param1);
         var _loc11_:Array = SkillXMLInfo.getSideEffectArgs(param1);
         if(_loc9_ == 1)
         {
            _loc2_ = "#FF0000";
         }
         else if(_loc9_ == 2)
         {
            _loc2_ = "#FF99FF";
         }
         else
         {
            _loc2_ = "#99ff00";
         }
         var _loc12_:String = "<font color=\'#ffff00\'>" + _loc8_ + "</font>  " + "<font color=\'" + _loc2_ + "\'>(" + SkillXMLInfo.getCategoryName(param1) + ")</font>\r";
         var _loc13_:* = 0;
         _loc12_ += "\r";
         var _loc14_:Number = SkillXMLInfo.getDamage(param1);
         if(_loc9_ == 1 || _loc9_ == 2)
         {
            _loc12_ += "威力：" + _loc14_ + "\r";
         }
         var _loc15_:int = SkillXMLInfo.getCritRate(param1);
         if(_loc15_ > 0)
         {
            _loc12_ += "会心率：" + Number(_loc15_ / 16 * 100) + "%\r";
         }
         var _loc16_:int = SkillXMLInfo.getPriority(param1);
         if(_loc16_ != 0)
         {
            if(_loc16_ > 0)
            {
               _loc12_ += "先制+" + _loc16_ + "\r";
            }
            else
            {
               _loc12_ += "先制" + _loc16_ + "\r";
            }
         }
         var _loc17_:Number = SkillXMLInfo.hitP(param1);
         var _loc18_:Number = SkillXMLInfo.getMustHit(param1);
         if(_loc18_ == 1)
         {
            _loc12_ += "必中";
         }
         else
         {
            _loc12_ += "命中率：" + _loc17_ + "%";
         }
         _loc12_ += "\r";
         for each(_loc3_ in _loc10_)
         {
            if(_loc3_ != "")
            {
               _loc5_ = uint(1000000 + uint(_loc3_));
               _loc6_ = EffectInfoManager.getArgsNum(uint(_loc3_));
               _loc7_ = EffectInfoManager.getInfo(uint(_loc3_),_loc11_.slice(_loc13_,_loc13_ + _loc6_));
               _loc13_ += _loc6_;
               _loc12_ += "\r" + _loc7_;
            }
         }
         _loc4_ = tipMC["info_txt"];
         _loc4_.autoSize = TextFieldAutoSize.LEFT;
         _loc4_.wordWrap = true;
         _loc4_.htmlText = _loc12_;
         tipMC["bgMC"].height = _loc4_.height + 20;
         tipMC["bgMC"].width = _loc4_.width + 20;
         MainManager.getStage().addChild(tipMC);
         tipMC.addEventListener(Event.ENTER_FRAME,enterFrameHandler);
         timer.start();
      }
      
      private static function timerHandler(param1:TimerEvent) : void
      {
         hide();
      }
      
      public static function hide() : void
      {
         if(Boolean(tipMC))
         {
            tipMC.removeEventListener(Event.ENTER_FRAME,enterFrameHandler);
            DisplayUtil.removeForParent(tipMC);
         }
      }
      
      private static function enterFrameHandler(param1:Event) : void
      {
         if(MainManager.getStage().mouseX + tipMC.width + 20 >= MainManager.getStageWidth())
         {
            tipMC.x = MainManager.getStageWidth() - tipMC.width - 10;
         }
         else
         {
            tipMC.x = MainManager.getStage().mouseX + 10;
         }
         if(MainManager.getStage().mouseY + tipMC.height + 20 >= MainManager.getStageHeight())
         {
            tipMC.y = MainManager.getStageHeight() - tipMC.height - 10;
         }
         else
         {
            tipMC.y = MainManager.getStage().mouseY + 20;
         }
      }
   }
}

