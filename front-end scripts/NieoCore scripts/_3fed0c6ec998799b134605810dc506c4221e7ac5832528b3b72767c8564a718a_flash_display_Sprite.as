package
{
   import flash.display.Sprite;
   import flash.system.Security;
   
   [ExcludeClass]
   public class _3fed0c6ec998799b134605810dc506c4221e7ac5832528b3b72767c8564a718a_flash_display_Sprite extends Sprite
   {
      
      public function _3fed0c6ec998799b134605810dc506c4221e7ac5832528b3b72767c8564a718a_flash_display_Sprite()
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

