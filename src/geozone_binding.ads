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

   type Geo_Point_Ptr is access all Geo_Point;
   pragma Convention (C, Geo_Point_Ptr);

   type Geo_Circle_Ptr is access all Geo_Circle;
   pragma Convention (C, Geo_Circle_Ptr);

   type Geo_Polygon_Ptr is access all Geo_Polygon;
   pragma Convention (C, Geo_Polygon_Ptr);

   type Geo_Zone_Result_Ptr is access all Geo_Zone_Result;
   pragma Convention (C, Geo_Zone_Result_Ptr);

   procedure Check_Circle_Zone
     (Zone    : Geo_Circle_Ptr;
      Current : Geo_Point_Ptr;
      Future  : Geo_Point_Ptr;
      Result  : Geo_Zone_Result_Ptr);
   pragma Import (C, Check_Circle_Zone, "check_circle_zone");

   procedure Check_Polygon_Zone
     (Zone    : Geo_Polygon_Ptr;
      Current : Geo_Point_Ptr;
      Future  : Geo_Point_Ptr;
      Result  : Geo_Zone_Result_Ptr);
   pragma Import (C, Check_Polygon_Zone, "check_polygon_zone");

end Geozone_Binding;
