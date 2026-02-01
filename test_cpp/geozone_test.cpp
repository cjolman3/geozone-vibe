#include <cppunit/TestCase.h>
#include <cppunit/TestFixture.h>
#include <cppunit/TestSuite.h>
#include <cppunit/TestCaller.h>
#include <cppunit/TestRunner.h>
#include <cppunit/extensions/HelperMacros.h>
#include <cppunit/ui/text/TestRunner.h>

#include "geozone.h"

class GeozoneTest : public CppUnit::TestFixture {
    CPPUNIT_TEST_SUITE(GeozoneTest);
    CPPUNIT_TEST(testInsideCircle);
    CPPUNIT_TEST(testCrossesCircle);
    CPPUNIT_TEST(testOutsideCircle);
    CPPUNIT_TEST(testEndsInCircle);
    CPPUNIT_TEST(testInsidePolygon);
    CPPUNIT_TEST(testCrossesPolygon);
    CPPUNIT_TEST(testOutsidePolygon);
    CPPUNIT_TEST(testClipsTriangle);
    CPPUNIT_TEST_SUITE_END();

private:
    GeoCircle circle;
    GeoPolygon polygon;
    GeoPoint current;
    GeoPoint future;
    GeoZoneResult result;

    void setupSquarePolygon() {
        polygon.num_points = 4;
        polygon.points[0] = {34.99, -100.01};
        polygon.points[1] = {34.99, -99.99};
        polygon.points[2] = {35.01, -99.99};
        polygon.points[3] = {35.01, -100.01};
    }

public:
    void testInsideCircle() {
        circle.center = {40.0, -105.0};
        circle.radius_meters = 1000.0;
        current = {40.001, -105.001};
        future = {40.05, -105.05};

        check_circle_zone(&circle, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should be IN the zone",
                                     1, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should CROSS the zone (leaving)",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in zone",
                                     0, result.will_end_in);
    }

    void testCrossesCircle() {
        circle.center = {40.0, -105.0};
        circle.radius_meters = 1000.0;
        current = {39.98, -105.0};
        future = {40.02, -105.0};

        check_circle_zone(&circle, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in zone",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon path should CROSS zone",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in zone",
                                     0, result.will_end_in);
    }

    void testOutsideCircle() {
        circle.center = {40.0, -105.0};
        circle.radius_meters = 1000.0;
        current = {41.0, -106.0};
        future = {41.5, -106.5};

        check_circle_zone(&circle, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in zone",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT cross zone",
                                     0, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in zone",
                                     0, result.will_end_in);
    }

    void testEndsInCircle() {
        circle.center = {40.0, -105.0};
        circle.radius_meters = 1000.0;
        current = {40.05, -105.0};
        future = {40.002, -105.001};

        check_circle_zone(&circle, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in zone initially",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should CROSS into zone",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should END in zone",
                                     1, result.will_end_in);
    }

    void testInsidePolygon() {
        setupSquarePolygon();
        current = {35.0, -100.0};
        future = {35.0, -100.0};

        check_polygon_zone(&polygon, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should be IN polygon",
                                     1, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should CROSS (still in zone)",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should END in polygon",
                                     1, result.will_end_in);
    }

    void testCrossesPolygon() {
        setupSquarePolygon();
        current = {34.95, -100.0};
        future = {35.05, -100.0};

        check_polygon_zone(&polygon, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in polygon",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should CROSS polygon",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in polygon",
                                     0, result.will_end_in);
    }

    void testOutsidePolygon() {
        setupSquarePolygon();
        current = {36.0, -101.0};
        future = {36.5, -101.5};

        check_polygon_zone(&polygon, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in polygon",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT cross polygon",
                                     0, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in polygon",
                                     0, result.will_end_in);
    }

    void testClipsTriangle() {
        polygon.num_points = 3;
        polygon.points[0] = {30.0, -90.0};
        polygon.points[1] = {30.0, -89.9};
        polygon.points[2] = {30.05, -89.95};
        current = {30.01, -90.01};
        future = {30.01, -89.89};

        check_polygon_zone(&polygon, &current, &future, &result);

        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT be in triangle",
                                     0, result.in_zone);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should CROSS triangle",
                                     1, result.will_cross);
        CPPUNIT_ASSERT_EQUAL_MESSAGE("Weapon should NOT end in triangle",
                                     0, result.will_end_in);
    }
};

CPPUNIT_TEST_SUITE_REGISTRATION(GeozoneTest);

int main() {
    CppUnit::TextUi::TestRunner runner;
    runner.addTest(GeozoneTest::suite());
    return runner.run() ? 0 : 1;
}
