SELECT*
FROM Project#3..NashvilleHousing

-- Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Project#3..NashvilleHousing

ALTER TABLE Project#3..NashvilleHousing
ADD SaleDateConverted Date;
UPDATE Project#3..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM Project#3..NashvilleHousing 

----
-- Modify Property Adress Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project#3..NashvilleHousing a
JOIN Project#3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project#3..NashvilleHousing a
JOIN Project#3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project#3..NashvilleHousing a
JOIN Project#3..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]



----
-- Dividing adresses into individual Columns like Adress, City and State

SELECT PropertyAddress
FROM Project#3..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM Project#3..NashvilleHousing

ALTER TABLE Project#3..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE Project#3..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE Project#3..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE Project#3..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

----

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Project#3..NashvilleHousing


ALTER TABLE Project#3..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Project#3..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE Project#3..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE Project#3..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE Project#3..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE Project#3..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



----
-- Changing the 'Y' and 'N's under Sold as Vacant column to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project#3..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Project#3..NashvilleHousing

UPDATE Project#3..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END



----
--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
) row_num
FROM Project#3..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1


----
--Deleteing Unused Columns, that we've splitted before

SELECT *
FROM Project#3..NashvilleHousing

ALTER TABLE Project#3..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE Project#3..NashvilleHousing
DROP COLUMN SaleDate



--Could have delete the other columns that contain ''nulls'', by using DELETE and IS NULL functions for much clearance

