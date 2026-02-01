with AUnit.Assertions;  use AUnit.Assertions;
with Interfaces.C;      use Interfaces.C;
with Geozone_Binding;   use Geozone_Binding;

package body Geozone_Tests is

   Circle  : aliased Geo_Circle;
   Polygon : aliased Geo_Polygon;
   Current : aliased Geo_Point;
   Future  : aliased Geo_Point;
   Result  : aliased Geo_Zone_Result;

   -------------------------
   -- Circle Tests
   -------------------------

   procedure Test_Inside_Circle (T : in out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Circle.Center.Latitude := 40.0;
      Circle.Center.Longitude := -105.0;
      Circle.Radius_Meters := 1000.0;
      Current.Latitude := 40.001;
      Current.Longitude := -105.001;
      Future.Latitude := 40.05;
      Future.Longitude := -105.05;

      Check_Circle_Zone (Circle'Access, Current'Access,
                         Future'Access, Result'Access);

      Assert (Result.In_Zone = 1,
              "Weapon should be IN the zone");
      Assert (Result.Will_Cross = 1,
              "Weapon should CROSS the zone (leaving)");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in zone");
   end Test_Inside_Circle;

   procedure Test_Crosses_Circle (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Circle.Center.Latitude := 40.0;
      Circle.Center.Longitude := -105.0;
      Circle.Radius_Meters := 1000.0;
      Current.Latitude := 39.98;
      Current.Longitude := -105.0;
      Future.Latitude := 40.02;
      Future.Longitude := -105.0;

      Check_Circle_Zone (Circle'Access, Current'Access,
                         Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in zone");
      Assert (Result.Will_Cross = 1,
              "Weapon path should CROSS zone");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in zone");
   end Test_Crosses_Circle;

   procedure Test_Outside_Circle (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Circle.Center.Latitude := 40.0;
      Circle.Center.Longitude := -105.0;
      Circle.Radius_Meters := 1000.0;
      Current.Latitude := 41.0;
      Current.Longitude := -106.0;
      Future.Latitude := 41.5;
      Future.Longitude := -106.5;

      Check_Circle_Zone (Circle'Access, Current'Access,
                         Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in zone");
      Assert (Result.Will_Cross = 0,
              "Weapon should NOT cross zone");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in zone");
   end Test_Outside_Circle;

   procedure Test_Ends_In_Circle (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Circle.Center.Latitude := 40.0;
      Circle.Center.Longitude := -105.0;
      Circle.Radius_Meters := 1000.0;
      Current.Latitude := 40.05;
      Current.Longitude := -105.0;
      Future.Latitude := 40.002;
      Future.Longitude := -105.001;

      Check_Circle_Zone (Circle'Access, Current'Access,
                         Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in zone initially");
      Assert (Result.Will_Cross = 1,
              "Weapon should CROSS into zone");
      Assert (Result.Will_End_In = 1,
              "Weapon should END in zone");
   end Test_Ends_In_Circle;

   -------------------------
   -- Polygon Tests
   -------------------------

   procedure Setup_Square_Polygon is
   begin
      Polygon.Num_Points := 4;
      Polygon.Points (0).Latitude := 34.99;
      Polygon.Points (0).Longitude := -100.01;
      Polygon.Points (1).Latitude := 34.99;
      Polygon.Points (1).Longitude := -99.99;
      Polygon.Points (2).Latitude := 35.01;
      Polygon.Points (2).Longitude := -99.99;
      Polygon.Points (3).Latitude := 35.01;
      Polygon.Points (3).Longitude := -100.01;
   end Setup_Square_Polygon;

   procedure Test_Inside_Polygon (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Setup_Square_Polygon;
      Current.Latitude := 35.0;
      Current.Longitude := -100.0;
      Future.Latitude := 35.0;
      Future.Longitude := -100.0;

      Check_Polygon_Zone (Polygon'Access, Current'Access,
                          Future'Access, Result'Access);

      Assert (Result.In_Zone = 1,
              "Weapon should be IN polygon");
      Assert (Result.Will_Cross = 1,
              "Weapon should CROSS (still in zone)");
      Assert (Result.Will_End_In = 1,
              "Weapon should END in polygon");
   end Test_Inside_Polygon;

   procedure Test_Crosses_Polygon (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Setup_Square_Polygon;
      Current.Latitude := 34.95;
      Current.Longitude := -100.0;
      Future.Latitude := 35.05;
      Future.Longitude := -100.0;

      Check_Polygon_Zone (Polygon'Access, Current'Access,
                          Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in polygon");
      Assert (Result.Will_Cross = 1,
              "Weapon should CROSS polygon");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in polygon");
   end Test_Crosses_Polygon;

   procedure Test_Outside_Polygon (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Setup_Square_Polygon;
      Current.Latitude := 36.0;
      Current.Longitude := -101.0;
      Future.Latitude := 36.5;
      Future.Longitude := -101.5;

      Check_Polygon_Zone (Polygon'Access, Current'Access,
                          Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in polygon");
      Assert (Result.Will_Cross = 0,
              "Weapon should NOT cross polygon");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in polygon");
   end Test_Outside_Polygon;

   procedure Test_Clips_Triangle (T : in Out Test_Case'Class) is
      pragma Unreferenced (T);
   begin
      Polygon.Num_Points := 3;
      Polygon.Points (0).Latitude := 30.0;
      Polygon.Points (0).Longitude := -90.0;
      Polygon.Points (1).Latitude := 30.0;
      Polygon.Points (1).Longitude := -89.9;
      Polygon.Points (2).Latitude := 30.05;
      Polygon.Points (2).Longitude := -89.95;
      Current.Latitude := 30.01;
      Current.Longitude := -90.01;
      Future.Latitude := 30.01;
      Future.Longitude := -89.89;

      Check_Polygon_Zone (Polygon'Access, Current'Access,
                          Future'Access, Result'Access);

      Assert (Result.In_Zone = 0,
              "Weapon should NOT be in triangle");
      Assert (Result.Will_Cross = 1,
              "Weapon should CROSS triangle");
      Assert (Result.Will_End_In = 0,
              "Weapon should NOT end in triangle");
   end Test_Clips_Triangle;

   -------------------------
   -- Framework Hooks
   -------------------------

   function Name (T : Geozone_Test_Case) return AUnit.Message_String is
      pragma Unreferenced (T);
   begin
      return AUnit.Format ("Geozone Tests");
   end Name;

   procedure Register_Tests (T : in Out Geozone_Test_Case) is
      use AUnit.Test_Cases.Registration;
   begin
      Register_Routine (T, Test_Inside_Circle'Access,
                        "Weapon inside circle");
      Register_Routine (T, Test_Crosses_Circle'Access,
                        "Path crosses circle");
      Register_Routine (T, Test_Outside_Circle'Access,
                        "Completely outside circle");
      Register_Routine (T, Test_Ends_In_Circle'Access,
                        "Will end in circle");
      Register_Routine (T, Test_Inside_Polygon'Access,
                        "Weapon inside polygon");
      Register_Routine (T, Test_Crosses_Polygon'Access,
                        "Path crosses polygon");
      Register_Routine (T, Test_Outside_Polygon'Access,
                        "Completely outside polygon");
      Register_Routine (T, Test_Clips_Triangle'Access,
                        "Path clips triangle");
   end Register_Tests;

end Geozone_Tests;
