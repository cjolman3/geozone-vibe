with Interfaces.C; use Interfaces.C;

package Geozone_Binding is

   Max_Polygon_Points : constant := 9;

   type Geo_Point is record
      Latitude  : double := 0.0;
      Longitude : double := 0.0;
   end record;
   pragma Convention (C, Geo_Point);

   type Geo_Circle is record
      Center        : Geo_Point;
      Radius_Meters : double := 0.0;
   end record;
   pragma Convention (C, Geo_Circle);

   type Point_Array is array (0 .. Max_Polygon_Points - 1) of Geo_Point;
   pragma Convention (C, Point_Array);

   type Geo_Polygon is record
      Points     : Point_Array;
      Num_Points : int := 0;
   end record;
   pragma Convention (C, Geo_Polygon);

   type Geo_Zone_Result is record
      In_Zone     : int := 0;
      Will_Cross  : int := 0;
      Will_End_In : int := 0;
   end record;
   pragma Convention (C, Geo_Zone_Result);

   procedure Check_Circle_Zone
     (Zone    : access constant Geo_Circle;
      Current : access constant Geo_Point;
      Future  : access constant Geo_Point;
      Result  : access Geo_Zone_Result);
   pragma Import (C, Check_Circle_Zone, "check_circle_zone");

   procedure Check_Polygon_Zone
     (Zone    : access constant Geo_Polygon;
      Current : access constant Geo_Point;
      Future  : access constant Geo_Point;
      Result  : access Geo_Zone_Result);
   pragma Import (C, Check_Polygon_Zone, "check_polygon_zone");

end Geozone_Binding;
