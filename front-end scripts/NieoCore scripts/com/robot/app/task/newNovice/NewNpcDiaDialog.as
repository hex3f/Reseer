package com.robot.app.task.newNovice
{
   import com.robot.core.event.MapEvent;
   import com.robot.core.manager.*;
   import flash.events.MouseEvent;
   import org.taomee.utils.DisplayUtil;
   
   public class NewNpcDiaDialog
   {
      
      private static var _npcMc:*;
      
      private static var _talkList_A:Array;
      
      private static var _npcUrlStr:String;
      
      private static var _curIndex:uint;
      
      private static var _applyHandler:Array;
      
      private static var _comHandler:Function;
      
      public function NewNpcDiaDialog()
      {
         super();
      }
      
      public static function show(param1:Array, param2:Array, param3:Function = null) : void
      {
         _applyHandler = param2;
         _comHandler = param3;
         _curIndex = 0;
         _talkList_A = param1;
         if(!_npcMc)
         {
            _npcMc = AssetsManager.getMovieClip("NPC_MC");
         }
         LevelManager.appLevel.addChild(_npcMc);
         _npcMc.y = 340;
         _npcMc.x = (960 - _npcMc.width) / 2;
         _npcMc["txt"].htmlText = "    " + _talkList_A[_curIndex];
         if(_talkList_A.length > 1)
         {
            _npcMc["continueBtn"].visible = true;
            _npcMc["continueBtn"].play();
            _npcMc["continueBtn"].addEventListener(MouseEvent.CLICK,onContinueHandler);
         }
         else if(_applyHandler[0] != null)
         {
            _npcMc["continueBtn"].visible = true;
            _npcMc["continueBtn"].play();
            _npcMc["continueBtn"].addEventListener(MouseEvent.CLICK,onContinueHandler);
         }
         else
         {
            _npcMc["continueBtn"].visible = false;
         }
         MapManager.addEventListener(MapEvent.MAP_DESTROY,onMapDestroyHandler);
      }
      
      private static function onContinueHandler(param1:MouseEvent) : void
      {
         if(_curIndex < _talkList_A.length - 1)
         {
            ++_curIndex;
            _npcMc["txt"].htmlText = "    " + _talkList_A[_curIndex];
            if(Boolean(_applyHandler))
            {
               if(_applyHandler.length > 0)
               {
                  if(_applyHandler[_curIndex] != null)
                  {
                     (_applyHandler[_curIndex] as Function)();
                     _applyHandler[_curIndex] = null;
                  }
               }
            }
            if(_curIndex == _talkList_A.length - 1)
            {
               _npcMc["continueBtn"].visible = false;
               hide();
               if(_comHandler != null)
               {
                  _comHandler();
               }
            }
         }
         else if(_curIndex == 0)
         {
            if(Boolean(_applyHandler))
            {
               if(_applyHandler.length > 0)
               {
                  if(_applyHandler[_curIndex] != null)
                  {
                     (_applyHandler[_curIndex] as Function)();
                     _applyHandler[_curIndex] = null;
                  }
               }
            }
         }
      }
      
      private static function onMapDestroyHandler(param1:MapEvent) : void
      {
         hide();
      }
      
      public static function hide() : void
      {
         DisplayUtil.removeForParent(_npcMc);
         MapManager.removeEventListener(MapEvent.MAP_DESTROY,onMapDestroyHandler);
         _talkList_A = null;
         _applyHandler = null;
      }
      
      public static function destroy() : void
      {
         if(Boolean(_npcMc))
         {
            DisplayUtil.removeForParent(_npcMc);
         }
         _talkList_A = null;
         _applyHandler = null;
         _comHandler = null;
      }
   }
}

