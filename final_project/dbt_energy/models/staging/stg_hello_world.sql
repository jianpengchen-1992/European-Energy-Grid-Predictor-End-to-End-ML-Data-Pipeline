/* This is your Hello World model!
   Instead of hardcoding `project.dataset.table`, we use the dbt source macro.
*/

WITH raw_data AS (
    -- The source macro looks at your sources.yml file to find the right table
    SELECT * FROM {{ source('energy_domain', 'Markt_Großhandelspreise') }}
)

SELECT 
    *
FROM raw_data
LIMIT 100