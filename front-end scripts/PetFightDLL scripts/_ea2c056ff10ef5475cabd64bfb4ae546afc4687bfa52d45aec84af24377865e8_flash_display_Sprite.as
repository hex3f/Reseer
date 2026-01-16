package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _ea2c056ff10ef5475cabd64bfb4ae546afc4687bfa52d45aec84af24377865e8_flash_display_Sprite extends Sprite
   {
      
      public function _ea2c056ff10ef5475cabd64bfb4ae546afc4687bfa52d45aec84af24377865e8_flash_display_Sprite()
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

