--Nashville Housing Data: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data
USE [Covid Project]
SELECT *
FROM [dbo].[NashvilleHousing]

--Format Date as YYYY-MM-DD
ALTER TABLE NashvilleHousing
ADD FormatSaleDate Date

UPDATE NashvilleHousing
SET FormatSaleDate = CONVERT(Date, SaleDate)

--Populate Property Address Data
UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [dbo].[NashvilleHousing] a
JOIN [dbo].[NashvilleHousing] b
ON a.ParcelID = b.ParcelID 
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Split Property Address into Multiple Columns (Address, City, State)
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Split Owner Address into Multiple Columns (Address, City, State)
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Change Y/N to Yes/No in "Sold as Vacant" column
UPDATE NashvilleHousing
SET SoldAsVacant = 'Yes'
WHERE SoldAsVacant = 'Y'

UPDATE NashvilleHousing
SET SoldAsVacant = 'No'
WHERE SoldAsVacant = 'N'

--Delete Duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY 
ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID) row_num
FROM [dbo].[NashvilleHousing])

DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns
ALTER TABLE [dbo].[NashvilleHousing]
DROP COLUMN SaleDate









