WITH rn_table AS (
  SELECT 
    *, 
    ROW_NUMBER() OVER (PARTITION BY crime_id ORDER BY report_date DESC) AS rn
  FROM {{ ref("raw__crashes") }}
)

SELECT 
  {{ dbt_utils.generate_surrogate_key(['event_id', 'crime_id']) }} AS crash_id, 
  crime_id, 
  report_date,
  from_date,
-- vehicles involved 
  total_vehicles, 
  total_bicycles, 
  total_pedestrians,
  total_taxis, 
  total_government,
-- injuries 
  major_injuries__bicyclist AS major_injuries__cyclist,
  minor_injuries__bicyclist AS minor_injuries__cyclist,
  unknown_injuries__bicyclist AS unknown_injuries__cyclist,
  fatal__bicyclist AS fatal__cyclist,
  major_injuries__driver,
  minor_injuries__driver,
  unknown_injuries__driver,
  fatal__driver,
  major_injuries__pedestrian,
  minor_injuries__pedestrian,
  unknown_injuries__pedestrian,
  major_injuries__passenger,
  minor_injuries__passenger,
  unknown_injuries__passenger,
  fatal__passenger,
-- crash details 
  pedestrians_impaired, 
  bicyclists_impaired AS cyclists_impaired, 
  drivers_impaired,
  speeding_involved,
-- geography
  address AS geo__address, 
  ward AS geo__ward,
  street_seg_id AS geo__street_seg_id, 
  roadway_seg_id AS geo__roadway_seg_id,
  latitude AS geo__latitude, 
  longitude AS geo__longitude, 
  x_coord AS geo__x_coord, 
  y_coord AS geo__y_coord,
  nearest_int_route_id AS geo__nearest_int_route_id, 
  nearest_int_street_name AS geo__nearest_int_street_name, 
  off_intersection AS geo__off_intersection
FROM rn_table
WHERE EXTRACT(YEAR FROM report_date) <= EXTRACT(YEAR FROM CURRENT_DATE)
  AND rn = 1