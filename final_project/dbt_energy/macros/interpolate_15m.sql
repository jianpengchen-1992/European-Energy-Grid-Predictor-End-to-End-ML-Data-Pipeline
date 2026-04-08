-- macros/interpolate_15m.sql

{% macro interpolate_linear(column_name, timestamp_col) %}
    h.{{ column_name }} + ((COALESCE(h.next_{{ column_name }}, h.{{ column_name }}) - h.{{ column_name }}) * (EXTRACT(MINUTE FROM {{ timestamp_col }}) / 60.0))
{% endmacro %}