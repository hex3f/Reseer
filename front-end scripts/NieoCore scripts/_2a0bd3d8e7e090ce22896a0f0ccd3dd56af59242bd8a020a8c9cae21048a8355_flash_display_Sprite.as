package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _2a0bd3d8e7e090ce22896a0f0ccd3dd56af59242bd8a020a8c9cae21048a8355_flash_display_Sprite extends Sprite
   {
      
      public function _2a0bd3d8e7e090ce22896a0f0ccd3dd56af59242bd8a020a8c9cae21048a8355_flash_display_Sprite()
      {
         super();
      }
      
      public function allowDomainInRSL(... rest) : void
      {
         Security.allowDomain.apply(null,rest);
      }
      
      public function allowInsecureDomainInRSL(... rest) : void
      {
         Security.allowInsecureDomain.apply(null,rest);
      }
   }
}

