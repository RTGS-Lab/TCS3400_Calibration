
SELECT
  to_timestamp((message::json->'Data'->>'Time')::int) as "time",
  -- dateadd(S, , '1970-01-01') AS "time",
  -- message AS metric,
  -- node_id,
  -- ARRAY(SELECT json_object_keys(message::json)) AS keys,
  -- (message::json->'Diagnostic'->>'Time')::int AS val2,
  -- (message::json->'Diagnostic'->'Devices'->'Kestrel'->'ACCEL'->>2)::float AS Accel_Z,
  (elems1->'Talon-Aux'->'PORT_1'->>0)::float as "Volt"
FROM public.raw_data, jsonb_array_elements((message::jsonb)->'Data'->'Devices') elems1
WHERE
  node_id = 'e00fce68a65d0fedcacb90b2' AND event = 'data/v2' AND elems1 ? 'Talon-Aux' and published_at > '2023-10-10 00:00:00'
ORDER BY 1