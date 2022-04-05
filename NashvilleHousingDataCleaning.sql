/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
Select saleDate,CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousingData

Update PortfolioProject.dbo.NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate) 

-- Other method to Update

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)


Select saleDateConverted 
From PortfolioProject.dbo.NashvilleHousingData

 --------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousingData
order by ParcelID

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData
where PropertyAddress is null

--Selfjion PropertyAdderss On ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingdata a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Update PropertyAddress

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousingData a
JOIN PortfolioProject.dbo.NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

--Split Address and City from PropertyAddress BY SUBSTIRING Method
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousingData

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update  PortfolioProject.dbo.NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousingData

--Split Address,City,State from OwnerAddress By PARSENAME Method

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousingData

Select PARSENAME(OwnerAddress,1)
From PortfolioProject.dbo.NashvilleHousingData

-- PARSENAME Split on '.' so Replace ',' by '.'
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--------------------------------------------------------------------------------------------------------------------------
--Checking 'SoldAsVacant' field 

Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousingData
Group by SoldAsVacant
order by 2

-- Change Y and N to Yes and No in "SoldAsVacant" field using CASE Statement

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousingData

Update PortfolioProject.dbo.NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	                    When SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END
-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates using Window function and CTE

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousingData
--Where row_num > 1
--Order by PropertyAddress

--Create CTE RowNumCTE And Delet Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousingData
)
DELETE
From RowNumCTE
Where row_num > 1


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleHousingData
)
select *
From RowNumCTE
Where row_num > 1

Select *
From PortfolioProject.dbo.NashvilleHousingData


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousingData

ALTER TABLE PortfolioProject.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate













