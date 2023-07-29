/*

Cleaning data in SQL queries

*/

Select * 
FROM NashvilleHousing

/*

Standardize date format

*/

Select SaleDateConverted, CONVERT(date, SaleDate) 
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)
/*update didnt work on the column which exists 
So I created another column and converted it there
*/

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


/*

Populate Property Address data

*/

/*each property has a distinct parcelID. There are duplicate values in the 
parcelID so if there are two #12432 (id) one of them has a 
filled propertyaddress and other one is NULL we are gonna copy 
that filled info into that NULL*/
/*we have to join the table to itself for finding the duplicate parcelIDs and 
their corresponding properties using Self join*/


--checking if we have null values in property address which has an address in its twin ParcelID row
Select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress
From NashvilleHousing a 
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 
/*each row has a unique ID so even if the ParcelID is same the 
UniqueID will be different...we'll get one row twice if we don't specify 
that their uniqueID should be different*/
/*So if ParcelID of Row x = ParcelID of Row y but their unique ID is different 
we will then check if any of their property address field is Null and populate it with the 
addresss of the other row*/
Where a.PropertyAddress is null


--Populate the field if it is null
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a 
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ] 


/*

Breaking out Address into individual Columns (Address, City, State)

*/

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address2
From NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Update NashvilleHousing
SET PropertySplitCity =SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


--breakking down by ParseName

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerSplitState
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerSplitCity
,PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Select * 
From NashvilleHousing


/*

Change Y and N to Yes and No in "Sold as Vacant" field

*/

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

/*

Remove Duplicates 

*/

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
)
DELETE
FROM RowNumCTE
Where row_num > 1


/*

Drop unwanted column

*/

Select * 
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate