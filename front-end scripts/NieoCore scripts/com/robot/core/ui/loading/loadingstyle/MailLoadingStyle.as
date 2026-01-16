package com.robot.core.ui.loading.loadingstyle
{
   import com.robot.core.manager.LoadingManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.text.TextField;
   import org.taomee.utils.DisplayUtil;
   
   public class MailLoadingStyle extends EventDispatcher implements ILoadingStyle
   {
      
      private var mc:MovieClip;
      
      private var parent:DisplayObjectContainer;
      
      private var txt:TextField;
      
      private var title:String;
      
      public function MailLoadingStyle(param1:DisplayObjectContainer = null, param2:String = "")
      {
         super();
         this.mc = LoadingManager.getMovieClip("mail_loading_mc");
         this.parent = param1;
         this.txt = this.mc["txt"];
         this.setTitle(param2);
         this.show();
      }
      
      public function changePercent(param1:Number, param2:Number) : void
      {
         var _loc3_:uint = Math.floor(param2 / param1 * 100);
         this.txt.text = this.title + " " + _loc3_ + "%";
      }
      
      public function destroy() : void
      {
         DisplayUtil.removeForParent(this.mc);
         this.mc = null;
         this.parent = null;
      }
      
      public function show() : void
      {
         if(Boolean(this.parent))
         {
            this.parent.addChild(this.mc);
         }
      }
      
      public function close() : void
      {
         DisplayUtil.removeForParent(this.mc);
      }
      
      public function setTitle(param1:String) : void
      {
         this.title = param1;
      }
      
      public function setIsShowCloseBtn(param1:Boolean) : void
      {
      }
      
      public function getParentMC() : DisplayObjectContainer
      {
         return this.parent;
      }
      
      public function getLoadingMC() : DisplayObject
      {
         return this.mc;
      }
   }
}

