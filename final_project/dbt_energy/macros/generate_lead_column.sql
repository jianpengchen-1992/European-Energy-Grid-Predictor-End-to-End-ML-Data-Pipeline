-- macros/generate_lead_columns.sql

{% macro generate_lead_columns(column_list, partition_col, order_col) %}
    
    {% for col in column_list %}
        , {{ col }}
        , LEAD({{ col }}) OVER (PARTITION BY {{ partition_col }} ORDER BY {{ order_col }}) AS next_{{ col }}
    {% endfor %}

{% endmacro %}