package com.robot.app.panel
{
   import com.robot.core.CommandID;
   import com.robot.core.config.ClientConfig;
   import com.robot.core.info.fightInfo.PetFightModel;
   import com.robot.core.manager.LevelManager;
   import com.robot.core.net.SocketConnection;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import org.taomee.events.SocketEvent;
   import org.taomee.manager.ResourceManager;
   import org.taomee.utils.AlignType;
   import org.taomee.utils.DisplayUtil;
   
   public class TopSelectPanel extends Sprite
   {
      
      private static var mc:MovieClip;
      
      private static var dragBtn:SimpleButton;
      
      private static var singleBtn:SimpleButton;
      
      private static var multiBtn:SimpleButton;
      
      private static var closeBtn:SimpleButton;
      
      private static var _isPlay:Boolean;
      
      private static var _mode:uint;
      
      private static var _isSingle:Boolean;
      
      private static var _s1:String;
      
      private static var _s2:String;
      
      private static var _s3:String;
      
      public static const NORMAL:uint = 0;
      
      public static const BEYOND:uint = 1;
      
      private static var typeXML:XML = <root>
										<normal>
											<single>
												<play>
													21
												</play>
												<real>
													19
												</real>
											</single>
											<multi>
												<play>
													22
												</play>
												<real>
													20
												</real>
											</multi>
										</normal>
										<beyond>
											<single>
												<play>
													50
												</play>
												<real>
													48
												</real>
											</single>
											<multi>
												<play>
													51
												</play>
												<real>
													49
												</real>
											</multi>
										</beyond>
									</root>;
      
      public function TopSelectPanel()
      {
         super();
      }
      
      public static function show(param1:Function = null) : void
      {
         var fun:Function = null;
         fun = param1;
         if(mc == null)
         {
            ResourceManager.getResource(ClientConfig.getAppRes("ui_pet_top_panel"),function(param1:MovieClip):void
            {
               mc = param1;
               addToAppLevel();
               if(fun != null)
               {
                  fun();
               }
            },"ui_pet_top_panel");
         }
         else
         {
            addToAppLevel();
            if(fun != null)
            {
               fun();
            }
         }
      }
      
      private static function addToAppLevel() : void
      {
         LevelManager.closeMouseEvent();
         LevelManager.appLevel.addChild(mc);
         DisplayUtil.align(mc,null,AlignType.MIDDLE_CENTER);
         mc["iconMC"].visible = false;
         mc["iconMC"].gotoAndStop(1);
         dragBtn = mc["dragBtn"];
         dragBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSelectDown);
         dragBtn.addEventListener(MouseEvent.MOUSE_UP,onSelectUp);
         closeBtn = mc["closeBtn"];
         closeBtn.addEventListener(MouseEvent.CLICK,onSelectClose);
         singleBtn = mc["singleBtn"];
         singleBtn.addEventListener(MouseEvent.CLICK,onSelectClick);
         multiBtn = mc["multiBtn"];
         multiBtn.addEventListener(MouseEvent.CLICK,onSelectClick);
      }
      
      public static function set isPlay(param1:Boolean) : void
      {
         _isPlay = param1;
         if(_isPlay)
         {
            if(Boolean(mc))
            {
               mc["title_mc"].gotoAndStop(2);
            }
            _s3 = "play";
         }
         else
         {
            if(Boolean(mc))
            {
               mc["title_mc"].gotoAndStop(1);
            }
            _s3 = "real";
         }
      }
      
      public static function set mode(param1:uint) : void
      {
         _mode = param1;
         if(param1 == NORMAL)
         {
            if(Boolean(mc))
            {
               mc["iconMC"].visible = false;
               mc["iconMC"].gotoAndStop(1);
               mc["txtMC"].gotoAndStop(1);
            }
            _s1 = "normal";
         }
         else
         {
            if(Boolean(mc))
            {
               mc["iconMC"].mouseEnabled = mc["iconMC"].mouseChildren = false;
               mc["iconMC"].visible = true;
               mc["iconMC"].gotoAndPlay(1);
               mc["txtMC"].gotoAndStop(2);
            }
            _s1 = "beyond";
         }
      }
      
      public static function set isSingle(param1:Boolean) : void
      {
         _isSingle = param1;
         if(param1)
         {
            _s2 = "single";
            PetFightModel.mode = PetFightModel.SINGLE_MODE;
         }
         else
         {
            _s2 = "multi";
            PetFightModel.mode = PetFightModel.MULTI_MODE;
         }
      }
      
      private static function onSelectDown(param1:MouseEvent) : void
      {
         mc.startDrag();
      }
      
      private static function onSelectUp(param1:MouseEvent) : void
      {
         mc.stopDrag();
      }
      
      private static function onSelectClose(param1:MouseEvent) : void
      {
         TopSelectPanel.destroy();
      }
      
      private static function onSelectClick(param1:MouseEvent) : void
      {
         DisplayUtil.removeForParent(mc);
         LevelManager.openMouseEvent();
         var _loc2_:SimpleButton = param1.currentTarget as SimpleButton;
         if(_loc2_ == singleBtn)
         {
            isSingle = true;
         }
         if(_loc2_ == multiBtn)
         {
            isSingle = false;
         }
         enterFight();
      }
      
      public static function enterFight() : void
      {
         SocketConnection.addCmdListener(CommandID.PET_TOPLEVEL_JOIN,onTopFightJoin);
         SocketConnection.addCmdListener(CommandID.INVITE_FIGHT_CANCEL,onCancelTopFight);
         SocketConnection.addCmdListener(CommandID.TOPFIGHT_BEYOND,onTopFightBeyond);
         var _loc1_:uint = uint(typeXML.child(_s1).child(_s2).child(_s3));
         if(_mode == BEYOND)
         {
            SocketConnection.send(CommandID.TOPFIGHT_BEYOND,_loc1_);
         }
         else
         {
            SocketConnection.send(CommandID.PET_TOPLEVEL_JOIN,_loc1_);
         }
      }
      
      private static function onTopFightJoin(param1:SocketEvent) : void
      {
         PetFightModel.type = PetFightModel.PET_TOPLEVEL;
         PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
         FightMatchingPanel.show(closeTopFight);
      }
      
      private static function onTopFightBeyond(param1:SocketEvent) : void
      {
         PetFightModel.type = PetFightModel.TOP_WAR_BEYOND;
         PetFightModel.status = PetFightModel.FIGHT_WITH_PLAYER;
         FightMatchingPanel.show(closeTopFight);
      }
      
      private static function closeTopFight() : void
      {
         SocketConnection.send(CommandID.INVITE_FIGHT_CANCEL);
      }
      
      private static function onCancelTopFight(param1:SocketEvent) : void
      {
         PetFightModel.mode = PetFightModel.MULTI_MODE;
         PetFightModel.type = 0;
         TopSelectPanel.destroy();
      }
      
      public static function destroy() : void
      {
         if(Boolean(mc))
         {
            dragBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSelectDown);
            dragBtn.removeEventListener(MouseEvent.MOUSE_UP,onSelectUp);
            closeBtn.removeEventListener(MouseEvent.CLICK,onSelectClose);
            singleBtn.removeEventListener(MouseEvent.CLICK,onSelectClick);
            multiBtn.removeEventListener(MouseEvent.CLICK,onSelectClick);
            DisplayUtil.removeForParent(mc);
            LevelManager.openMouseEvent();
            dragBtn = null;
            closeBtn = null;
            singleBtn = null;
            multiBtn = null;
            mc = null;
         }
         SocketConnection.removeCmdListener(CommandID.PET_TOPLEVEL_JOIN,onTopFightJoin);
         SocketConnection.removeCmdListener(CommandID.INVITE_FIGHT_CANCEL,onCancelTopFight);
         SocketConnection.removeCmdListener(CommandID.TOPFIGHT_BEYOND,onTopFightBeyond);
      }
   }
}

