#include "geozone.h"
#include <cmath>

static const double DEG_TO_RAD = 3.14159265358979323846 / 180.0;
static const double EARTH_RADIUS_M = 6371000.0;

static double haversine_distance(GeoPoint a, GeoPoint b)
{
    double dlat = (b.latitude - a.latitude) * DEG_TO_RAD;
    double dlon = (b.longitude - a.longitude) * DEG_TO_RAD;
    double lat1 = a.latitude * DEG_TO_RAD;
    double lat2 = b.latitude * DEG_TO_RAD;

    double h = sin(dlat / 2.0) * sin(dlat / 2.0) +
               cos(lat1) * cos(lat2) *
               sin(dlon / 2.0) * sin(dlon / 2.0);
    double c = 2.0 * atan2(sqrt(h), sqrt(1.0 - h));
    return EARTH_RADIUS_M * c;
}

static void to_local(GeoPoint ref, GeoPoint p, double &x, double &y)
{
    x = (p.longitude - ref.longitude) * DEG_TO_RAD * EARTH_RADIUS_M *
        cos(ref.latitude * DEG_TO_RAD);
    y = (p.latitude - ref.latitude) * DEG_TO_RAD * EARTH_RADIUS_M;
}

static double closest_t_on_segment(double px, double py,
                                   double ax, double ay,
                                   double bx, double by)
{
    double dx = bx - ax;
    double dy = by - ay;
    double len_sq = dx * dx + dy * dy;
    if (len_sq < 1e-12) {
        return 0.0;
    }
    double t = ((px - ax) * dx + (py - ay) * dy) / len_sq;
    if (t < 0.0) t = 0.0;
    if (t > 1.0) t = 1.0;
    return t;
}

static bool point_in_polygon_local(double px, double py,
                                   const double *poly_x,
                                   const double *poly_y,
                                   int n)
{
    bool inside = false;
    int j = n - 1;
    for (int i = 0; i < n; i++) {
        if (((poly_y[i] > py) != (poly_y[j] > py)) &&
            (px < (poly_x[j] - poly_x[i]) * (py - poly_y[i]) /
                  (poly_y[j] - poly_y[i]) + poly_x[i])) {
            inside = !inside;
        }
        j = i;
    }
    return inside;
}

static double cross2d(double ax, double ay, double bx, double by)
{
    return ax * by - ay * bx;
}

static bool segments_intersect(double ax, double ay, double bx, double by,
                               double cx, double cy, double dx, double dy)
{
    double abx = bx - ax, aby = by - ay;
    double cdx = dx - cx, cdy = dy - cy;
    double acx = cx - ax, acy = cy - ay;

    double denom = cross2d(abx, aby, cdx, cdy);
    if (fabs(denom) < 1e-12) {
        return false; /* parallel */
    }

    double t = cross2d(acx, acy, cdx, cdy) / denom;
    double u = cross2d(acx, acy, abx, aby) / denom;

    return (t >= 0.0 && t <= 1.0 && u >= 0.0 && u <= 1.0);
}

static bool segment_crosses_polygon(double ax, double ay,
                                    double bx, double by,
                                    const double *poly_x,
                                    const double *poly_y,
                                    int n)
{
    for (int i = 0; i < n; i++) {
        int j = (i + 1) % n;
        if (segments_intersect(ax, ay, bx, by,
                               poly_x[i], poly_y[i],
                               poly_x[j], poly_y[j])) {
            return true;
        }
    }
    return false;
}

void check_circle_zone(const GeoCircle *zone, const GeoPoint *current,
                        const GeoPoint *future, GeoZoneResult *result)
{
    /* Check if current position is in zone */
    double dist_current = haversine_distance(*current, zone->center);
    result->in_zone = (dist_current <= zone->radius_meters) ? 1 : 0;

    /* Check if future position is in zone */
    double dist_future = haversine_distance(*future, zone->center);
    result->will_end_in = (dist_future <= zone->radius_meters) ? 1 : 0;

    /* Check if path crosses zone: find closest approach of line segment
       to circle center in local coordinates */
    double ax, ay, bx, by;
    to_local(zone->center, *current, ax, ay);
    to_local(zone->center, *future, bx, by);

    double t = closest_t_on_segment(0.0, 0.0, ax, ay, bx, by);
    double closest_x = ax + t * (bx - ax);
    double closest_y = ay + t * (by - ay);
    double min_dist = sqrt(closest_x * closest_x + closest_y * closest_y);

    result->will_cross = (min_dist <= zone->radius_meters) ? 1 : 0;
}

void check_polygon_zone(const GeoPolygon *zone, const GeoPoint *current,
                         const GeoPoint *future, GeoZoneResult *result)
{
    if (zone->num_points < 3) {
        result->in_zone = 0;
        result->will_cross = 0;
        result->will_end_in = 0;
        return;
    }

    /* Use centroid as reference for local coordinate conversion */
    GeoPoint ref;
    ref.latitude = 0.0;
    ref.longitude = 0.0;
    for (int i = 0; i < zone->num_points; i++) {
        ref.latitude += zone->points[i].latitude;
        ref.longitude += zone->points[i].longitude;
    }
    ref.latitude /= zone->num_points;
    ref.longitude /= zone->num_points;

    /* Convert polygon to local coords */
    double poly_x[GEOZONE_MAX_POLYGON_POINTS];
    double poly_y[GEOZONE_MAX_POLYGON_POINTS];
    for (int i = 0; i < zone->num_points; i++) {
        to_local(ref, zone->points[i], poly_x[i], poly_y[i]);
    }

    /* Convert current and future to local coords */
    double cur_x, cur_y, fut_x, fut_y;
    to_local(ref, *current, cur_x, cur_y);
    to_local(ref, *future, fut_x, fut_y);

    /* Check if current position is in polygon */
    result->in_zone = point_in_polygon_local(cur_x, cur_y,
                                             poly_x, poly_y,
                                             zone->num_points) ? 1 : 0;

    /* Check if future position is in polygon */
    result->will_end_in = point_in_polygon_local(fut_x, fut_y,
                                                 poly_x, poly_y,
                                                 zone->num_points) ? 1 : 0;

    /* Check if path crosses polygon: either an endpoint is inside
       or the segment intersects an edge */
    bool crosses = (result->in_zone == 1) ||
                   (result->will_end_in == 1) ||
                   segment_crosses_polygon(cur_x, cur_y, fut_x, fut_y,
                                           poly_x, poly_y, zone->num_points);
    result->will_cross = crosses ? 1 : 0;
}
