

--Grab the beginning TimeStamp and max EmpoyeeID for each observation
--Optionally we may choose to ignore an Observation if the result is a FAILURE
SELECT MIN(src.ObsTimestamp)[TimeStamp], MAX(src.ItemName)[EmployeeID], src.ObsID, MIN(src.Result)[Result]
FROM (SELECT frd.ObsTimestamp, dta.ItemName, frd.ObsID, frd.Value,
			CASE 
				WHEN(frd.Value > fpr.UpperToleranceLimit OR frd.Value < fpr.LowerToleranceLimit) THEN 'Fail'
				ELSE 'Pass'
			END AS 'Result'
		FROM MeasurLink7.dbo.FeatureRun fr 
		INNER JOIN MeasurLink7.dbo.Feature f ON F.FeatureID = fr.FeatureID 
		INNER JOIN MeasurLink7.dbo.Run r ON fr.RunID = r.RunID 
		INNER JOIN MeasurLink7.dbo.Routine rt ON rt.RoutineID = r.RoutineID 
		INNER JOIN MeasurLink7.dbo.FeatureRunData frd ON fr.RunID = frd.RunID AND fr.FeatureID=frd.FeatureID
		LEFT OUTER JOIN MeasurLink7.dbo.FeatureProperties fpr ON f.FeatureID = fpr.FeatureID AND f.FeaturePropID = fpr.FeaturePropID 
		LEFT OUTER JOIN MeasurLink7.dbo.DataTraceability dta ON r.RunID = dta.RunID AND f.FeatureID = dta.FeatureID AND frd.ObsID = dta.StartObsID 
		WHERE r.RunName = ? AND rt.RoutineName = ?
		UNION ALL
		SELECT  afrd.ObsTimestamp, dta.ItemName, afrd.ObsID, afrd.DefectCount,
			CASE
				WHEN afrd.DefectCount = 1 THEN 'Fail'
				ELSE 'Pass'
			END AS 'Result'
		FROM MeasurLink7.dbo.FeatureRun fr 
		INNER JOIN MeasurLink7.dbo.Feature f ON F.FeatureID = fr.FeatureID 
		INNER JOIN MeasurLink7.dbo.Run r ON fr.RunID = r.RunID 
		INNER JOIN MeasurLink7.dbo.Routine rt ON rt.RoutineID = r.RoutineID 
		INNER JOIN MeasurLink7.dbo.AttFeatureRunData afrd ON fr.RunID = afrd.RunID AND fr.FeatureID = afrd.FeatureID
		LEFT OUTER JOIN MeasurLink7.dbo.DataTraceability dta ON r.RunID = dta.RunID AND f.FeatureID = dta.FeatureID AND afrd.ObsID = dta.StartObsID 
		WHERE r.RunName = ? AND rt.RoutineName = ?) src
GROUP BY src.ObsID
ORDER BY src.ObsID