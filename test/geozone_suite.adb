with Geozone_Tests;

package body Geozone_Suite is

   function Suite return AUnit.Test_Suites.Access_Test_Suite is
      Result : constant AUnit.Test_Suites.Access_Test_Suite :=
         AUnit.Test_Suites.New_Suite;
   begin
      Result.Add_Test (new Geozone_Tests.Geozone_Test_Case);
      return Result;
   end Suite;

end Geozone_Suite;
