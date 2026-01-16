package com.robot.core.animate
{
   import com.robot.core.SoundManager;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.manager.MainManager;
   import com.robot.core.newloader.MCLoader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.system.ApplicationDomain;
   import org.taomee.utils.DisplayUtil;
   
   public class AnimateManager
   {
      
      private static var url:String;
      
      private static var name:String;
      
      private static var soundName:String;
      
      private static var func:Function;
      
      private static var mcloader:MCLoader;
      
      private static var soundChal:SoundChannel;
      
      private static var frameFunc:Function;
      
      public static const MC_NOT_FIND:String = "mcIsNotFind";
      
      public function AnimateManager()
      {
         super();
      }
      
      public static function playFullScreenAnimate(param1:String = "", param2:Function = null, param3:String = null, param4:String = null) : void
      {
         url = param1;
         name = param3;
         soundName = param4;
         func = param2;
         if(param1 != "" && param1 != null)
         {
            if(Boolean(mcloader))
            {
               mcloader.clear();
               mcloader = null;
            }
            mcloader = new MCLoader(url,LevelManager.appLevel,1,"正在加载动画..");
            mcloader.addEventListener(MCLoadEvent.SUCCESS,onLoadAnimateSuccess);
            mcloader.doLoad(url);
            return;
         }
         throw new Error("加载的动画路径不对哟!");
      }
      
      private static function onLoadAnimateSuccess(param1:MCLoadEvent) : void
      {
         var _loc2_:ApplicationDomain = null;
         var _loc3_:* = undefined;
         var _loc4_:Sound = null;
         var _loc5_:ApplicationDomain = null;
         var _loc6_:* = undefined;
         var _loc7_:MovieClip = null;
         var _loc8_:MovieClip = null;
         LevelManager.closeMouseEvent();
         SoundManager.stopSound();
         mcloader.removeEventListener(MCLoadEvent.SUCCESS,onLoadAnimateSuccess);
         if(soundName != "" && soundName != null)
         {
            _loc2_ = param1.getApplicationDomain();
            _loc3_ = _loc2_.getDefinition(soundName);
            _loc4_ = new _loc3_() as Sound;
            if(Boolean(soundChal))
            {
               soundChal.stop();
               soundChal = null;
            }
            soundChal = _loc4_.play(10);
         }
         if(name != "" && name != null)
         {
            _loc5_ = param1.getApplicationDomain();
            _loc6_ = _loc5_.getDefinition(name);
            _loc7_ = new _loc6_() as MovieClip;
            if(_loc7_ == null)
            {
               throw new Error("加载的动画出错!");
            }
            MainManager.getStage().addChild(_loc7_);
            playMovieClip(_loc7_);
         }
         else
         {
            _loc8_ = param1.getContent() as MovieClip;
            MainManager.getStage().addChild(_loc8_);
            playMovieClip(_loc8_);
         }
      }
      
      private static function playMovieClip(param1:MovieClip) : void
      {
         var mc:MovieClip = param1;
         mc.gotoAndPlay(2);
         mc.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
         {
            if(mc.currentFrame == mc.totalFrames)
            {
               mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
               DisplayUtil.removeForParent(mc);
               mc = null;
               SoundManager.playSound();
               LevelManager.openMouseEvent();
               if(Boolean(soundChal))
               {
                  soundChal.stop();
               }
               url = "";
               name = "";
               soundName = "";
               if(func != null)
               {
                  func();
               }
            }
         });
      }
      
      public static function playMcAnimate(param1:MovieClip, param2:uint = 0, param3:String = "", param4:Function = null) : void
      {
         var mc:MovieClip = param1;
         var frame:uint = param2;
         var name:String = param3;
         var func:Function = param4;
         frameFunc = func;
         if(func == null)
         {
            throw new Error("动画播放回调函数不能为null");
         }
         if(frame == 0 || name == "" || name == null)
         {
            playFrameMC(mc);
         }
         else
         {
            mc.gotoAndStop(frame);
            LevelManager.closeMouseEvent();
            mc.addEventListener(Event.ENTER_FRAME,function():void
            {
               var _loc2_:MovieClip = mc[name] as MovieClip;
               if(Boolean(_loc2_))
               {
                  mc.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  playFrameMC(_loc2_);
               }
            });
         }
      }
      
      private static function playFrameMC(param1:MovieClip) : void
      {
         var frameMC:MovieClip = param1;
         if(Boolean(frameMC))
         {
            frameMC.gotoAndPlay(2);
            frameMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               if(frameMC.currentFrame == frameMC.totalFrames)
               {
                  frameMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  LevelManager.openMouseEvent();
                  frameFunc();
               }
            });
         }
      }
   }
}

