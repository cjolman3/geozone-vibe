#ifndef GEOZONE_H
#define GEOZONE_H

#ifdef __cplusplus
extern "C" {
#endif

#define GEOZONE_MAX_POLYGON_POINTS 9

typedef struct {
    double latitude;
    double longitude;
} GeoPoint;

typedef struct {
    GeoPoint center;
    double radius_meters;
} GeoCircle;

typedef struct {
    GeoPoint points[GEOZONE_MAX_POLYGON_POINTS];
    int num_points;
} GeoPolygon;

typedef struct {
    int in_zone;       /* 1 if current position is in zone */
    int will_cross;    /* 1 if path from current to future crosses the zone */
    int will_end_in;   /* 1 if future position is in zone */
} GeoZoneResult;

/* Check current and future positions against a circular geozone */
void check_circle_zone(const GeoCircle *zone, const GeoPoint *current,
                        const GeoPoint *future, GeoZoneResult *result);

/* Check current and future positions against a polygonal geozone */
void check_polygon_zone(const GeoPolygon *zone, const GeoPoint *current,
                         const GeoPoint *future, GeoZoneResult *result);

#ifdef __cplusplus
}
#endif

#endif /* GEOZONE_H */
