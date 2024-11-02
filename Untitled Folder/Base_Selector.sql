SELECT
  to_timestamp((message::json->'Data'->>'Time')::int) as "time",
  ((elems1->'Talon-Aux'->'PORT_1'->1)::float)*100.0 as "PAR" --convert to par based on SQ-500 sensor
FROM public.raw_data, jsonb_array_elements((message::jsonb)->'Data'->'Devices') elems1
where
	node_id = 'e00fce68a65d0fedcacb90b2' AND event = 'data/v2' and published_at > '2023-10-12 00:00:00' and published_at < '2023-11-28 00:00:00' and elems1 ? 'Talon-Aux'
	ORDER BY 1