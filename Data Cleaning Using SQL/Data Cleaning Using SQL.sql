/*

Project: Data Cleaning Using SQL Queries

*/


--------------------------------------------------------------------------------------------------------------------------

--Query To Explore The Dataset
Select *
From [Portfolio Project]..NashvilleHousing


--Query To Convert The Sales Date Column To Date Format
Select 
SaleDate,
Convert(Date,SaleDate)
From [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)
--To update the table with the converted date column


Select 
SaleDateConverted 
From [Portfolio Project]..NashvilleHousing
--To confirm update was successful

--------------------------------------------------------------------------------------------------------------------------


--Query To Populate Property Address Data
Select *
From [Portfolio Project]..NashvilleHousing
Where PropertyAddress is Null
--To see how many columns have Null fields in the PropertyAddress column
--Running again after updating the table in the queries below confirms there are no longer null values 


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--ISNULL checks if a.PropertyAddress is a null value. If so, it populated it with b.PropertyAddress
From [Portfolio Project]..NashvilleHousing as a
Join [Portfolio Project]..NashvilleHousing as b
on a.ParcelID = b.ParcelID And
a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null
--We want to join the table to itself to populate the PropertyAddress column's NULL values with correct addresses
--This is achieved when the propterty has been sold multiple times, and the address is populated under another UniqueID

Update a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project]..NashvilleHousing as a
Join [Portfolio Project]..NashvilleHousing as b
on a.ParcelID = b.ParcelID And
a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------


--Query To Break Up The Address Into Individual Columns (Address, City, State)
Select PropertyAddress
From [Portfolio Project]..NashvilleHousing
--Confirmed the only delimiter in this column is a comma

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
--This returns a portion of a string value, starting at position 1, and ending at the comma 
--(the -1 eliminated the comma from the results)
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) as City
From [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing 
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))

--------------------------------------------------------------------------------------------------------------------------


--Query To Break Up The OwnerAddress Column Using the PARSENAME Method
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--PARSENAME only works with periods as a delimiter. 3, 2, 1 represents the segment from the original string retrieved. 
From [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing 
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing 
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------


--Query Change "Y" and "N" to "Yes" and "No" In The "SoldAsVacant" Field
Select
Distinct(SoldAsVacant), 
COUNT (SoldAsVacant)
From [Portfolio Project]..NashvilleHousing
Group by SoldAsVacant
Order by 2
--To confirm there are only two initial existing values


Select
SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--------------------------------------------------------------------------------------------------------------------------


-- Query To Remove Duplicates (To Demonstrate Only) Using a CTE

WITH RowNumCTE AS
(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				PropertyAddress, 
				SaleDate, 
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From [Portfolio Project]..NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1
--Used a CTE because results in the row_num column cannot be filtered with the WHERE statement
--This function assumes that the ParcelID, PropertyAddress, SaleDate, and LegalReference should all be unique.
--If not, a row is assumed to be a duplicate.

--------------------------------------------------------------------------------------------------------------------------


--Query To Remove Unused Columns (To Demonstrate Only). Use Case Is For Deleting Data From Views, Not Company Source Data
Select *
From [Portfolio Project]..NashvilleHousing

ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


