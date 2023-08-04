-- Cleaning data in SQL queries

select * 
from PortfolioProject..NashvilleHousing

--Standardize Data Format
select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate)


--Populate Property Address data
select * 
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join  PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address,City,State)

select PropertyAddress
from PortfolioProject..NashvilleHousing


select 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress))-1) as Address,
SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress))+1, LEN(PropertyAddress))  as Address
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(225)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress))-1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(225)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, (CHARINDEX(',',PropertyAddress))+1, LEN(PropertyAddress))


select * from PortfolioProject..NashvilleHousing

select OwnerAddress from PortfolioProject..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(225)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(225)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(225)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * from PortfolioProject..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case 
  when  SoldAsVacant = 'Y' then 'Yes'
  when  SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case 
  when  SoldAsVacant = 'Y' then 'Yes'
  when  SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end
from PortfolioProject..NashvilleHousing


--Remove Dublicates

select * from PortfolioProject..NashvilleHousing


with rownumCTE as(
select *, 
   ROW_NUMBER() over (
   partition by parcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by
			  uniqueID)row_num 
from PortfolioProject..NashvilleHousing)

delete  from rownumCTE
where row_num>1
--order by PropertyAddress


--Delete Unused Columns


select * from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject..NashvilleHousing
drop column SaleDate