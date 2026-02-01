with AUnit.Test_Cases; use AUnit.Test_Cases;

package Geozone_Tests is

   type Geozone_Test_Case is new Test_Case with null record;

   procedure Register_Tests (T : in out Geozone_Test_Case);
   function Name (T : Geozone_Test_Case) return AUnit.Message_String;

end Geozone_Tests;
