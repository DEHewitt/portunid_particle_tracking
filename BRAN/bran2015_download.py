# To download BRAN files subset to Australia surface only currents
# based upon ncdf subsetting at this site:  http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2016/OFAM/ocean_u_1994_01.nc/dataset.html

# with wget
import wget

# Example
#url = 'http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2016/OFAM/ocean_v_1995_01.nc?var=v&north=0&west=100&east=190&south=-50&horizStride=1&time_start=1995-01-01T12%3A00%3A00Z&time_end=1995-01-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5'
#wget.download(url, '/Users/hayde/Crab-Dispersal/BRAN/test_v_1995.nc')

# Create year list
years = list(range(2010, 2018))

# Create list of variables/files to download
products = ("u", "v", "temp", 'salt')

 # scratch folder 'srv/scratch/z3374139/BRAN_AUS/'

# For each month, loop through the products and years to make unique URLs,
# Subsetting is done within the URL
# Months are separate due to different number of days in each month which made the coding complicated, could be improved by including month in the loop and modifying dates from that.

# January
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_01.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-01-01T12%3A00%3A00Z&time_end="+str(year)+"-01-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_01.nc')

#  March
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_03.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-03-01T12%3A00%3A00Z&time_end="+str(year)+"-03-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_03.nc')

# April
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_04.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-04-01T12%3A00%3A00Z&time_end="+str(year)+"-04-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_04.nc')

# May
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_05.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-05-01T12%3A00%3A00Z&time_end="+str(year)+"-05-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_05.nc')

# June
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_06.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-06-01T12%3A00%3A00Z&time_end="+str(year)+"-06-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_06.nc')

# July
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_07.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-07-01T12%3A00%3A00Z&time_end="+str(year)+"-07-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_07.nc')

# August
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_08.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-08-01T12%3A00%3A00Z&time_end="+str(year)+"-08-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_08.nc')

# September
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_09.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-09-01T12%3A00%3A00Z&time_end="+str(year)+"-09-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_09.nc')

# October
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_10.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-10-01T12%3A00%3A00Z&time_end="+str(year)+"-10-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_10.nc')

# November
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_11.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-11-01T12%3A00%3A00Z&time_end="+str(year)+"-11-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_11.nc')

# December
for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_12.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-12-01T12%3A00%3A00Z&time_end="+str(year)+"-12-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_12.nc')
            
# change coding for 2009 as it starts in April
year = 2009

# April
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_04.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-04-01T12%3A00%3A00Z&time_end="+str(year)+"-04-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_04.nc')

# May
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_05.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-05-01T12%3A00%3A00Z&time_end="+str(year)+"-05-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_05.nc')

# June
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_06.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-06-01T12%3A00%3A00Z&time_end="+str(year)+"-06-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_06.nc')

# July
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_07.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-07-01T12%3A00%3A00Z&time_end="+str(year)+"-07-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_07.nc')

# August
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_08.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-08-01T12%3A00%3A00Z&time_end="+str(year)+"-08-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_08.nc')

# September
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_09.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-09-01T12%3A00%3A00Z&time_end="+str(year)+"-09-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_09.nc')

# October
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_10.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-10-01T12%3A00%3A00Z&time_end="+str(year)+"-10-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_10.nc')

# November
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_11.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-11-01T12%3A00%3A00Z&time_end="+str(year)+"-11-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_11.nc')

# December
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_12.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-12-01T12%3A00%3A00Z&time_end="+str(year)+"-12-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_12.nc')


# change for 2019 as only Jan-Mar
year = 2019

# January
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_01.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-01-01T12%3A00%3A00Z&time_end="+str(year)+"-01-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_01.nc')

#  March
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_03.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-03-01T12%3A00%3A00Z&time_end="+str(year)+"-03-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_03.nc')
            
# Hacky 2018 fix - not sure why it wouldn't work in the loop
year = 2018

# January
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_01.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-01-01T12%3A00%3A00Z&time_end="+str(year)+"-01-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_01.nc')

#  March
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_03.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-03-01T12%3A00%3A00Z&time_end="+str(year)+"-03-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_03.nc')
            
# April
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_04.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-04-01T12%3A00%3A00Z&time_end="+str(year)+"-04-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_04.nc')

# May
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_05.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-05-01T12%3A00%3A00Z&time_end="+str(year)+"-05-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_05.nc')

# June
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_06.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-06-01T12%3A00%3A00Z&time_end="+str(year)+"-06-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_06.nc')

# July
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_07.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-07-01T12%3A00%3A00Z&time_end="+str(year)+"-07-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_07.nc')

# August
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_08.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-08-01T12%3A00%3A00Z&time_end="+str(year)+"-08-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_08.nc')

# September
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_09.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-09-01T12%3A00%3A00Z&time_end="+str(year)+"-09-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_09.nc')

# October
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_10.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-10-01T12%3A00%3A00Z&time_end="+str(year)+"-10-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_10.nc')

# November
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_11.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-11-01T12%3A00%3A00Z&time_end="+str(year)+"-11-30T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_11.nc')

# December
for product in products:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_12.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-12-01T12%3A00%3A00Z&time_end="+str(year)+"-12-31T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_12.nc')

# February is complicated because leap years have more days than non-leap years (29 or 28)

# February non-leap years
years = (2010, 2011, 2013, 2014, 2015, 2017, 2018, 2019)

for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_02.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-02-01T12%3A00%3A00Z&time_end="+str(year)+"-02-28T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_02.nc')
           
# February leap years
years = (2012, 2016)

for product in products:
    for year in years:
            url =("http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/OFAM/ocean_"+product+"_"+str(year)+"_02.nc?var="+product+"&north=0&west=100&east=190&south=-50&horizStride=1&time_start="+str(year)+"-02-01T12%3A00%3A00Z&time_end="+str(year)+"-02-29T12%3A00%3A00Z&timeStride=1&vertCoord=2.5&addLatLon=true")
            wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/Ocean_'+product+'_'+str(year)+'_02.nc')
           
# Get mesh grid
url = 'http://dapds00.nci.org.au/thredds/ncss/gb6/BRAN/BRAN_2015/misc/grid_spec.nc?var=angle_C&var=angle_E&var=angle_N&var=angle_T&var=area_C&var=area_E&var=area_N&var=area_T&var=depth_t&var=ds_00_01_C&var=ds_00_01_E&var=ds_00_01_N&var=ds_00_01_T&var=ds_00_02_C&var=ds_00_02_E&var=ds_00_02_N&var=ds_00_02_T&var=ds_00_10_C&var=ds_00_10_E&var=ds_00_10_N&var=ds_00_10_T&var=ds_00_20_C&var=ds_00_20_E&var=ds_00_20_N&var=ds_00_20_T&var=ds_01_02_C&var=ds_01_02_E&var=ds_01_02_N&var=ds_01_02_T&var=ds_01_11_C&var=ds_01_11_E&var=ds_01_11_N&var=ds_01_11_T&var=ds_01_21_C&var=ds_01_21_E&var=ds_01_21_N&var=ds_01_21_T&var=ds_02_12_C&var=ds_02_12_E&var=ds_02_12_N&var=ds_02_12_T&var=ds_02_22_C&var=ds_02_22_E&var=ds_02_22_N&var=ds_02_22_T&var=ds_10_11_C&var=ds_10_11_E&var=ds_10_11_N&var=ds_10_11_T&var=ds_10_12_C&var=ds_10_12_E&var=ds_10_12_N&var=ds_10_12_T&var=ds_10_20_C&var=ds_10_20_E&var=ds_10_20_N&var=ds_10_20_T&var=ds_11_12_C&var=ds_11_12_E&var=ds_11_12_N&var=ds_11_12_T&var=ds_11_21_C&var=ds_11_21_E&var=ds_11_21_N&var=ds_11_21_T&var=ds_12_22_C&var=ds_12_22_E&var=ds_12_22_N&var=ds_12_22_T&var=ds_20_21_C&var=ds_20_21_E&var=ds_20_21_N&var=ds_20_21_T&var=ds_20_22_C&var=ds_20_22_E&var=ds_20_22_N&var=ds_20_22_T&var=ds_21_22_C&var=ds_21_22_E&var=ds_21_22_N&var=ds_21_22_T&var=num_levels&var=wet&var=x_C&var=x_E&var=x_N&var=x_T&var=y_C&var=y_E&var=y_N&var=y_T&north=0&west=100&east=190&south=-50&horizStride=1'
wget.download(url, '../../srv/scratch/z5278054/BRAN_AUS/BRAN_2015/grid_spec.nc')