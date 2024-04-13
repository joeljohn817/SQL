/*

Cleaning Data in SQL Queries

*/



Select *
From NashvilleHousing

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
from NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select*
From NashvilleHousing


Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(Replace(OwnerAddress,',','.'), 3),
PARSENAME(Replace(OwnerAddress,',','.'), 2),
PARSENAME(Replace(OwnerAddress,',','.'), 1)
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

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant
Order by 2

Select SoldASVacant,
	Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing


Update NashvilleHousing
	Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant
		End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference Order By UniqueID) row_num
from NashvilleHousing
)
--Order By ParcelID
Delete
From RowNumCTE
Where row_num > 1


-- Check for duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference Order By UniqueID) row_num
from NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
from NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate