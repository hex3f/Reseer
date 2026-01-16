package com.robot.app.newspaper
{
   import com.robot.app.service.Service;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.UIManager;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class ContributeAlert
   {
      
      private static var mc:MovieClip;
      
      private static var titleTxt:TextField;
      
      private static var msgTxt:TextField;
      
      private static var closeBtn:SimpleButton;
      
      private static var sendBtn:SimpleButton;
      
      private static var _type:uint;
      
      public static const NEWS_TYPE:uint = 1;
      
      public static const SHIPER_TYPE:uint = 2;
      
      public static const DOCTOR_TYPE:uint = 3;
      
      public static const NONO:uint = 4;
      
      public static const LYMAN:uint = 5;
      
      public static const ROCKY:uint = 6;
      
      public function ContributeAlert()
      {
         super();
      }
      
      public static function show(param1:uint = 1) : void
      {
         _type = param1;
         if(!mc)
         {
            mc = UIManager.getMovieClip("ContributePanel");
            titleTxt = mc["titleTxt"];
            msgTxt = mc["msgTxt"];
            closeBtn = mc["closeBtn"];
            sendBtn = mc["sendBtn"];
            closeBtn.addEventListener(MouseEvent.CLICK,closeHandler);
            sendBtn.addEventListener(MouseEvent.CLICK,sendHandler);
         }
         mc["title_mc"].gotoAndStop(param1);
         LevelManager.topLevel.addChild(mc);
         titleTxt.text = "";
         msgTxt.text = "";
         DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
      }
      
      private static function closeHandler(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
      }
      
      private static function sendHandler(param1:MouseEvent) : void
      {
         if(Service.contribute(titleTxt.text,msgTxt.text,_type))
         {
            closeHandler(null);
         }
      }
   }
}

