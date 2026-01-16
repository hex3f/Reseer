package com.robot.petFightModule.control
{
   import com.robot.petFightModule.PetFightEntry;
   import com.robot.petFightModule.mode.BaseFighterMode;
   import org.taomee.ds.HashMap;
   
   public class PetStautsEffect
   {
      
      private static var hashMap:HashMap = new HashMap();
      
      setup();
      
      public function PetStautsEffect()
      {
         super();
      }
      
      public static function addEffect(param1:uint, param2:uint, param3:uint) : void
      {
         var _loc4_:BaseFighterMode = null;
         var _loc5_:Class = null;
         if(Boolean(hashMap.getValue(param2)))
         {
            _loc4_ = PetFightEntry.fighterCon.getFighterMode(param1);
            _loc5_ = hashMap.getValue(param2) as Class;
            _loc4_.propView.addEffect(_loc5_,param2,param3);
         }
      }
      
      public static function addEffectTrait(param1:uint, param2:uint, param3:int) : void
      {
         var _loc4_:BaseFighterMode = null;
         var _loc5_:Class = null;
         var _loc6_:int = param3 > 0 ? 14 : 15;
         if(Boolean(hashMap.getValue(_loc6_)))
         {
            _loc4_ = PetFightEntry.fighterCon.getFighterMode(param1);
            _loc5_ = hashMap.getValue(_loc6_) as Class;
            _loc4_.propView.addEffectTrait(_loc5_,param2,param3);
         }
      }
      
      private static function setup() : void
      {
         hashMap.add(0,Effect_Narcosis_Icon);
         hashMap.add(1,Effect_Poisoning_Icon);
         hashMap.add(2,Effect_Fire_Icon);
         hashMap.add(3,Effect_0_3);
         hashMap.add(4,Effect_0_4);
         hashMap.add(5,Effect_Freeze_Icon);
         hashMap.add(6,Effect_Afraid_Icon);
         hashMap.add(7,Effect_Tired_Icon);
         hashMap.add(8,Effect_Sleep_Icon);
         hashMap.add(9,Effect_0_9);
         hashMap.add(10,Effect_0_10);
         hashMap.add(11,Effect_0_11);
         hashMap.add(12,Effect_0_12);
         hashMap.add(13,Effect_0_13);
         hashMap.add(14,Effect_Trait_Up);
         hashMap.add(15,Effect_Trait_Down);
      }
   }
}

