WITH raw AS (
  SELECT
    to_timestamp((string_to_array(split_part(message, E'\n', 2), ','))[1]::int) AS time,
    to_char(published_at, 'YYYY-MM-DD HH24:MI:SSTZ') AS "Database Time",
    string_to_array(split_part(message, E'\n', 1), ',')  AS header,
    string_to_array(split_part(message, E'\n', 2), ',')  AS reading,
    generate_subscripts(string_to_array(split_part(message, E'\n', 1), ','), 1) AS i
    FROM public.raw_data
    WHERE node_id='e00fce681da839c091071295' AND published_at > '2023-10-10 00:00:00'
  )
  SELECT 
    time,
--    max(reading[1]) as "TIME",
    max(reading[4]) as "RED",
    max(reading[5]) as "GREEN",
    max(reading[6]) as "BLUE"
  FROM raw
  GROUP BY 1
  order by 1