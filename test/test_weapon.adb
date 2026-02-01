with Ada.Text_IO;       use Ada.Text_IO;
with Interfaces.C;      use Interfaces.C;
with Geozone_Binding;   use Geozone_Binding;

procedure Test_Weapon is

   procedure Print_Result (Label : String; R : Geo_Zone_Result) is
   begin
      Put_Line ("--- " & Label & " ---");
      if R.In_Zone = 1 then
         Put_Line ("  [X] Currently IN the zone");
      else
         Put_Line ("  [ ] Currently NOT in the zone");
      end if;
      if R.Will_Cross = 1 then
         Put_Line ("  [X] Will CROSS through the zone");
      else
         Put_Line ("  [ ] Will NOT cross through the zone");
      end if;
      if R.Will_End_In = 1 then
         Put_Line ("  [X] Will END UP in the zone");
      else
         Put_Line ("  [ ] Will NOT end up in the zone");
      end if;
      New_Line;
   end Print_Result;

   Circle   : aliased Geo_Circle;
   Polygon  : aliased Geo_Polygon;
   Current  : aliased Geo_Point;
   Future   : aliased Geo_Point;
   Result   : aliased Geo_Zone_Result;

begin
   Put_Line ("=== GEOZONE WEAPON TEST ===");
   New_Line;

   -- Test 1: Weapon currently inside a circular no-fly zone
   Put_Line ("Test 1: Weapon inside circular zone (1km radius)");
   Circle.Center.Latitude := 40.0;
   Circle.Center.Longitude := -105.0;
   Circle.Radius_Meters := 1000.0;
   Current.Latitude := 40.001;
   Current.Longitude := -105.001;
   Future.Latitude := 40.05;
   Future.Longitude := -105.05;
   Check_Circle_Zone (Circle'Access, Current'Access,
                      Future'Access, Result'Access);
   Print_Result ("Circle: Weapon starts inside", Result);

   -- Test 2: Weapon outside circle, path crosses through
   Put_Line ("Test 2: Weapon path crosses circular zone");
   Current.Latitude := 39.98;
   Current.Longitude := -105.0;
   Future.Latitude := 40.02;
   Future.Longitude := -105.0;
   Check_Circle_Zone (Circle'Access, Current'Access,
                      Future'Access, Result'Access);
   Print_Result ("Circle: Path crosses zone", Result);

   -- Test 3: Weapon completely outside circle
   Put_Line ("Test 3: Weapon completely outside circular zone");
   Current.Latitude := 41.0;
   Current.Longitude := -106.0;
   Future.Latitude := 41.5;
   Future.Longitude := -106.5;
   Check_Circle_Zone (Circle'Access, Current'Access,
                      Future'Access, Result'Access);
   Print_Result ("Circle: Completely outside", Result);

   -- Test 4: Weapon heading into circle (will end in zone)
   Put_Line ("Test 4: Weapon will end up in circular zone");
   Current.Latitude := 40.05;
   Current.Longitude := -105.0;
   Future.Latitude := 40.002;
   Future.Longitude := -105.001;
   Check_Circle_Zone (Circle'Access, Current'Access,
                      Future'Access, Result'Access);
   Print_Result ("Circle: Will end in zone", Result);

   -- Set up a square polygon zone around (35.0, -100.0)
   -- Approximately 2km x 2km square
   Polygon.Num_Points := 4;
   Polygon.Points (0).Latitude := 34.99;
   Polygon.Points (0).Longitude := -100.01;
   Polygon.Points (1).Latitude := 34.99;
   Polygon.Points (1).Longitude := -99.99;
   Polygon.Points (2).Latitude := 35.01;
   Polygon.Points (2).Longitude := -99.99;
   Polygon.Points (3).Latitude := 35.01;
   Polygon.Points (3).Longitude := -100.01;

   -- Test 5: Weapon inside polygon zone
   Put_Line ("Test 5: Weapon inside polygon zone");
   Current.Latitude := 35.0;
   Current.Longitude := -100.0;
   Future.Latitude := 35.0;
   Future.Longitude := -100.0;
   Check_Polygon_Zone (Polygon'Access, Current'Access,
                       Future'Access, Result'Access);
   Print_Result ("Polygon: Weapon inside", Result);

   -- Test 6: Weapon path crosses polygon
   Put_Line ("Test 6: Weapon path crosses polygon zone");
   Current.Latitude := 34.95;
   Current.Longitude := -100.0;
   Future.Latitude := 35.05;
   Future.Longitude := -100.0;
   Check_Polygon_Zone (Polygon'Access, Current'Access,
                       Future'Access, Result'Access);
   Print_Result ("Polygon: Path crosses zone", Result);

   -- Test 7: Weapon completely outside polygon
   Put_Line ("Test 7: Weapon completely outside polygon zone");
   Current.Latitude := 36.0;
   Current.Longitude := -101.0;
   Future.Latitude := 36.5;
   Future.Longitude := -101.5;
   Check_Polygon_Zone (Polygon'Access, Current'Access,
                       Future'Access, Result'Access);
   Print_Result ("Polygon: Completely outside", Result);

   -- Test 8: Triangle zone with weapon path clipping corner
   Put_Line ("Test 8: Triangle zone, path clips through");
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
   Print_Result ("Triangle: Path clips through", Result);

   Put_Line ("=== ALL TESTS COMPLETE ===");
end Test_Weapon;
