/*
	DATA CLEANING USING SQL
*/

--------------------------------------------------------------------------------------------------------------------------

SELECT SaleDate
FROM PortfolioProject..Housing

--------------------------------------------------------------------------------------------------------------------------
/*
	Standarizing Data Format 
*/
SELECT SaleDate, CONVERT(date,SaleDate) As UpdatedDate
FROM PortfolioProject..Housing

ALTER TABLE Housing 
ADD SaleDateConverted Date;

UPDATE Housing 
SET SaleDateConverted = CONVERT(date,SaleDate) 

ALTER TABLE Housing 
DROP COLUMN SaleDate;

--------------------------------------------------------------------------------------------------------------------------
/*
	Populate Property Adress data
*/

SELECT *
FROM  PortfolioProject..Housing
ORDER BY ParcelID

SELECT h1.ParcelID,h1.PropertyAddress, h2.ParcelID , h2.PropertyAddress, ISNULL(h1.PropertyAddress,h2.PropertyAddress)
FROM  PortfolioProject..Housing h1 
JOIN PortfolioProject..Housing h2
ON h1.ParcelID = h2.ParcelID
AND h1.[UniqueID ] <> h2.[UniqueID ]
WHERE h1.PropertyAddress is NULL

/*
	Updating the NULL values for the PropertyAddress
*/

UPDATE h1
Set PropertyAddress =  ISNULL(h1.PropertyAddress,h2.PropertyAddress)
FROM  PortfolioProject..Housing h1 
JOIN PortfolioProject..Housing h2
ON h1.ParcelID = h2.ParcelID
AND h1.[UniqueID ] <> h2.[UniqueID ]
WHERE h1.PropertyAddress is NULL
--------------------------------------------------------------------------------------------------------------------------

/*
	Breaking out the Adress into Columns (Adress, City, State)
*/

SELECT PropertyAddress
FROM  PortfolioProject..Housing

SELECT 
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) AS Adress,
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM PortfolioProject..Housing
ORDER BY City

ALTER TABLE Housing
add PropertyCity Nvarchar(255);

UPDATE Housing
SET PropertyCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


ALTER TABLE Housing
add Property_Adress Nvarchar(255);

UPDATE Housing
SET Property_Adress = SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)

--------------------------------------------------------------------------------------------------------------------------
/*
	Working On Owner Address
*/
SELECT OwnerAddress
FROM PortfolioProject..Housing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),1),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
FROM PortfolioProject..Housing

--Owner Address
ALTER TABLE Housing
add Owner_Address Nvarchar(255);

UPDATE Housing
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--Owner City
ALTER TABLE Housing
add Owner_City Nvarchar(255);

UPDATE Housing
SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--Owner State
ALTER TABLE Housing
add Owner_State Nvarchar(255);

UPDATE Housing
SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


/*
	Checking the updated values
*/
SELECT Owner_Address,Owner_City,Owner_State
FROM Housing

--------------------------------------------------------------------------------------------------------------------------
/*
	Change Y and N to Yes and No is 'SoldAsVacant' Column -> Unifying the values  
*/

SELECT Distinct(SoldAsVacant) , COUNT(SoldAsVacant)
FROM Housing
GROUP by SoldAsVacant
order by  COUNT(SoldAsVacant)

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Housing

UPDATE Housing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

--------------------------------------------------------------------------------------------------------------------------
/*
	Romoving Duplicates
*/
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDateConverted,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
				   )row_num
FROM PortfolioProject..Housing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


--------------------------------------------------------------------------------------------------------------------------
/*
	Deleting unsused Columns
*/

SELECT * 
FROM Housing 

ALTER TABLE Housing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

/*
Link to dataset : https://github.com/MohamedAliBahri/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
*/