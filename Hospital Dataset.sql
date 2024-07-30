--Table Overview
SELECT *
FROM HospitalDatasetProject..healthcare_dataset;

--HOSPITAL OVERVIEW
-- How many patients are in the dataset?
-- What is the total number of people admitted?
-- How many different hospitals are represented?
-- How many Doctors are there?
SELECT COUNT(DISTINCT [Patient Names]) AS TotalPatients,
	   COUNT(*) AS TotalAdmission,
	   COUNT(DISTINCT Hospital) AS NumberOfHospitals,
	   COUNT(DISTINCT Doctor) AS NumberOfDoctors
FROM HospitalDatasetProject..healthcare_dataset;


-- PATIENT DEMOGRAPHICS AND STATISTICS
-- What is the age distribution of patients?
SELECT Age, COUNT(*) AS NumberOfPatients
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY Age
ORDER BY 2 DESC;

-- What is the gender ratio?
WITH CountGender AS (
    SELECT Gender, COUNT(*) AS GenderCount
    FROM HospitalDatasetProject..healthcare_dataset
    GROUP BY Gender
)
SELECT
    (SELECT GenderCount FROM CountGender WHERE Gender = 'Male') AS MaleCount,
    (SELECT GenderCount FROM CountGender WHERE Gender = 'Female') AS FemaleCount,
    CAST((SELECT GenderCount FROM CountGender WHERE Gender = 'Male') AS FLOAT) / 
        (SELECT GenderCount FROM CountGender WHERE Gender = 'Female') AS GenderRatio;

--What is the distribution of blood types within the patient dataset?
SELECT [Blood Type], 
	   COUNT(*) AS BloodTypeCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Blood Type]
ORDER BY 2 DESC;

--What is the distribution of admission types (urgent, emergency, elective) within the patient dataset?
SELECT [Admission Type], 
	   COUNT(*) AS AdmissionCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Admission Type]
ORDER BY 2 DESC;

--What is the distribution of admission times across different days of the week?
SELECT 
    DATENAME(weekday, [Date of Admission]) AS DayOfWeek,
    COUNT(*) AS NumberOfPatientAdmitted
FROM HospitalDatasetProject..healthcare_dataset
WHERE [Date of Admission] IS NOT NULL
GROUP BY DATENAME(weekday, [Date of Admission])
ORDER BY 
    CASE DATENAME(weekday, [Date of Admission])
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

--HOSPITAL PERFORMANCE
-- Which hospital has the highest number of admissions?
SELECT Hospital AS Hospital_Name, 
	   COUNT(*) AS TotalAdmitted
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY Hospital
ORDER BY 2 DESC;

-- What is the average billing amount per patient for each hospital?
SELECT Hospital AS Hospital_Name, 
	   AVG([Billing Amount]) AS AverageBillingAmount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY Hospital
ORDER BY 2 DESC;

--Which doctor has the highest number of patients attended to?
SELECT Doctor, 
	   COUNT(*) AS PatientCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY Doctor
ORDER BY 2 DESC;

--DISEASE ANALYSIS
-- What are the most common medical conditions?
SELECT [Medical Condition], 
	   COUNT(*) AS ConditionCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Medical Condition]
ORDER BY 2 DESC;

-- Average length of stay for patients with specific medical conditions
SELECT [Medical Condition],
       AVG(DATEDIFF(day, [Date of Admission], [Discharge Date])) AS AverageLengthOfStay
FROM HospitalDatasetProject..healthcare_dataset
WHERE [Discharge Date] IS NOT NULL
GROUP BY [Medical Condition];

-- Most common medical conditions among different age groups
SELECT Age,
       [Medical Condition],
       COUNT(*) AS ConditionCount
FROM (
    SELECT CASE 
               WHEN Age < 18 THEN '0-17'
               WHEN Age BETWEEN 18 AND 35 THEN '18-35'
               WHEN Age BETWEEN 36 AND 50 THEN '36-50'
               WHEN Age BETWEEN 51 AND 65 THEN '51-65'
               ELSE '66+'
           END AS Age, 
		   [Medical Condition]
    FROM HospitalDatasetProject..healthcare_dataset
) AS AgeConditionData
GROUP BY Age, [Medical Condition]
ORDER BY 3 DESC;

--Which medications are frequently prescribed for certain medical conditions?
SELECT [Medical Condition], Medication, COUNT(*) PrescriptionCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Medical Condition], Medication
ORDER BY 1, 3 DESC;

--How does the distribution of Test results (normal, inconclusive, abnormal) vary across different medical conditions?
SELECT [Medical Condition],
	   [Test Results],
	   COUNT(*) AS ResultCount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Medical Condition], [Test Results]
ORDER BY 1, 3 DESC;


---FINANCIAL ANALYSIS
-- What is the total revenue generated by various hospitals?
SELECT Hospital AS Hospital_Name, 
	   SUM([Billing Amount]) AS TotalRevenueGenerated
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY Hospital
ORDER BY 2 DESC;

-- Identify the top 5 most expensive medical conditions based on billing amount.
SELECT TOP 5 [Medical Condition], 
             SUM([Billing Amount]) AS TotalBillingAmount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Medical Condition]
ORDER BY 2 DESC;

--What is the average billing amount for different insurance providers?
SELECT [Insurance Provider], 
	   AVG([Billing Amount]) AS AverageBillingAmount
FROM HospitalDatasetProject..healthcare_dataset
GROUP BY [Insurance Provider] 
ORDER BY 2 DESC; 

-- Analyze the correlation between average length of stay and total billing amount.
SELECT [Patient Names],
	   DATEDIFF(day, [Date of Admission], [Discharge Date]) AS LengthOfStay,
	   [Billing Amount]
FROM HospitalDatasetProject..healthcare_dataset
WHERE [Discharge Date] IS NOT NULL
ORDER BY 2 DESC;

-- Calculate the average billing amount for different admission types and compare across various hospitals
SELECT 
    Hospital,
    [Admission Type],
    AVG([Billing Amount]) AS AvgBillingAmount
FROM HospitalDatasetProject.dbo.healthcare_dataset
GROUP BY Hospital, [Admission Type]
ORDER BY 1, 2;

-- Analyze the average billing amount for different medications prescribed by various Doctors
SELECT 
    Doctor,
    Medication,
    AVG([Billing Amount]) AS AvgBillingAmount
FROM HospitalDatasetProject.dbo.healthcare_dataset
GROUP BY Doctor, Medication
ORDER BY 2, 1 ASC;

-- Calculate average length of stay and billing amount for patients with different Test results
SELECT 
    [Test Results],
    AVG(DATEDIFF(day, [Date of Admission], [Discharge Date])) AS AvgLengthOfStay,
    AVG([Billing Amount]) AS AvgBillingAmount
FROM HospitalDatasetProject.dbo.healthcare_dataset
WHERE [Discharge Date] IS NOT NULL
GROUP BY [Test Results]
ORDER BY 3 DESC;

-- Analyze the billing amount variation across insurance providers and medical conditions
SELECT 
    [Insurance Provider],
    [Medical Condition],
    AVG([Billing Amount]) AS AvgBillingAmount
FROM HospitalDatasetProject.dbo.healthcare_dataset
GROUP BY [Insurance Provider], [Medical Condition]
ORDER BY 1, 2;

-- Calculate the average time between admission and discharge date and its effect on billing amounts by room numbers
SELECT 
    [Room Number],
    AVG(DATEDIFF(day, [Date of Admission], [Discharge Date])) AS AvgLengthOfStay,
    AVG([Billing Amount]) AS AvgBillingAmount
FROM HospitalDatasetProject.dbo.healthcare_dataset
WHERE [Discharge Date] IS NOT NULL
GROUP BY [Room Number]
ORDER BY 2 DESC;


