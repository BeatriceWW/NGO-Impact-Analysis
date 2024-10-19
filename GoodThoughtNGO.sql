-- Q1-- highest_donation_assignments

WITH DonationSummary AS (
    SELECT s.assignment_name, 
           s.region, 
           ROUND(SUM(d.amount), 2) AS rounded_total_donation_amount, 
           dn.donor_type
    FROM assignments AS s
    INNER JOIN donations AS d
        ON s.assignment_id = d.assignment_id
    INNER JOIN donors AS dn
        ON d.donor_id = dn.donor_id
    GROUP BY s.assignment_name, s.region, dn.donor_type
)
SELECT *
FROM DonationSummary
ORDER BY rounded_total_donation_amount DESC
LIMIT 5;


-- top_regional_impact_assignments

WITH donations_counts AS (
    SELECT assignment_id, 
           COUNT(donation_id) AS num_total_donations 
    FROM donations 
    GROUP BY assignment_id
), 
ranked_assignments AS (
    SELECT s.assignment_name,
           s.region,
           s.impact_score,
           d.num_total_donations,
           ROW_NUMBER() OVER(PARTITION BY s.region ORDER BY s.impact_score DESC) AS rank_in_region 
    FROM assignments AS s
    JOIN donations_counts d ON s.assignment_id = d.assignment_id
    WHERE d.num_total_donations > 0
)
SELECT assignment_name, region, impact_score, num_total_donations
FROM ranked_assignments
WHERE rank_in_region = 1
ORDER BY region ASC;
