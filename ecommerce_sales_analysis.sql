-- Prepare dataset 
    -- 🔄 Combine Data from All Three Months
        SELECT * INTO combined_data
        FROM (
            SELECT * FROM Ecommerce_oct
            UNION ALL
            SELECT * FROM Ecommerce_nov
            UNION ALL
            SELECT * FROM Ecommerce_dec
        ) AS all_data;

    -- Change data type of 'event_time'
        ALTER TABLE combined_data
        ADD event_time_dt DATETIME;

        UPDATE combined_data
        SET event_time_dt = CAST(LEFT(event_time, 19) AS DATETIME)

SELECT * FROM combined_data

-- 1. TOP SELLING

    -- 1.1. Top Sellings over 3 months
        -- 🥇 Top 10 Products by Revenue and Units Sold
            SELECT TOP 10
                product_id,
                SUM(price) AS revenue,
                COUNT(*) AS units_sold
            FROM combined_data
            WHERE event_type = 'purchase'
            GROUP BY product_id
            ORDER BY revenue DESC

        -- 🏷️ Top 10 Categories by Revenue and Units Sold
            SELECT TOP 10
                category_code,
                SUM(price) AS revenue,
                COUNT(*) AS units_sold
            FROM combined_data
            WHERE event_type = 'purchase'
            GROUP BY category_code
            ORDER BY revenue DESC

        -- 🧢 Top 10 Brands by Revenue and Units Sold
            SELECT TOP 10
                brand,
                SUM(price) AS revenue,
                COUNT(*) AS units_sold
            FROM combined_data
            WHERE event_type = 'purchase'
            GROUP BY brand
            ORDER BY revenue DESC
   
    -- 1.2. Top Selling by Month
        -- 🧩 Top 3 Products of each Month
            WITH product_rank AS(
                SELECT
                    DATENAME(MONTH, event_time_dt) AS month,
                    product_id,
                    SUM(price) AS revenue,
                    COUNT(*) AS units_sold,
                    ROW_NUMBER() OVER (
                        PARTITION BY DATENAME(month, event_time_dt)
                        ORDER BY SUM(price) DESC
                    ) AS rank
                FROM combined_data
                WHERE event_type = 'purchase'
                GROUP BY 
                    DATENAME(MONTH, event_time_dt),
                    product_id
            )
            SELECT
                month,
                product_id,
                revenue,
                units_sold
            FROM product_rank
            WHERE rank <= 3
            ORDER BY month, rank

        -- 🏷️ Top 3 Categories of each Month
            WITH category_rank AS(
                SELECT
                    DATENAME(MONTH, event_time_dt) AS month,
                    category_code,
                    SUM(price) AS revenue,
                    COUNT(*) AS units_sold,
                    ROW_NUMBER() OVER (
                        PARTITION BY DATENAME(month, event_time_dt)
                        ORDER BY SUM(price) DESC
                    ) AS rank
                FROM combined_data
                WHERE event_type = 'purchase'
                GROUP BY 
                    DATENAME(MONTH, event_time_dt),
                    category_code
            )
            SELECT
                month,
                category_code,
                revenue,
                units_sold
            FROM category_rank
            WHERE rank <= 3
            ORDER BY month, rank

        -- 🧢 Top 3 Brands of each Month
            WITH brand_rank AS(
                SELECT
                    DATENAME(MONTH, event_time_dt) AS month,
                    brand,
                    SUM(price) AS revenue,
                    COUNT(*) AS units_sold,
                    ROW_NUMBER() OVER (
                        PARTITION BY DATENAME(month, event_time_dt)
                        ORDER BY SUM(price) DESC
                    ) AS rank
                FROM combined_data
                WHERE event_type = 'purchase'
                GROUP BY 
                    DATENAME(MONTH, event_time_dt),
                    brand
            )
            SELECT
                month,
                brand,
                revenue,
                units_sold
            FROM brand_rank
            WHERE rank <= 3
            ORDER BY month, rank


-- 2. CUSTOMER SEGMENTATION

    -- 2.1. Group Users
        WITH user_overview AS (
            SELECT
                user_id,
                COUNT(*) AS total_orders,
                SUM(price) AS total_spent,
                AVG(price) AS avg_value
            FROM combined_data
            WHERE event_type = 'purchase'
            GROUP BY user_id
        )
        SELECT
            u.user_id,
            u.total_orders,
            u.total_spent,
            u.avg_value,
            STUFF((
                SELECT DISTINCT ', ' + category_code
                FROM combined_data AS inner_data
                WHERE inner_data.user_id = u.user_id
                    AND inner_data.event_type = 'purchase'
                    AND inner_data.category_code IS NOT NULL
                FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS categories_purchased
        FROM user_overview u
        ORDER BY u.total_orders DESC
    -- 2.2. RFM Score
        WITH cleaned_purchase_data AS (
            SELECT
                user_id,
                event_time_dt,
                price
            FROM combined_data
            WHERE event_type = 'purchase'
        ), rfm_base AS (
            SELECT
                user_id,
                MAX(event_time_dt) AS last_purchase_day,
                COUNT(*) AS frequency,
                SUM(price) AS monetary
            FROM cleaned_purchase_data
            GROUP BY user_id
        )
        SELECT
            user_id,
            DATEDIFF(DAY, last_purchase_day, MAX(last_purchase_day) OVER()) AS recency,
            frequency,
            monetary
        FROM rfm_base
        ORDER BY recency ASC, frequency DESC, monetary DESC


-- 3. SESSION-BASED FUNNEL ANALYSIS

    -- 3.1. Trace Users Journey
        -- Behavior overview by user_session
            SELECT
                user_id,
                user_session,
                COUNT(*) AS total_events,
                MIN(event_time_dt) AS session_start,
                MAX(event_time_dt) AS session_end,
                DATEDIFF(SECOND, MIN(event_time_dt), MAX(event_time_dt)) AS 'duration (second)'
            FROM combined_data
            GROUP BY user_id, user_session
            ORDER BY total_events DESC
        -- Behaviors occur during each session
            SELECT
                user_id,
                user_session,
                event_type,
                COUNT(*) AS event_count
            FROM combined_data
            GROUP BY user_id, user_session, event_type
            ORDER BY user_id, event_count DESC
        -- Sessions with purchasing behavior
            SELECT
                user_id,
                user_session,
                COUNT(*) AS purchase_events
            FROM combined_data
            WHERE event_type = 'purchase'
            GROUP BY user_id, user_session
            ORDER BY purchase_events DESC
        -- Conversion Rate
            WITH sessions AS (
                SELECT DISTINCT
                    user_id,
                    user_session
                FROM combined_data
            ), session_with_purchase AS (
                SELECT
                    user_id,
                    user_session
                FROM combined_data
                WHERE event_type = 'purchase'
            )
            SELECT
                (SELECT COUNT(*) FROM sessions) AS total_sessions,
                (SELECT COUNT(*) FROM session_with_purchase) AS session_with_purchase,
                (SELECT COUNT(*) FROM session_with_purchase) * 100.00 / (SELECT COUNT(*) FROM sessions) AS 'CVR (%)'

    -- 3.2. Frequency of sessions ending in a purchase
        WITH session_last_event AS (
            SELECT
                user_id,
                user_session,
                event_type,
                event_time_dt,
                ROW_NUMBER() OVER(
                    PARTITION BY
                        user_id,
                        user_session
                    ORDER BY event_time_dt DESC
                ) AS rn
            FROM combined_data
        ), last_event AS (
            SELECT * FROM session_last_event WHERE rn = 1
        )
        SELECT
            COUNT(*) AS total_sessions,
            SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) AS total_purchasing_sessions,
            SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) * 100.00 / COUNT(*) AS CVR
        FROM last_event


-- 4. BRAND PERFORMANCE ANALYSIS

    -- 4.1. Compare brands
        SELECT
            brand,
            SUM(price) as revenue,
            COUNT(DISTINCT user_id) as buyer_count,
            AVG(price) AS average_price
        FROM combined_data
        WHERE event_type = 'purchase'
        GROUP BY brand
        ORDER BY revenue DESC

    -- 4.2. Dominant brand by revenue of product line
        WITH brand_rank AS(
            SELECT
                category_code,
                brand,
                SUM(price) as revenue,
                COUNT(DISTINCT user_id) as buyer_count,
                AVG(price) AS average_price,
                ROW_NUMBER() OVER(
                    PARTITION BY category_code
                    ORDER BY SUM(price) DESC
                ) AS rank
            FROM combined_data
            GROUP BY category_code, brand
        )
        SELECT * FROM brand_rank
        WHERE rank = 1
