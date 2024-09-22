CREATE TABLE objects(
	id BIGSERIAL NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
    coord1 DECIMAL NOT NULL,
	coord2 DECIMAL NOT NULL,
	type VARCHAR(50) NOT NULL,
	creationTime BIGINT NOT NULL
);

CREATE OR REPLACE FUNCTION getSortedGroupByFirstLetter() RETURNS TABLE (
	object_group text,
    object_name varchar,
    object_coord1 DECIMAL,
	object_coord2 DECIMAL,
	object_type varchar,
	object_creationTime BIGINT
)
language plpgsql
as $$
BEGIN
	RETURN QUERY 
	SELECT 
    CASE 
        WHEN LEFT(name, 1) BETWEEN 'А' AND 'Я' THEN LEFT(name, 1)
        ELSE '#'
    END AS myGroup,
    name,
    coord1,
	coord2,
	type,
	creationTime
FROM objects
ORDER BY 
    myGroup,
    name;
END;
$$;

CREATE OR REPLACE FUNCTION getSortedGroupByTypeCount(N int) RETURNS TABLE (
	object_group varchar,
    object_name varchar,
    object_coord1 DECIMAL,
	object_coord2 DECIMAL,
	object_type varchar,
	object_creationTime BIGINT
)
language plpgsql
as $$
BEGIN
	RETURN QUERY 
	SELECT 
    CASE 
        WHEN (SELECT COUNT(type) FROM objects AS t2 WHERE t2.type = t1.type) > N THEN type
        ELSE 'Разное'
    END AS myGroup,
    name,
    coord1,
	coord2,
	type,
	creationTime
FROM objects AS t1
ORDER BY myGroup, name;
END;
$$;

CREATE OR REPLACE FUNCTION getSortedGroupByDistance() RETURNS TABLE (
	object_group text,
    object_name varchar,
    object_coord1 DECIMAL,
	object_coord2 DECIMAL,
	object_type varchar,
	object_creationTime BIGINT
)
language plpgsql
as $$
BEGIN
	RETURN QUERY 
	SELECT
	CASE 
        WHEN ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry) < 100 THEN 'До 100'
		WHEN ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry) >= 100 AND ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry) < 1000 THEN 'До 1000'
		WHEN ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry) >= 1000 AND ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry) < 10000 THEN 'До 10000'
        ELSE 'Слишком далеко'
    END AS myGroup,
	name,
    coord1,
	coord2,
	type,
	creationTime
FROM objects
ORDER BY myGroup, ST_Distance(point(0,0)::geometry, point(coord1, coord2)::geometry);
END;
$$;

CREATE OR REPLACE FUNCTION getSortedGroupByDate() RETURNS TABLE (
	object_group text,
    object_name varchar,
    object_coord1 DECIMAL,
	object_coord2 DECIMAL,
	object_type varchar,
	object_creationTime BIGINT
)
language plpgsql
as $$
BEGIN
	RETURN QUERY 
	SELECT CASE
		WHEN to_timestamp(creationTime)::DATE = CURRENT_TIMESTAMP THEN 'Сегодня'
		WHEN to_timestamp(creationTime)::DATE = (CURRENT_TIMESTAMP::DATE + INTERVAL '1 DAY')::DATE THEN 'Завтра'
		WHEN to_timestamp(creationTime) >= date_trunc('week', CURRENT_TIMESTAMP)
			 AND to_timestamp(creationTime) < date_trunc('week', CURRENT_TIMESTAMP + INTERVAL '1 WEEK') THEN 'На этой неделе'
		WHEN to_timestamp(creationTime) >= date_trunc('month', CURRENT_TIMESTAMP)
			 AND to_timestamp(creationTime) < date_trunc('month', CURRENT_TIMESTAMP + INTERVAL '1 MONTH') THEN 'В этом месяце'
		WHEN to_timestamp(creationTime) >= date_trunc('year', CURRENT_TIMESTAMP)
			 AND to_timestamp(creationTime) < date_trunc('year', CURRENT_TIMESTAMP + INTERVAL '1 YEAR') THEN 'В этом году'
		ELSE 'Ранее'
    END AS myGroup,
	name,
    coord1,
	coord2,
	type,
	creationTime
FROM objects
ORDER BY myGroup, creationTime;
END;
$$;

insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2388.386158, 1450.852364, 'здание', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1122.917159, -2244.071716, 'дом', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 930.389699, 773.508212, 'камень', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -148.077903, 692.17401, 'кирпич', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 730.583571, -682.98233, 'часы', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3361.321035, 1654.385335, 'часы', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 260.843226, 580.368468, 'книга', 1726953276);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 746.154349, -2904.330495, 'машина', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2469.005179, 3108.512069, 'часы', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2453.456003, -2775.281801, 'почтовый ящик', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2103.964238, -2525.249111, 'ручка', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2522.477213, -2507.375307, 'столб', 1722294051);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -1188.809278, 1950.150954, 'дом', 1762823205);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -3395.181975, 2096.589342, 'вайлдбериз', 1704790192);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -731.174971, -2699.243372, 'машина', 1750369243);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 213.286621, 1178.106487, 'озон', 1717884640);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2305.337566, 18.660694, 'машина', 1737598844);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2785.068808, 1970.820787, 'почтовый ящик', 1786023372);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3126.409469, 2638.580165, 'кирпич', 1717936255);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1849.795428, -1681.100452, 'телефон', 1782405348);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1232.214804, 2690.54062, 'банк', 1750754687);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3007.512354, 2830.686447, 'телефон', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 3047.441444, -3319.941554, 'кирпич', 1713835207);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -211.610442, 134.90935, 'камень', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 3108.279153, 1893.069719, 'столб', 1785424823);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1401.591891, -2920.454736, 'телефон', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3022.635599, -1835.946348, 'банк', 1761095540);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1361.325619, 2434.931638, 'вайлдбериз', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 256.609461, -3306.699544, 'вайлдбериз', 1780598730);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3249.970862, -3213.405456, 'машина', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1929.876246, 2729.047605, 'машина', 1727853696);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1973.01439, 2731.083329, 'телефон', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 10.094723, -562.152754, 'камень', 1782844173);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2798.43628, 2016.065126, 'столб', 1714203780);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 853.091603, -367.938552, 'вайлдбериз', 1777251419);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -502.910496, -695.200284, 'здание', 1751615365);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2260.984422, 1068.699617, 'компьютер', 1761444965);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2317.72068, 2928.807231, 'озон', 1770229203);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2049.491521, -621.851827, 'озон', 1753918563);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1843.703799, -2777.005911, 'здание', 1757341071);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -10.461362, -3134.747474, 'компьютер', 1743276088);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 51.514668, 2752.138081, 'озон', 1722930135);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1651.767788, 2015.887306, 'озон', 1750078899);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2155.757658, -2655.225769, 'дом', 1752900758);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1355.098188, -1715.192133, 'почтовый ящик', 1762302292);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2509.591121, 3145.302919, 'ручка', 1743493938);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2259.24969, 2043.546616, 'ручка', 1716179585);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1483.678425, 1015.58891, 'почтовый ящик', 1753880065);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2310.442045, -1939.33259, 'кирпич', 1740540354);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -3431.246895, 991.691213, 'ручка', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -3052.55357, -563.621698, 'машина', 1748384315);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2008.252599, -1969.982925, 'машина', 1737714652);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2818.867362, -2615.049907, 'озон', 1717281877);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1452.174049, -1412.134872, 'почтовый ящик', 1775721679);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2396.944074, -2262.768033, 'машина', 1769297967);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2215.002117, 2211.448723, 'телефон', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 701.241687, -2346.673983, 'книга', 1772322154);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -490.725832, 3401.495958, 'озон', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -855.25938, 715.773047, 'камень', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1411.259858, -987.165906, 'камень', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -145.603548, -1655.986162, 'вайлдбериз', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2810.231147, -7.611858, 'дом', 1717709687);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2009.043488, -25.935812, 'дом', 1724318534);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -545.237632, -2133.462602, 'телефон', 1725584665);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2211.175687, -1590.05298, 'вайлдбериз', 1698533733);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -817.956747, 1919.05941, 'камень', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -568.790832, -1901.176065, 'камень', 1754519547);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2953.977913, 2503.60245, 'часы', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2279.626929, -1912.258527, 'компьютер', 1748265156);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2249.190899, 3343.216799, 'машина', 1727172794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 341.57484, -939.335832, 'камень', 1730027560);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1770.592464, -1194.849362, 'машина', 1727431994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 495.481449, -307.703304, 'телефон', 1748767825);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2672.999158, 835.859991, 'столб', 1727431994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1951.185761, -2324.616802, 'озон', 1705557833);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -615.042606, -880.734465, 'компьютер', 1758014114);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2551.83101, -2803.197825, 'столб', 1716728778);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2403.179477, 3114.427283, 'банк', 1727431994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2135.123729, -1757.829341, 'книга', 1724835255);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 327.422367, -1800.650931, 'вайлдбериз', 1748025605);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3421.28103, 190.68515, 'здание', 1727431994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 3221.843592, 1100.884671, 'здание', 1769778379);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -960.097923, 2872.164944, 'камень', 1727431994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2306.488126, 503.080647, 'телефон', 1701413283);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1782.68115, -2775.249235, 'столб', 1730503333);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2034.575874, -2029.005193, 'книга', 1727518394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1.484331, 1779.771744, 'машина', 1720223994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 117.728275, 1675.313985, 'компьютер', 1742235956);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1948.255745, 3354.331847, 'часы', 1750835405);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 171.364995, -3216.781982, 'озон', 1727518394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1108.271361, 120.86442, 'камень', 1715449980);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1329.651504, -2621.979971, 'почтовый ящик', 1703527925);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 422.167337, 3241.80681, 'здание', 1730815505);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1849.949178, -2527.423216, 'дом', 1727518394);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1998.479953, 2819.113819, 'озон', 1720071133);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2812.349769, -3016.690141, 'машина', 1727604794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2320.897584, 3383.305707, 'здание', 1727518394);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2148.922753, 3405.46749, 'вайлдбериз', 1752259640);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3025.077367, -2836.639148, 'столб', 1732287344);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2358.827273, -1401.302354, 'здание', 1727604794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2487.11492, 3177.867548, 'машина', 1700016443);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1821.057852, -153.121796, 'камень', 1760827326);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 893.612499, 1042.042678, 'камень', 1727604794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2964.813101, 1590.059746, 'телефон', 1753818703);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2965.727437, 2843.491256, 'машина', 1718835207);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1000.019202, 1701.276261, 'книга', 1769745908);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1446.732977, 1266.846378, 'столб', 1773654405);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3175.597898, -2413.961974, 'часы', 1765932645);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2490.424849, 194.384355, 'ручка', 1717059778);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2330.780938, 2919.987112, 'столб', 1727691194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1888.357796, 2742.07193, 'компьютер', 1727691194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 3408.506275, 3386.159018, 'компьютер', 1727691194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2644.486537, -1709.459906, 'вайлдбериз', 1727691194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1001.12905, 1796.025472, 'банк', 1727249256);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 708.507467, -1532.609685, 'почтовый ящик', 1754610823);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2610.241174, 3043.05786, 'вайлдбериз', 1762808611);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 249.661475, 1281.799093, 'компьютер', 1743554758);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -742.429985, -86.473499, 'кирпич', 1748416025);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2431.550644, 1526.290705, 'озон', 1735087543);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 891.968698, 1162.131306, 'телефон', 1731206841);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -356.854412, 351.992873, 'камень', 1738044986);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3357.226926, 817.096353, 'кирпич', 1725099194);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1269.903444, -2180.357634, 'телефон', 1733866819);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2888.063661, 1510.419381, 'озон', 1725099194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1229.54323, -2358.275109, 'ручка', 1785054023);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1793.832286, -3143.471788, 'почтовый ящик', 1758271787);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 533.663138, -2034.50192, 'телефон', 1725099194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3365.661971, 1462.77039, 'вайлдбериз', 1727141089);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2877.145303, -3082.821517, 'вайлдбериз', 1760922115);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2328.167418, 1033.008491, 'машина', 1720335032);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -960.138229, 3296.062538, 'здание', 1771008631);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -709.849245, 3139.464629, 'машина', 1738749842);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -3135.134353, -719.971883, 'кирпич', 1725099194);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 142.199267, -1312.477652, 'книга', 1718248501);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 806.605022, 899.725659, 'озон', 1779474282);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1414.778336, 2825.296821, 'почтовый ящик', 1703439926);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -804.86397, 1153.297618, 'банк', 1711503780);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1427.889602, 323.18609, 'озон', 1750585473);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1673.325873, -1686.266559, 'вайлдбериз', 1729178702);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 560.6936, 1053.427086, 'здание', 1733161995);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -430.193137, 70.398144, 'дом', 1717862828);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1352.471789, -1050.370402, 'ручка', 1749168497);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -767.890749, 926.925995, 'часы', 1715032142);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2487.891707, -470.110329, 'телефон', 1698644665);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3272.059607, 1542.991326, 'телефон', 1726999994);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2412.197454, 3201.407284, 'камень', 1718580749);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3072.088986, 3087.346663, 'озон', 1780320881);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2475.60348, 1870.537575, 'книга', 1710936955);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2155.011387, 2988.231067, 'часы', 1715795288);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2591.543025, -884.2128, 'почтовый ящик', 1715733305);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -178.240887, -1039.942521, 'книга', 1783611450);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -3180.353377, -917.489603, 'компьютер', 1711945890);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 717.454715, 2834.893729, 'компьютер', 1757433614);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1251.015992, -688.081992, 'дом', 1710768168);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2933.062819, 2669.396477, 'телефон', 1740509282);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1624.580837, 3263.910301, 'часы', 1726999994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1612.169342, -203.004702, 'ручка', 1699408564);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 26.865351, 455.197649, 'кирпич', 1769667794);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1741.82486, 219.159941, 'книга', 1732274769);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3012.732588, 1059.504118, 'столб', 1732884684);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1895.860975, 2372.965989, 'ручка', 1732157693);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -904.930042, 706.684855, 'почтовый ящик', 1704372909);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2728.229947, 2282.625414, 'здание', 1742895074);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2257.761894, 218.695326, 'почтовый ящик', 1783917511);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2536.954317, -403.275885, 'книга', 1745241223);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2415.487751, 1393.223433, 'ручка', 1716207474);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 156.73958, 3065.610962, 'ручка', 1776731496);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -991.066348, 1006.786082, 'вайлдбериз', 1726999994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -651.393804, -3339.164203, 'здание', 1785245207);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2482.773979, 1320.735058, 'ручка', 1777944394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2026.062926, 1437.612161, 'вайлдбериз', 1769892433);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1724.34549, -2268.962925, 'банк', 1726246592);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2461.742249, -176.84133, 'камень', 1739260713);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3415.869393, -13.985701, 'вайлдбериз', 1718725966);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1092.546303, 2409.762359, 'здание', 1764880038);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3025.007196, 216.077465, 'книга', 1786792476);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1101.586815, -409.856947, 'часы', 1726999994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2946.262419, 3331.3871, 'компьютер', 1749533122);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1611.789908, -1410.728692, 'телефон', 1750400318);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 671.018079, 1218.548082, 'почтовый ящик', 1784785209);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1022.820512, -3253.165477, 'машина', 1704336953);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -3127.231644, -3335.013169, 'машина', 1699400394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2125.392684, 2538.418105, 'часы', 1776240482);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1893.056547, -2433.302982, 'столб', 1715307477);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 476.672724, 581.155844, 'книга', 1726999994);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -3317.95931, -2918.911171, 'ручка', 1716249528);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2475.219406, -2322.992159, 'вайлдбериз', 1740931199);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2109.726679, 1978.424815, 'банк', 1715575220);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2091.580304, 2447.87717, 'ручка', 1734129903);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3008.152981, -2768.257649, 'ручка', 1762839943);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1149.340562, 1198.344144, 'камень', 1729566280);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2055.605485, 1464.200804, 'озон', 1706983716);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1422.125972, -3241.152377, 'книга', 1747166694);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1748.032709, -996.880213, 'часы', 1758570515);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1671.760255, -2052.109735, 'телефон', 1784693267);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2260.329463, -853.321582, 'почтовый ящик', 1779310811);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -214.29107, -2694.352638, 'часы', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 178.568803, -1895.098988, 'банк', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1731.038385, 2366.553835, 'кирпич', 1784708967);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -779.226812, -1350.651616, 'озон', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2863.086483, 2870.482975, 'почтовый ящик', 1726921554);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3418.236101, -2623.697079, 'столб', 1731968796);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 506.949435, -3017.656069, 'кирпич', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2529.049006, 432.665847, 'часы', 1698202032);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1307.762294, 453.493217, 'здание', 1727086394);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -184.033547, 670.784554, 'кирпич', 1738616382);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1347.390634, -2077.608319, 'кирпич', 1775443004);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 838.596073, 2457.534504, 'кирпич', 1706927733);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2031.445785, -284.101926, 'часы', 1726913594);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2071.628555, 1562.176086, 'дом', 1718973753);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -256.509608, -886.613171, 'вайлдбериз', 1768703769);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 109.907699, -2150.759895, 'дом', 1726913594);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2366.922108, 1434.99538, 'машина', 1777435988);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 622.986694, 2572.018831, 'телефон', 1726913594);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1141.358294, -829.22744, 'здание', 1743199313);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2384.745071, 272.115404, 'ручка', 1736239504);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -87.361449, 145.825183, 'машина', 1726913594);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -218.804928, -2102.15629, 'ручка', 1707055576);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -449.034913, -1441.648091, 'озон', 1757504392);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1349.153693, 1669.881709, 'камень', 1752523851);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1370.135257, -254.148128, 'здание', 1715607715);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -316.820978, -371.560718, 'почтовый ящик', 1774739227);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2678.518891, 3331.435321, 'столб', 1709521039);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1254.894809, 3039.714545, 'книга', 1706664859);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 354.469147, -1179.85858, 'банк', 1783370687);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -1097.091144, -3059.136634, 'телефон', 1765120058);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1344.972584, -1128.492027, 'здание', 1729862515);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -956.059384, -2210.188773, 'почтовый ящик', 1717450828);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2040.607874, -2665.150872, 'дом', 1719185997);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -191.361736, -816.260736, 'машина', 1702629632);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 428.110326, -378.323697, 'компьютер', 1732916885);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -325.170862, -1645.540212, 'часы', 1777218285);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -237.290901, -183.575218, 'часы', 1733656614);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -952.120672, 531.896389, 'компьютер', 1747485898);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2822.205965, 153.849932, 'компьютер', 1724868309);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -602.398657, -480.149599, 'вайлдбериз', 1725388420);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2949.276733, -366.665706, 'компьютер', 1764195090);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2742.85397, 881.553696, 'ручка', 1699900584);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2590.587626, 2873.233815, 'кирпич', 1718744250);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 3056.707317, 3003.411717, 'часы', 1781042465);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2193.821772, -908.542485, 'столб', 1786562754);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 569.887691, 1625.761785, 'дом', 1765170975);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1316.196746, 106.309026, 'книга', 1714796222);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1983.249196, 1839.464379, 'почтовый ящик', 1707038422);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2157.89917, -1554.722754, 'книга', 1786760472);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2663.534546, 2114.927441, 'машина', 1777506386);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1388.47134, 2809.366877, 'банк', 1718993865);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 681.113226, -711.018365, 'машина', 1716474084);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2039.489836, 2631.398753, 'камень', 1698592936);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 19.917733, -451.69425, 'дом', 1717279167);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2705.197085, -3068.207429, 'озон', 1700581234);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1870.178313, 1791.671003, 'почтовый ящик', 1751279583);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 772.369085, -3052.988622, 'книга', 1786070314);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 306.563186, -1935.241832, 'здание', 1779368332);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2772.843035, 2250.616445, 'озон', 1778614186);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 3107.425686, -3356.421913, 'почтовый ящик', 1761686123);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2099.491257, -1014.198646, 'ручка', 1752241893);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -935.179805, -2719.25722, 'здание', 1734695077);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -186.714326, -696.474612, 'вайлдбериз', 1767676469);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -295.257897, -1175.417449, 'камень', 1715042382);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1809.295205, -966.04208, 'вайлдбериз', 1720628315);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 707.72272, -1713.854459, 'почтовый ящик', 1759447423);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2767.2794, -2230.8898, 'дом', 1763954350);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -192.855987, 2285.636268, 'столб', 1775135321);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1562.82978, 3211.809396, 'кирпич', 1742570102);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1548.256676, 3021.103451, 'вайлдбериз', 1758271696);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 484.134675, -2519.850872, 'камень', 1761835241);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 741.548276, 1905.90513, 'столб', 1721664420);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2106.438934, 1817.120632, 'столб', 1756832834);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1120.984463, 2066.914222, 'здание', 1748626914);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2513.925591, -1504.748398, 'кирпич', 1711718486);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1217.821676, -2562.595985, 'почтовый ящик', 1712608972);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -3421.397335, -839.055885, 'машина', 1772731396);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2224.061317, -188.18034, 'озон', 1766012112);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2266.307758, -1531.228696, 'банк', 1697472125);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2472.849019, -1034.141711, 'ручка', 1771282762);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2050.630226, -41.125002, 'книга', 1735488283);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1099.107577, 2181.695715, 'почтовый ящик', 1726262293);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2065.447641, -3072.81452, 'озон', 1697651446);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 909.321152, 2083.324806, 'почтовый ящик', 1769960105);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 927.895689, -1843.143447, 'машина', 1762973537);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2281.662693, -1474.229003, 'банк', 1754822112);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2131.443851, -1431.23897, 'машина', 1712237467);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1565.249693, 2484.995864, 'дом', 1756928491);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1383.272648, 2940.263006, 'компьютер', 1772927541);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2667.074679, 411.787264, 'книга', 1766994283);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1300.670729, 181.53783, 'почтовый ящик', 1775498353);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 833.368843, 2772.763044, 'телефон', 1730280447);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3278.800952, -717.494434, 'часы', 1752233485);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2724.084856, -120.707735, 'камень', 1754434376);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 3109.478042, -2426.266154, 'дом', 1760136313);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1504.438366, -3077.554934, 'телефон', 1729669673);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2414.442919, -2557.949358, 'книга', 1783121845);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3078.185312, -1908.64328, 'камень', 1758397296);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1288.390184, -2226.931242, 'столб', 1752908248);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 903.999464, -341.978355, 'камень', 1709897917);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2828.323527, 1926.087612, 'вайлдбериз', 1724722296);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2837.401737, -2135.425747, 'столб', 1759485312);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2840.022226, 3068.064283, 'компьютер', 1710320020);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2315.874871, -3298.333624, 'почтовый ящик', 1738565206);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -814.840093, -1097.410326, 'столб', 1778932588);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2776.343602, -3231.978468, 'дом', 1775245765);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3068.865444, 985.735017, 'кирпич', 1700141515);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1064.619249, 1792.69946, 'телефон', 1761327195);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 177.81294, 967.449973, 'озон', 1732475788);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -797.115035, 631.898846, 'вайлдбериз', 1730672808);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1984.785979, -496.864498, 'телефон', 1755092620);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 395.652391, 426.610638, 'часы', 1717266239);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1724.721674, -667.218811, 'озон', 1778645095);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 3344.024348, 1913.429107, 'кирпич', 1722005827);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1998.244945, 194.09246, 'здание', 1749930875);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -517.164867, -2025.171564, 'камень', 1711358929);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1980.038883, 1632.16928, 'книга', 1763252026);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2446.418215, -2648.127843, 'телефон', 1732240879);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 238.745848, 3354.087781, 'столб', 1701814004);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2427.106589, -2980.655378, 'камень', 1722385667);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 3124.454364, 695.345799, 'телефон', 1728976258);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 12.934477, -148.537279, 'кирпич', 1713245645);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 57.845503, -657.19552, 'здание', 1757523966);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2420.970538, 2010.840683, 'компьютер', 1720516293);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3380.505891, 2159.562663, 'озон', 1771491270);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1546.247192, 2013.89728, 'телефон', 1713541730);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 857.925911, -44.400013, 'озон', 1765135325);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 3013.812174, -3332.877703, 'компьютер', 1737741568);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2899.994555, -2536.542031, 'банк', 1758469491);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -58.86069, 3068.493215, 'банк', 1765233186);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2083.276984, 3066.547581, 'часы', 1781256728);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1265.896652, 1192.880928, 'часы', 1754899604);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2032.583663, 437.503059, 'камень', 1710845352);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -386.778974, 1756.780137, 'здание', 1782371976);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 231.606663, 1617.820219, 'банк', 1777825369);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -276.711876, 1990.417074, 'книга', 1703744909);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1333.829876, -575.060483, 'компьютер', 1785914283);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2635.631008, -1024.479912, 'почтовый ящик', 1778561039);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 907.311757, 1678.913164, 'книга', 1712691028);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2069.215514, -2330.522459, 'компьютер', 1725951222);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2528.410309, -1414.468264, 'компьютер', 1732559749);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1225.296646, -1777.036061, 'дом', 1708432580);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -615.34546, 2622.547602, 'камень', 1786136762);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1333.388483, -662.902063, 'вайлдбериз', 1725909219);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1867.447478, -1490.242979, 'почтовый ящик', 1734385665);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 835.32883, -2514.451748, 'почтовый ящик', 1769431485);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1552.374657, -906.418387, 'часы', 1775859548);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2786.029648, 898.856737, 'компьютер', 1730021652);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2914.72462, 2710.650765, 'машина', 1729542580);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -501.061721, 3423.639428, 'озон', 1746382115);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1423.735308, 272.114961, 'столб', 1700705570);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 327.739749, 1280.911235, 'здание', 1737281215);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2412.581258, 179.095303, 'часы', 1707817104);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2116.711937, -2652.005757, 'столб', 1708302235);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2915.411757, 1655.16654, 'дом', 1774311825);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3429.20032, -2272.653581, 'телефон', 1754011806);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1735.250236, -2660.267338, 'телефон', 1785353856);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -69.954075, -2438.32758, 'машина', 1776374031);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1688.49671, -1772.227092, 'машина', 1702486798);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1363.171223, -2253.685198, 'машина', 1771643378);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -943.46835, -2147.838048, 'телефон', 1718402107);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2128.869132, 2917.371865, 'камень', 1705704072);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -207.351933, -2600.092886, 'кирпич', 1724233383);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1160.651701, -2476.538987, 'банк', 1728869753);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -812.427666, -1892.357656, 'столб', 1757309091);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2511.364864, 168.82444, 'книга', 1717685278);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 3277.513409, -2588.822229, 'книга', 1743068825);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2197.037604, 1547.595735, 'компьютер', 1730509442);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2306.392488, -1847.63493, 'камень', 1733426188);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -3107.765865, -381.676322, 'здание', 1749451128);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1332.541299, 104.167229, 'почтовый ящик', 1762926251);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1493.658241, 409.613431, 'озон', 1755420584);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 712.878658, -3287.564594, 'часы', 1739896473);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2459.858, 3058.930311, 'банк', 1733944272);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2798.330672, -2640.90928, 'вайлдбериз', 1768647517);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2.315473, 1214.889461, 'телефон', 1746613890);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1949.642258, 1934.611785, 'книга', 1772980484);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -852.453484, 3230.006544, 'вайлдбериз', 1716313725);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -424.882631, -2629.38602, 'дом', 1713171299);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1183.327451, -1687.67687, 'книга', 1785915161);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1583.50847, 369.657431, 'часы', 1784850164);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1481.158219, -1805.430951, 'здание', 1747358543);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1646.608208, -946.104957, 'книга', 1738156983);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2833.249173, -919.755505, 'здание', 1711225899);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1363.272599, -2779.005998, 'машина', 1741845415);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -423.718848, 117.679424, 'машина', 1748745779);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1940.47437, -1886.065535, 'телефон', 1744122477);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2967.966005, -47.275576, 'здание', 1769113715);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -631.408942, 2575.814191, 'ручка', 1770070413);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -187.947548, 7.7289, 'здание', 1782745135);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -616.44515, 2871.595161, 'ручка', 1734178117);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 584.306554, 2937.830006, 'вайлдбериз', 1779896728);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2624.094067, 327.129308, 'дом', 1731197659);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1506.070043, -2863.015172, 'книга', 1758128431);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1579.379891, 1815.114093, 'телефон', 1757817507);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -25.626043, -327.151193, 'банк', 1767534497);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 3336.562777, -1688.685914, 'камень', 1763946524);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 880.143392, 1343.730392, 'озон', 1730051864);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1942.053418, 3213.313395, 'вайлдбериз', 1719723109);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1285.798626, 2785.870328, 'озон', 1701204889);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -138.84743, 1408.013807, 'телефон', 1730813827);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -660.283365, 1881.834407, 'ручка', 1744936805);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1723.297842, 30.5017, 'вайлдбериз', 1762697264);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1892.898152, -1085.937773, 'почтовый ящик', 1701216202);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1904.411072, -2286.536052, 'дом', 1734317623);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 3276.832866, -3021.150054, 'часы', 1736242772);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -447.386362, 1488.878303, 'здание', 1705076131);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -192.121178, 160.325932, 'столб', 1708276079);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2636.209547, -1900.672372, 'здание', 1731836126);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3068.962565, -2904.574769, 'часы', 1777628073);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -921.77194, -2207.605829, 'машина', 1712420371);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 922.815703, 2576.969453, 'часы', 1708341040);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -534.128685, 2785.965183, 'телефон', 1768747808);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -954.916096, 2530.373241, 'столб', 1754459686);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2738.288119, 854.501718, 'вайлдбериз', 1741369181);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2688.954978, -3180.418521, 'озон', 1729244602);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2628.734233, 1061.219993, 'машина', 1741655280);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2282.522793, 3229.408153, 'кирпич', 1771587263);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 662.051516, -1477.6164, 'кирпич', 1752539717);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2432.887523, 3296.104799, 'книга', 1783593474);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -3165.074603, -274.074228, 'озон', 1711898279);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2565.854437, 3407.619934, 'телефон', 1755280683);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1327.179661, 1573.061746, 'вайлдбериз', 1764928354);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 387.001859, -1961.020739, 'машина', 1715633836);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1038.755923, -3013.849667, 'часы', 1701362081);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2013.260261, 81.087711, 'дом', 1778251895);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2657.369044, -498.595078, 'телефон', 1730554705);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2794.800171, 761.015964, 'дом', 1764515982);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2558.300958, -1445.243034, 'озон', 1731232862);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2651.992591, 3267.451538, 'ручка', 1754205768);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1975.717757, 1399.754869, 'банк', 1765057434);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2999.758292, 207.602706, 'телефон', 1734863018);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 616.008624, 641.705609, 'телефон', 1739649834);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1647.568211, 1813.280402, 'часы', 1777189552);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1396.340095, -669.965501, 'ручка', 1765746913);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3255.972548, 1867.040328, 'здание', 1748008926);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 979.298129, 3068.50477, 'машина', 1709061084);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1313.173859, 1568.370475, 'часы', 1729947097);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1853.864234, -782.15647, 'книга', 1763093653);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2161.493301, 1215.530327, 'камень', 1754519536);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -550.713772, 1328.148602, 'банк', 1722994323);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 389.474006, 2622.531806, 'часы', 1753908472);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1931.565877, 3403.439194, 'столб', 1715230103);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1745.236456, -914.35547, 'кирпич', 1757861250);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 92.054685, -142.773854, 'столб', 1756314264);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2294.115312, 557.781995, 'здание', 1718773314);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1694.88289, 3345.449156, 'телефон', 1783320273);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 762.778897, 53.631127, 'кирпич', 1766255776);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 331.559726, -1141.081219, 'машина', 1741268230);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 868.693681, -242.478268, 'ручка', 1714441873);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2168.811876, 3079.68696, 'озон', 1750498853);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 576.202897, 1593.10953, 'столб', 1755617457);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2193.613203, -2225.545978, 'столб', 1770542247);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2677.694952, 1893.670131, 'телефон', 1765230099);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2027.797144, 2944.048361, 'камень', 1708504728);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1492.258142, 1331.286601, 'озон', 1729190390);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1147.490055, -816.311204, 'банк', 1744197869);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -70.87095, 2088.752561, 'компьютер', 1739479481);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1481.272206, 1475.708428, 'телефон', 1700227417);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2003.430792, 171.595423, 'компьютер', 1712342354);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -3419.713368, -334.341798, 'машина', 1719895591);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1148.105873, -3029.432016, 'почтовый ящик', 1711097106);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 3123.286147, -1082.720921, 'машина', 1723729582);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1085.855108, -2569.373733, 'почтовый ящик', 1768467235);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2535.494038, -1555.357858, 'озон', 1701264020);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1373.018003, 332.463655, 'камень', 1767787154);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2745.249612, -2705.123951, 'кирпич', 1765864231);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1692.476376, -2921.597577, 'телефон', 1727489366);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1939.551292, 631.824923, 'компьютер', 1741885980);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2725.740807, 2363.529194, 'телефон', 1706005308);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2775.647605, 265.942801, 'банк', 1733694478);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2930.549704, -3359.711516, 'машина', 1717500954);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -582.336297, 3273.286371, 'дом', 1726882440);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2696.980556, -2191.8977, 'столб', 1753528581);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -3186.693599, -115.800867, 'дом', 1712023900);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2875.075541, 1277.865791, 'телефон', 1784399468);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2007.324131, -2668.099804, 'телефон', 1743318902);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -35.446893, 3073.135185, 'ручка', 1744379637);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3240.199301, -226.255157, 'ручка', 1734889494);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3369.671472, 884.325064, 'книга', 1756497310);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1397.830575, -715.176095, 'кирпич', 1731559456);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1220.032929, 401.385188, 'камень', 1732697828);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -697.376876, -1934.051594, 'часы', 1705833136);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2499.26814, 499.056048, 'вайлдбериз', 1702341537);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2267.096604, 1200.056531, 'столб', 1751233883);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 762.036585, 1937.607199, 'камень', 1700235680);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 333.662077, -2483.897844, 'кирпич', 1718054343);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1557.410732, 2503.292146, 'дом', 1753491878);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1197.710305, -506.793197, 'дом', 1752367273);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1206.632443, -966.818521, 'книга', 1777364927);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 419.708848, -1527.264979, 'дом', 1724518570);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2689.110817, -2959.582806, 'кирпич', 1782031964);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -598.344165, -2203.086466, 'здание', 1780949088);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2285.122286, 2109.016475, 'ручка', 1749780764);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 777.03869, -2153.309745, 'телефон', 1714519649);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2031.269632, 2648.168016, 'здание', 1733726912);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2811.101745, 2347.893439, 'телефон', 1700187139);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -3306.775892, 509.502782, 'озон', 1786705017);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1276.128948, -1880.798236, 'почтовый ящик', 1739180617);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2146.39523, 3216.323374, 'столб', 1736731371);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 262.449989, 2885.366169, 'камень', 1784509442);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -319.108963, 76.926036, 'здание', 1766658016);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1231.900992, 2128.068997, 'книга', 1765536367);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -1924.555624, 2599.141884, 'дом', 1718681029);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 591.331497, -3076.954388, 'ручка', 1699866135);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1544.870358, 223.554079, 'озон', 1784284948);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 870.753324, -2913.815385, 'почтовый ящик', 1727160708);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 959.270699, 2133.850948, 'камень', 1708527028);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -721.140988, 1168.161151, 'телефон', 1727900195);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1309.885017, -1233.88094, 'компьютер', 1761058890);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 85.141434, -274.690783, 'здание', 1786326821);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2362.604201, 1416.483162, 'часы', 1752133796);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2832.465679, -367.326752, 'кирпич', 1761859780);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -881.373667, 1599.285823, 'компьютер', 1743289235);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -496.586807, 3241.044915, 'компьютер', 1718843937);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1862.958044, -1703.523084, 'телефон', 1778717664);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2645.350917, -797.013856, 'компьютер', 1723798963);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2959.468377, 1932.646698, 'озон', 1750837098);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 3382.592477, -2129.198791, 'банк', 1775508438);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1611.397048, 570.40794, 'телефон', 1745966809);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2833.175067, 1106.733987, 'машина', 1725305012);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -199.833878, 1639.513121, 'компьютер', 1724691820);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 954.462184, 2780.610974, 'банк', 1706861489);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1983.782795, 763.688439, 'машина', 1770078077);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2247.267964, 3140.013346, 'часы', 1705988513);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -521.426549, 1391.120999, 'книга', 1713946418);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1382.439391, -1817.476373, 'банк', 1725311207);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1485.807287, -1916.19381, 'телефон', 1709537641);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2895.324125, 2942.07029, 'машина', 1782811013);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2171.960994, 1871.982474, 'телефон', 1754084432);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2601.893709, 3333.602923, 'телефон', 1783659832);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -3003.510237, -2209.721349, 'телефон', 1742131902);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2144.12545, 2265.860808, 'камень', 1786126718);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 3326.243085, -2193.724498, 'телефон', 1714292122);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1910.570517, 2521.523077, 'часы', 1729600520);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2156.342929, -2942.853911, 'книга', 1717831496);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1913.142713, 1139.667688, 'компьютер', 1714061451);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -438.571439, 3106.742318, 'вайлдбериз', 1698696338);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2778.236992, 2110.688397, 'часы', 1736798310);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 792.484647, -1929.514499, 'машина', 1740905251);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2931.043244, -3366.16457, 'почтовый ящик', 1700498792);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 193.333008, 177.645191, 'дом', 1761587720);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -3184.140858, -549.277937, 'книга', 1778786868);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -979.886818, -239.958944, 'компьютер', 1773211380);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2435.887693, 2378.943154, 'кирпич', 1717839038);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1747.839926, 182.671538, 'телефон', 1733541950);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1900.625141, -2689.090904, 'здание', 1781987601);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 393.060516, 1720.799386, 'камень', 1706785839);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2945.996492, -2177.166836, 'банк', 1786760064);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 970.883187, -625.73099, 'часы', 1722045332);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -286.406865, -1447.318796, 'камень', 1735342075);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1701.096174, 936.964564, 'камень', 1761682468);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3120.905249, -2700.53114, 'машина', 1716125413);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -53.258815, -3073.586426, 'телефон', 1734854638);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2401.6822, -362.332696, 'озон', 1744099730);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 803.782308, 508.163213, 'здание', 1742885367);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2198.6847, -1892.084466, 'компьютер', 1774859460);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -1308.252472, 400.849385, 'ручка', 1776916104);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2560.187813, -3306.629233, 'книга', 1758974176);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 59.64941, 2277.519366, 'телефон', 1781387601);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 730.106791, -584.962927, 'банк', 1721148400);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1169.717872, 1657.718298, 'книга', 1756235566);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 3419.567623, -2026.117553, 'озон', 1785833740);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1394.432798, 1013.709119, 'машина', 1782771912);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2715.225571, -3089.477788, 'дом', 1759199794);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 3112.178746, 2856.41605, 'озон', 1709881764);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1418.76235, -1008.196538, 'машина', 1701406639);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1498.528175, 3351.835037, 'ручка', 1721619414);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2767.256932, 1275.145911, 'столб', 1769613938);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1765.049977, -397.278577, 'озон', 1781249753);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 317.866726, -1630.545566, 'вайлдбериз', 1755937176);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1090.807513, -1030.421744, 'камень', 1749531097);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2258.178359, -2962.877062, 'ручка', 1721799549);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -898.028355, 999.839714, 'почтовый ящик', 1717242571);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1968.469113, -3188.838073, 'телефон', 1785478420);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1642.07601, -2663.452998, 'дом', 1740955848);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1826.053543, -2097.902345, 'ручка', 1701762747);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 414.885606, 3209.274452, 'телефон', 1762916164);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -558.431631, 506.611241, 'столб', 1754198197);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1997.886425, -704.684003, 'компьютер', 1751718462);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 223.635282, 2504.705027, 'ручка', 1769749157);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -888.846153, 703.578497, 'камень', 1720776884);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1878.438497, 3364.905622, 'ручка', 1771517044);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -3427.674388, -1850.705326, 'дом', 1738424515);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2147.694575, -631.615387, 'ручка', 1723001912);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2643.798772, -2562.888103, 'телефон', 1753885386);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 850.939869, 1378.614158, 'камень', 1750682218);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1877.666369, -1926.714572, 'банк', 1753415957);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2307.55145, 3329.082465, 'машина', 1719045220);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1955.973812, -676.234463, 'телефон', 1716479375);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 681.852807, 1145.825774, 'столб', 1707729979);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -483.177007, -584.445895, 'столб', 1726213558);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1050.06721, -2249.082832, 'дом', 1725231760);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2101.875659, -192.147665, 'почтовый ящик', 1783751885);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1700.043593, -2388.583855, 'дом', 1775098750);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1377.919124, 1529.776796, 'дом', 1710244498);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2353.053255, 3080.241388, 'книга', 1713775803);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 931.251376, -2094.096478, 'столб', 1710245007);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 48.400879, 2222.672847, 'дом', 1781396422);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2638.542831, -1358.688244, 'телефон', 1712958226);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 735.143445, 2896.991353, 'часы', 1757813207);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1645.449192, 1216.7901, 'вайлдбериз', 1773082082);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2692.650049, 2467.026116, 'часы', 1780028957);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2961.245154, -25.053074, 'почтовый ящик', 1721931429);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 441.129312, -1053.490736, 'часы', 1765732997);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2342.661046, 3237.763384, 'почтовый ящик', 1702779465);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1947.266577, 2236.987394, 'ручка', 1713566530);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -1693.404224, -3055.655908, 'часы', 1731832124);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1703.428191, -2085.562554, 'вайлдбериз', 1745884300);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -757.287007, 2034.628394, 'книга', 1764593096);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -892.488439, -2794.541193, 'телефон', 1781612734);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -819.353497, -2549.421346, 'камень', 1757828738);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1694.19003, 603.076126, 'дом', 1735052482);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1637.02352, 1292.323035, 'камень', 1781675845);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 722.002055, 3041.694045, 'телефон', 1771607915);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -160.360566, 2255.532445, 'компьютер', 1775929765);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2098.607502, 819.214579, 'кирпич', 1764366828);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1331.274202, -2740.00644, 'часы', 1755773168);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2108.567318, -1083.825835, 'банк', 1740943253);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1488.892206, -1989.555936, 'почтовый ящик', 1745959609);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 330.351618, 2190.687765, 'здание', 1714699673);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 895.902807, -2997.710431, 'книга', 1767814246);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2289.462145, 432.634675, 'банк', 1700161232);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2977.794861, -628.093327, 'ручка', 1728036180);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -3274.777377, -1074.16731, 'почтовый ящик', 1744599079);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 207.799126, 3017.910257, 'банк', 1762588653);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2537.133832, -2847.357734, 'компьютер', 1751966111);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 466.875747, 1096.423031, 'здание', 1704293081);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -3233.519807, -2249.384504, 'вайлдбериз', 1710198152);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -831.878623, -1.801211, 'дом', 1724333179);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3174.239366, -1545.334577, 'камень', 1732450920);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2958.526869, 2291.787269, 'часы', 1756442899);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 3203.421376, -618.431236, 'банк', 1780979445);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2166.272805, 2909.438908, 'озон', 1717798488);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1725.696352, 2037.408388, 'камень', 1765439767);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1187.934257, -152.510703, 'часы', 1729941318);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1154.277273, -2173.028397, 'книга', 1784822181);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -289.527242, -2573.964834, 'столб', 1704939182);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2263.790474, 229.725538, 'часы', 1705133485);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2033.473738, -635.39574, 'почтовый ящик', 1770507253);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3168.174941, 3310.658613, 'дом', 1776078073);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1896.249583, 418.048568, 'телефон', 1770363187);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2353.80879, 2984.670686, 'компьютер', 1720939723);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1414.043191, -1613.003385, 'банк', 1780874395);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2568.056613, -3326.641536, 'машина', 1764114137);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2889.259485, 1369.256757, 'кирпич', 1713159972);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2892.481412, 2466.290913, 'телефон', 1782636639);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1492.647981, -1505.886236, 'озон', 1727710531);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1574.312214, -2514.045774, 'почтовый ящик', 1712997875);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -425.832668, -1371.470315, 'часы', 1726853182);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1185.833993, 3394.900508, 'здание', 1783462074);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1305.827891, 2195.855511, 'компьютер', 1761090065);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 875.802385, -2893.897003, 'ручка', 1741232388);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 1840.562073, -289.199105, 'машина', 1736385896);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -511.579526, 2180.045203, 'озон', 1778692205);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1767.603812, -922.649251, 'дом', 1723511637);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 778.454211, 2933.483477, 'столб', 1739325773);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1424.47273, -1019.084694, 'дом', 1782567362);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 862.595558, 1096.070352, 'вайлдбериз', 1769841535);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -901.178346, 1459.646163, 'почтовый ящик', 1763065866);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 3093.410736, -1564.737355, 'озон', 1739838656);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1028.888004, 1562.328869, 'столб', 1761099494);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 978.417373, -624.956593, 'столб', 1729486332);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1692.427245, -1473.399915, 'почтовый ящик', 1738155416);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 86.619062, -1070.254699, 'здание', 1754247681);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -3032.07416, -1547.477807, 'столб', 1777821709);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1730.024261, -2598.312752, 'столб', 1775219494);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -185.508816, -1746.208921, 'ручка', 1756774553);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1138.538687, -3216.576925, 'столб', 1724263541);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 3339.224288, 1870.294238, 'ручка', 1704557722);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2329.51467, 2595.840781, 'здание', 1771940064);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1019.707263, -3184.3385, 'машина', 1750200198);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -661.221032, 982.449378, 'кирпич', 1754957458);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2225.620973, 62.91745, 'компьютер', 1767986131);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1676.579233, -2753.881035, 'машина', 1759557492);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3234.14389, 2226.578877, 'банк', 1763649240);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2758.315301, 1044.259848, 'здание', 1748730425);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3198.506762, 686.003794, 'часы', 1748927294);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2143.374463, -1043.995078, 'телефон', 1739082548);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1408.930925, 1635.41515, 'камень', 1716590723);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2128.892301, -3080.669311, 'часы', 1769913408);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1670.599839, -924.117169, 'здание', 1744147409);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3045.763761, -2235.531697, 'машина', 1773393301);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2654.703239, 1529.04172, 'ручка', 1717758852);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1295.547227, 2303.419672, 'книга', 1759808043);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1105.124025, 104.1239, 'столб', 1713255308);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 178.325328, 1081.618904, 'банк', 1750143827);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -161.07984, 1734.433336, 'здание', 1735584234);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3240.306889, -812.887197, 'здание', 1743726422);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2383.027744, -709.992741, 'книга', 1711469451);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1508.035811, 1306.765574, 'банк', 1779152570);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2381.43243, -977.963961, 'ручка', 1766555295);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1441.417415, 915.562054, 'книга', 1773768074);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -127.035013, -2500.85246, 'дом', 1748927801);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 529.21023, -213.684781, 'банк', 1738556056);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1301.113284, -3349.702709, 'телефон', 1697705213);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -525.797811, 2883.610832, 'почтовый ящик', 1738846581);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1327.86753, -2266.28674, 'вайлдбериз', 1704297632);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1371.869313, 979.769339, 'машина', 1760449117);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2284.475341, 1827.777775, 'книга', 1731683735);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 3139.489081, -363.587201, 'кирпич', 1786758334);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1598.736645, -992.281362, 'кирпич', 1719079661);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1541.589339, -3047.88884, 'кирпич', 1777611914);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2393.052345, 3428.15921, 'кирпич', 1773178427);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -340.0917, 1763.622217, 'озон', 1785216415);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1047.050136, -1230.80988, 'телефон', 1712587379);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1555.551742, -1369.022499, 'вайлдбериз', 1714968027);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2342.926623, 2381.400692, 'кирпич', 1745103852);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2876.631007, -2009.918522, 'книга', 1757300390);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1861.500978, -2302.17854, 'банк', 1699872657);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2877.065255, -2394.910096, 'часы', 1725776489);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1832.039198, 790.72721, 'ручка', 1733006249);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2761.017298, -83.142879, 'книга', 1755552614);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2407.411336, -255.032229, 'ручка', 1767202283);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1332.737861, -1311.892326, 'озон', 1697231788);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1481.572849, -1220.543448, 'озон', 1769482497);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 926.10227, 2594.937492, 'столб', 1720208213);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 3118.155414, -2370.628594, 'почтовый ящик', 1711314125);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -629.15196, -722.353708, 'почтовый ящик', 1763389904);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1018.960261, 3386.843612, 'часы', 1762398466);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1103.109328, 117.530666, 'кирпич', 1737175220);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2918.307504, 192.127477, 'дом', 1755456364);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2862.838144, 908.182654, 'ручка', 1737745517);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -2467.140929, -607.227807, 'озон', 1700218307);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2188.941003, 1455.105447, 'машина', 1780617916);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2128.599612, -1096.634854, 'ручка', 1770336216);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -585.968752, -357.15768, 'банк', 1715579110);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3141.457549, 2792.083808, 'ручка', 1705740722);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1154.782746, -1835.433998, 'дом', 1777317506);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1420.053998, 1195.693103, 'ручка', 1749450100);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1069.219544, 3137.313025, 'дом', 1713338107);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2111.936989, -1439.041463, 'вайлдбериз', 1704767748);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -691.216746, -2906.193831, 'книга', 1697177213);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2738.705179, 2161.604427, 'компьютер', 1702060471);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2777.375127, 1008.116149, 'телефон', 1710714340);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -45.43501, -2243.949733, 'здание', 1768349600);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -3166.036408, 3269.427028, 'столб', 1778112998);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1061.345043, 3415.969931, 'почтовый ящик', 1759848898);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1876.352948, 3169.946163, 'дом', 1735241963);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2357.896706, 2256.163545, 'вайлдбериз', 1728512901);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 3300.473934, -2238.976063, 'почтовый ящик', 1781839972);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -3371.901916, 1783.957584, 'кирпич', 1768105011);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1967.570681, 2073.826859, 'книга', 1724028406);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 104.74895, 561.203118, 'часы', 1770829158);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2560.37001, -2387.229267, 'дом', 1758373052);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3312.412009, 642.000229, 'часы', 1748348778);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3016.536774, -2078.875879, 'ручка', 1781269174);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 741.174727, -2911.319002, 'компьютер', 1708288180);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 217.090965, -2097.734143, 'столб', 1716395920);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1093.617509, -139.155822, 'компьютер', 1697412500);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1569.539206, -3015.723308, 'вайлдбериз', 1770981422);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -473.789756, -3349.805205, 'здание', 1734127642);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -629.820682, -1843.506592, 'машина', 1768450466);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2913.598019, -2120.527447, 'вайлдбериз', 1715350362);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1777.825197, 2310.363274, 'почтовый ящик', 1776347009);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1651.221687, -252.398324, 'банк', 1718011605);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1966.182814, -437.667062, 'ручка', 1715604829);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 2942.638916, -3300.156213, 'телефон', 1786216155);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 494.248578, -786.584116, 'часы', 1777552513);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2549.339268, 1358.656317, 'дом', 1761929605);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1700.686604, 3041.334942, 'телефон', 1737946183);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -1918.781309, -2785.432953, 'кирпич', 1706899514);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2172.119451, -3053.013075, 'вайлдбериз', 1768042510);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 46.452244, 1288.905293, 'камень', 1734305111);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 931.669302, 1125.610658, 'дом', 1777452222);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -542.722833, -1239.009668, 'книга', 1733600445);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 370.378828, 1215.235711, 'почтовый ящик', 1768812494);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -170.867346, -2297.585932, 'банк', 1728832188);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1760.941384, 1147.665376, 'озон', 1755670149);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1270.794065, -2833.548032, 'книга', 1711040919);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2470.338882, 2958.390183, 'компьютер', 1700053249);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2215.200285, -3421.738246, 'банк', 1770712037);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2232.073394, 3132.42432, 'ручка', 1729369338);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -580.957592, 3401.151716, 'машина', 1708513841);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1833.19905, -2649.592603, 'кирпич', 1756970650);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2558.634953, -816.250665, 'здание', 1786826156);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1294.144584, -936.726598, 'телефон', 1719834602);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2324.20405, -1556.601729, 'компьютер', 1744844191);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2528.820502, 3254.10397, 'столб', 1737071319);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 955.971104, 3058.831828, 'телефон', 1726597538);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2154.131093, 1234.292581, 'озон', 1739197744);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1269.383759, -1046.728154, 'компьютер', 1733001515);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -687.586685, 2177.266395, 'почтовый ящик', 1712141519);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2395.509826, 2565.070494, 'здание', 1777805836);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 903.510433, 1957.328273, 'столб', 1735222557);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3021.10384, 1229.445513, 'кирпич', 1710796262);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 3157.500046, 549.710241, 'озон', 1709717023);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1322.987331, 713.567914, 'камень', 1712821625);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 2228.064615, -1248.671057, 'банк', 1698653125);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1431.209747, -2179.814314, 'банк', 1726851364);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2411.352805, -1288.897734, 'ручка', 1707671128);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1614.294231, 2065.200419, 'вайлдбериз', 1734803290);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3333.593086, 118.599649, 'кирпич', 1699293080);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3298.748483, -2943.158014, 'озон', 1733009817);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2364.900479, -2970.116314, 'телефон', 1712612893);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2627.284787, 3242.169551, 'компьютер', 1763644936);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 2866.489441, -2088.508416, 'компьютер', 1764055080);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1091.260919, -1416.850635, 'ручка', 1761089385);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -209.979767, -2645.905554, 'телефон', 1738577234);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -3357.632585, 1593.080944, 'ручка', 1723450124);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1245.709634, 554.097968, 'компьютер', 1748347583);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 523.511768, 1891.674721, 'компьютер', 1769544275);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1901.399361, 2883.000091, 'книга', 1720503081);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1776.604355, -3327.522166, 'здание', 1761191926);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2773.340856, 1519.871397, 'телефон', 1703368508);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2266.639382, -2381.204189, 'ручка', 1700113279);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2222.603139, 1789.070067, 'книга', 1762883846);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -992.04148, 453.181663, 'машина', 1781048129);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -560.939247, -2741.239495, 'банк', 1697134083);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -3171.823149, 1652.245393, 'телефон', 1770202258);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -766.191215, -82.456303, 'вайлдбериз', 1708334013);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -610.596962, 1881.085934, 'озон', 1708535593);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 52.795281, 3268.946195, 'здание', 1717860998);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2857.220817, -1844.378984, 'камень', 1740410490);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1501.451196, -2276.884562, 'машина', 1772075465);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1557.223648, 827.096221, 'банк', 1743897639);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1274.590136, 456.483288, 'компьютер', 1711020392);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2546.084161, 1458.146262, 'ручка', 1730090137);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1127.012837, -2179.38186, 'дом', 1718229474);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2390.612385, -934.846392, 'компьютер', 1735264636);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 590.954451, -1460.848907, 'почтовый ящик', 1773732847);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -1934.48047, -556.76647, 'компьютер', 1738615282);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -906.278008, -779.807382, 'здание', 1727006410);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1212.213231, 2629.837341, 'банк', 1703236880);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2504.565813, -1256.444143, 'вайлдбериз', 1720651094);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 2195.476892, -963.03755, 'камень', 1746458727);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1241.760011, 106.379948, 'кирпич', 1760783394);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -2894.729496, 2543.245248, 'телефон', 1751062655);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1207.878785, 2164.87413, 'книга', 1750631613);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2514.796824, -2860.290615, 'здание', 1766117248);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2861.078801, 1725.289201, 'ручка', 1760371487);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 414.857944, 366.216555, 'компьютер', 1737566748);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1429.345592, 226.338967, 'здание', 1770860925);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 437.76503, -1182.176149, 'дом', 1700196067);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 936.496978, 2382.981948, 'компьютер', 1704756672);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2737.734078, 1364.193299, 'машина', 1719904643);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -854.877054, -2130.711741, 'телефон', 1738354923);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1574.783821, -1809.596714, 'часы', 1757056884);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3376.570338, -1554.329767, 'озон', 1763009366);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2545.873931, -2519.782892, 'банк', 1783888787);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2681.851681, 2822.625875, 'здание', 1778510349);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2925.598052, -3323.398789, 'ручка', 1735477666);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 3357.230894, 2344.918996, 'здание', 1700192376);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 317.819628, -881.871684, 'столб', 1719438150);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 846.536985, -516.089366, 'телефон', 1736868991);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 723.694681, 2581.897168, 'машина', 1774953745);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -107.780412, 1382.183104, 'кирпич', 1770915243);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -408.196494, -541.001947, 'банк', 1736053495);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 1119.920533, 2453.231431, 'дом', 1745767200);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2624.28612, -844.120304, 'книга', 1699230303);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2174.281278, -3244.039293, 'камень', 1734338739);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 130.865284, -2216.640297, 'ручка', 1769945420);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2494.033903, -1459.473207, 'книга', 1775861434);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3134.45818, -2238.994295, 'камень', 1782630732);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -1324.047064, 1529.33556, 'книга', 1747184702);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2854.627594, -897.516023, 'почтовый ящик', 1778897796);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2811.019866, 2538.023615, 'банк', 1713811467);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -3305.3726, 730.434067, 'компьютер', 1761872005);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 2229.616841, -1213.495066, 'кирпич', 1748856242);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 2137.346788, -10.071379, 'телефон', 1710481511);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -1577.537634, 2134.944511, 'телефон', 1750777081);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -25.736435, -1852.620768, 'почтовый ящик', 1732515344);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 535.354715, -2841.835558, 'кирпич', 1740352723);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2108.416563, -755.760095, 'столб', 1727210346);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2798.792103, -695.411204, 'столб', 1714439750);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2350.994422, -2728.039448, 'столб', 1769234985);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 180.644215, 1604.76977, 'кирпич', 1742723791);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1186.127983, 583.594067, 'кирпич', 1751100459);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -314.477293, 2885.108985, 'камень', 1734265177);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2259.072567, 3306.723288, 'почтовый ящик', 1767194743);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 627.10847, -1038.254145, 'дом', 1759624070);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2507.850037, 664.231235, 'здание', 1777877194);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1415.396539, -1604.180321, 'телефон', 1722945282);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1248.303098, 240.642554, 'столб', 1729238486);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 3425.857747, -2143.203986, 'столб', 1714962464);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -2735.38864, 1555.193737, 'часы', 1763614623);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 3202.81205, -90.89806, 'кирпич', 1735326829);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1721.123933, 40.784488, 'дом', 1773809748);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1000.205846, -22.381985, 'книга', 1755863768);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 3278.241657, -1407.910149, 'машина', 1698830313);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1686.304203, -2678.064083, 'телефон', 1713011004);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2540.753561, 2071.571825, 'почтовый ящик', 1759058694);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -296.914603, 2540.43669, 'кирпич', 1728738432);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 812.002669, 3294.490507, 'кирпич', 1777993457);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1001.340569, 1962.06858, 'машина', 1734157866);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 371.859263, -128.490445, 'почтовый ящик', 1786388965);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -3103.338102, 1564.696416, 'книга', 1721485964);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1075.304704, -2080.585037, 'ручка', 1761417417);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 1276.421913, 1277.566137, 'озон', 1747536130);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1868.970596, -1567.973262, 'камень', 1779895425);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -361.419268, 113.470638, 'ручка', 1736114928);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2272.26912, 2743.00331, 'вайлдбериз', 1783983570);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1983.593917, -2372.118544, 'машина', 1772878407);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 3356.358649, 3202.328565, 'почтовый ящик', 1755473338);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -476.059394, 3244.459147, 'ручка', 1717626477);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 922.832875, -261.58117, 'ручка', 1765779739);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1477.037308, -1445.055306, 'банк', 1766687358);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1781.010593, -3196.578757, 'столб', 1714633541);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 984.147515, 55.829046, 'вайлдбериз', 1739342476);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1090.695806, 1696.673859, 'дом', 1737155368);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1353.434777, -769.478565, 'камень', 1755531239);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -927.305946, 1234.840456, 'банк', 1732828181);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -930.361216, 673.045899, 'здание', 1748237522);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -3131.962389, 27.606021, 'почтовый ящик', 1763963067);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1632.980453, -3413.499542, 'здание', 1771125126);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -2354.469507, -261.33943, 'банк', 1782708196);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1231.358042, 154.422223, 'книга', 1761601925);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2512.681886, 3395.225193, 'книга', 1707345246);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2431.172888, 1004.77464, 'почтовый ящик', 1734382340);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2145.19878, -1403.673608, 'камень', 1760275919);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -955.518918, -1350.366988, 'вайлдбериз', 1763504016);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1219.808165, -728.50971, 'дом', 1763186258);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -1757.586065, 720.411041, 'столб', 1754810662);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -717.432306, 844.975065, 'столб', 1764279104);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 867.08552, 1913.041556, 'дом', 1732135736);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 2806.102978, 2111.020997, 'камень', 1730188529);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 1864.186624, -2501.270314, 'ручка', 1754470968);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -2482.861975, -582.584908, 'камень', 1774438741);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -3306.71772, 877.91159, 'машина', 1718172031);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2184.488497, -1399.848476, 'кирпич', 1731204336);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3180.158351, 153.796342, 'озон', 1772317023);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -88.943332, -3139.96483, 'камень', 1698317928);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2367.2332, 955.733369, 'камень', 1738829921);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2291.686983, 795.432578, 'кирпич', 1779300134);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -125.020611, 3248.30906, 'ручка', 1710433029);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -424.073074, -1592.055966, 'озон', 1755751597);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2035.886358, 636.709205, 'столб', 1754624718);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 137.274062, 2669.372473, 'банк', 1774937760);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2375.908061, -130.531539, 'часы', 1726435598);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2139.891375, -1675.944851, 'камень', 1784360386);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 1273.381196, -1057.018125, 'книга', 1739091586);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -2630.462026, 1200.195116, 'компьютер', 1731721500);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 3112.42111, 1273.397572, 'компьютер', 1750973130);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2179.962582, -732.236572, 'кирпич', 1720365741);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3201.718718, -1151.300396, 'озон', 1701430106);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -1224.251507, 808.446951, 'камень', 1720733286);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1616.103606, -639.243928, 'компьютер', 1771281808);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -1397.338638, -53.031095, 'компьютер', 1718236245);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 283.075177, 1710.509554, 'банк', 1712371106);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -3039.141162, 2626.925961, 'ручка', 1708588571);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2338.063814, 893.862705, 'ручка', 1742362280);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', -2841.116535, 724.388156, 'книга', 1768617779);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2644.499119, -3256.782247, 'озон', 1754279126);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 1529.152187, 2178.951513, 'книга', 1777374160);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', -2611.011179, -14.583026, 'часы', 1708996355);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2462.378013, -780.160281, 'почтовый ящик', 1774005771);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -396.196244, 2404.954978, 'ручка', 1735020990);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2075.533919, -2285.895755, 'машина', 1729348913);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1298.584394, 3194.375141, 'озон', 1756468023);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3128.288293, 1833.42569, 'почтовый ящик', 1725069329);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 784.971627, -1805.866565, 'компьютер', 1702224006);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2331.08659, -1933.615323, 'банк', 1753379804);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1512.640583, -620.745049, 'банк', 1735092521);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -1226.732058, 1639.855965, 'озон', 1736906189);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', -809.254402, 935.452978, 'книга', 1713759519);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 3405.381611, 1618.793465, 'дом', 1724750235);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 142.617825, 1825.365388, 'столб', 1709091877);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 971.496796, -1843.141936, 'здание', 1758149884);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 2947.77865, -3121.374128, 'здание', 1729686059);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 3083.437564, 998.944771, 'ручка', 1763536811);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 184.920202, 1482.173779, 'книга', 1712002699);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', 1203.596709, -2888.85552, 'машина', 1747642777);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -2994.792582, -2425.616421, 'ручка', 1722832333);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 2509.4127, -3310.419547, 'кирпич', 1734356190);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -1856.867803, -1814.48173, 'телефон', 1721892855);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 162.082687, -3261.268054, 'банк', 1763680606);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 2802.306061, 705.531719, 'книга', 1728647145);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', 1610.352274, -377.615388, 'здание', 1781182477);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', -2586.232114, 70.622978, 'телефон', 1784981258);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -1962.891908, 7777.066093, 'машина', 1723078651);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 35353.957333, 1768.372919, 'камень', 1739321520);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -91.276843, 1072.671173, 'компьютер', 1763852990);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', 852.67069, -2594.547027, 'вайлдбериз', 1713966407);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -3388.802239, 2124.55232, 'машина', 1719795994);
insert into objects (name, coord1, coord2, type, creationTime) values ('Александр', 594.353207, 1548.231815, 'вайлдбериз', 1736655940);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 35353563.383829, 353535.897568, 'почтовый ящик', 1721156812);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 925.924501, -3055.304821, 'озон', 1762736839);
insert into objects (name, coord1, coord2, type, creationTime) values ('Zhenya', 445.662756, 1504.701374, 'столб', 1720029396);
insert into objects (name, coord1, coord2, type, creationTime) values ('Vasya', -1817.640018, 646.816326, 'вайлдбериз', 1786216338);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 49.627221, -1746.306341, 'книга', 1774900231);
insert into objects (name, coord1, coord2, type, creationTime) values ('!ewee', -390.338379, 2463.554481, 'банк', 1743914991);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2630.323627, -2979.828141, 'компьютер', 1737966440);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', 2815.691121, -1312.541865, 'банк', 1760761591);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 355535.751391, 53535353.233089, 'камень', 1716068913);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 548.659578, -456.282176, 'камень', 1762063180);
insert into objects (name, coord1, coord2, type, creationTime) values ('Evgenii', -693.715792, 777.165148, 'компьютер', 1724968953);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', 3185.829302, -2719.825438, 'здание', 1770313067);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -3144.350117, 549.408443, 'ручка', 1719668943);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', -2360.68298, -2939.056633, 'почтовый ящик', 1774679560);
insert into objects (name, coord1, coord2, type, creationTime) values ('Екатерина', 1950.804485, 3369.669869, 'телефон', 1780714970);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 1896.892538, -2788.028698, 'машина', 1750267919);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -31.472896, 3099.698757, 'здание', 1743307324);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', 1529.429201, -1154.331411, 'столб', 1757910345);
insert into objects (name, coord1, coord2, type, creationTime) values ('xXxLehaxXx', 3398.458023, -2506.50953, 'банк', 1786950828);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 2415.522771, 1727.673535, 'телефон', 1734252470);
insert into objects (name, coord1, coord2, type, creationTime) values ('2121212', -819.256899, 653.412001, 'машина', 1785364107);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', -2546.012592, -640.223238, 'кирпич', 1741927411);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', 3280.361622, 2694.417111, 'банк', 1777201993);
insert into objects (name, coord1, coord2, type, creationTime) values ('Иван', -2146.344892, 1641.663945, 'столб', 1733026274);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 1148.126716, 497.081749, 'ручка', 1784613657);
insert into objects (name, coord1, coord2, type, creationTime) values ('Мария', 1027.416704, -2909.659059, 'камень', 1757880254);
insert into objects (name, coord1, coord2, type, creationTime) values ('Павел', 2867.2872, 688.022611, 'здание', 1785907741);
insert into objects (name, coord1, coord2, type, creationTime) values ('Btooo', -1920.099943, 1349.919775, 'компьютер', 1715688857);
insert into objects (name, coord1, coord2, type, creationTime) values ('13Димон37', -3063.139628, 1904.553535, 'дом', 1758181236);
