package com.robot.app.task.machinewar
{
   import com.robot.core.config.ClientConfig;
   import com.robot.core.event.ItemEvent;
   import com.robot.core.event.MCLoadEvent;
   import com.robot.core.info.userItem.SingleItemInfo;
   import com.robot.core.manager.ItemManager;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.newloader.MCLoader;
   import com.robot.core.ui.alert.Alarm;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import org.taomee.effect.ColorFilter;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class MissileFirePanel extends Sprite
   {
      
      private const PATH:String = "task/missilefire.swf";
      
      private var mainMC:MovieClip;
      
      private var closeBtn:SimpleButton;
      
      private var sendBtn:SimpleButton;
      
      private var canSend:Boolean;
      
      public function MissileFirePanel()
      {
         super();
      }
      
      public function show() : void
      {
         if(Boolean(this.mainMC))
         {
            this.init();
         }
         else
         {
            this.loadUI();
         }
      }
      
      private function loadUI() : void
      {
         var _loc1_:String = ClientConfig.getResPath(this.PATH);
         var _loc2_:MCLoader = new MCLoader(_loc1_,LevelManager.appLevel,1,"正在打开发射系统程序");
         _loc2_.addEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         _loc2_.doLoad();
      }
      
      private function onLoadSuccess(param1:MCLoadEvent) : void
      {
         var cls:Class = null;
         var event:MCLoadEvent = param1;
         var mcloader:MCLoader = event.currentTarget as MCLoader;
         mcloader.removeEventListener(MCLoadEvent.SUCCESS,this.onLoadSuccess);
         cls = event.getApplicationDomain().getDefinition("Main_Panel") as Class;
         this.mainMC = new cls() as MovieClip;
         this.closeBtn = this.mainMC["close_btn"];
         this.closeBtn.addEventListener(MouseEvent.CLICK,this.close);
         this.sendBtn = this.mainMC["send_bomrb"];
         this.sendBtn.addEventListener(MouseEvent.CLICK,this.sendHandler);
         mcloader.clear();
         ItemManager.addEventListener(ItemEvent.COLLECTION_LIST,function(param1:ItemEvent):void
         {
            var _loc3_:* = 0;
            var _loc4_:* = 0;
            ItemManager.removeEventListener(ItemEvent.COLLECTION_LIST,arguments.callee);
            var _loc5_:SingleItemInfo = ItemManager.getInfo(400008);
            if(Boolean(_loc5_))
            {
               _loc4_ = uint(_loc5_.itemNum);
               if(_loc4_ >= 5)
               {
                  canSend = true;
               }
               else
               {
                  _loc3_ = uint(_loc4_ + 1);
                  while(_loc3_ < 6)
                  {
                     mainMC["energy" + _loc3_].filters = [ColorFilter.setGrayscale()];
                     _loc3_++;
                  }
               }
            }
            else
            {
               canSend = false;
               _loc3_ = 1;
               while(_loc3_ < 6)
               {
                  mainMC["energy" + _loc3_].filters = [ColorFilter.setGrayscale()];
                  _loc3_++;
               }
            }
         });
         ItemManager.getCollection();
         this.init();
      }
      
      private function init() : void
      {
         this.addChild(this.mainMC);
         DisplayUtil.align(this,null,AlignType.MIDDLE_CENTER);
         LevelManager.appLevel.addChild(this);
      }
      
      private function close(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(this);
      }
      
      private function sendHandler(param1:MouseEvent) : void
      {
         var event:MouseEvent = param1;
         if(this.canSend)
         {
            this.mainMC.gotoAndStop(2);
            LevelManager.closeMouseEvent();
            this.mainMC.addEventListener(Event.ENTER_FRAME,function(param1:Event):void
            {
               var _loc3_:MovieClip = mainMC["loading"];
               if(Boolean(_loc3_))
               {
                  mainMC.removeEventListener(Event.ENTER_FRAME,arguments.callee);
                  _loc3_.addEventListener(Event.ENTER_FRAME,onLoadingFrameHandler);
               }
            });
         }
         else
         {
            Alarm.show("很抱歉您目前还没有<font color=\'#ff0000\'>5颗电容球</font>，不能启动导弹发射装置。");
         }
      }
      
      private function onLoadingFrameHandler(param1:Event) : void
      {
         if(this.mainMC["loading"].totalFrames == this.mainMC["loading"].currentFrame)
         {
            this.mainMC["loading"].removeEventListener(Event.ENTER_FRAME,this.onLoadingFrameHandler);
            LevelManager.openMouseEvent();
            this.dispatchEvent(new Event("canSend"));
            this.close(null);
         }
      }
      
      private function loadItem(param1:Array) : void
      {
      }
   }
}

