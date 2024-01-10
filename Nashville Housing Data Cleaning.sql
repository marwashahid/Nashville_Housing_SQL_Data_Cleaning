/* 

Cleaning Data in SQL

*/

SELECT * FROM NashvilleHousing;
-------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Data format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)




----------------------------------------------------------------------------------------------------------------------------------------------

-- Properly populate property address data

SELECT PropertyAddress
FROM NashvilleHousing
where PropertyAddress is NULL

SELECT *
FROM NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a                    -- Rows having same Parcel ID have the same property address
JOIN NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a                    -- Rows having same Parcel ID have the same property address
JOIN NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking down Address into Individual components (Address , City, State)

Select PropertyAddress FROM NashvilleHousing;


SELECT SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress,-1)) as Address , --comma is a delimeter only at one place in all rows
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing 
Add PropertySplitAddress nvarchar(255)



UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress,0, CHARINDEX(',',PropertyAddress,-1))


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT * FROM NashvilleHousing

Select OwnerAddress FROM NashvilleHousing

SELECT PARSENAME(OwnerAddress,1) FROM NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
      WHEN SoldAsVacant='N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
