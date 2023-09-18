{{ config(
    materialized='incremental',
    on_schema_change='fail'
    )
}}

WITH raw_reviews AS (
    SELECT * FROM {{ ref('raw_reviews') }}
)

SELECT * EXCLUDE rn FROM(
SELECT
    *, ROW_NUMBER() OVER(PARTITION BY review_id ORDER BY review_date DESC) as rn
FROM
    raw_reviews

WHERE
    review_text is not null
{% if is_incremental() %}
 AND review_date > (SELECT MAX(review_date) FROM {{ this }})
{% endif %}
) WHERE rn = 1