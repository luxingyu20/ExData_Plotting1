# Load Required Packages

if( !require( readr ) ) { install.packages( "readr" ) }
if( !require( tidyr ) ) { install.packages( "tidyr" ) }
if( !require( dplyr ) ) { install.packages( "dplyr" ) }
if( !require( lubridate ) ) { install.packages( "lubridate" ) }

library( readr ) 
library( tidyr )
library( dplyr )
library( lubridate )

# Remove Objects; Create Directory & Download Data

rm( list = ls() )
if( !file.exists( "./data" )){ dir.create( "./data" )}

url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
download.file( url, 
               destfile = "./data/dataset.zip", 
               method = "curl" )
rm( url )

# Unzip; Read In Date-Specific Data & Coerce Classes

unzip( zipfile = "./data/dataset.zip" )

file <- "household_power_consumption.txt"
cols <- c( "date", "time", "global_active_power", "global_reactive_power", 
           "voltage", "global_intensity", "sub_metering_1", "sub_metering_2", 
           "sub_metering_3" )
typs <- c( "ccccccccc")

power <- read_csv2( file = file, 
                    skip = 66637, 
                    n_max = 2880, 
                    col_names = cols, 
                    col_types = typs ) 

# Combine "date" and "time" to POSIXlt: "datetime"; Coerce Remaining Classes

power <- power %>% unite( col = datetime, date, time, sep = " " )
power$datetime <- dmy_hms( power$datetime )

power[,2:7] <- sapply( power[,2:7], as.numeric )

rm( cols, file, typs )

# Reset Global Defaults; Create & Save Plot; Disconnect Device

plot.new()

png( filename = "plot4.png", width = 480, height = 480 )

# Set Facet Rows/Columns: 2*2 Plots

par( mfrow = c( 2, 2 ))

## Subplot c(1,1)

with( power, plot( x = datetime, 
                   y = global_active_power, 
                   type = "n", 
                   xlab = "", 
                   ylab = "Global Active Power" ))
with( power, lines( x = datetime, y = global_active_power ))

## Subplot c(1,2) 

with( power, plot( x = datetime, 
                   y = voltage, 
                   type = "n", 
                   xlab = "datetime", 
                   ylab = "Voltage" ))
with( power, lines( x = datetime, y = voltage ))

## Subplot c(2,1)

with( power, plot( x = datetime, 
                   y = sub_metering_1, 
                   type = "n", 
                   xlab = "", 
                   ylab = "Energy sub metering" ))
with( power, lines( x = datetime, y = sub_metering_1, col = "darkgrey" ))
with( power, lines( x = datetime, y = sub_metering_2, col = "red" ))
with( power, lines( x = datetime, y = sub_metering_3, col = "blue" ))
legend( "topright",
        lty = 1,
        bty = "n",
        cex = 0.75,
        legend = c( "Sub_metering_1",
                    "Sub_metering_2", 
                    "Sub_metering_3" ), 
        col = c( "darkgrey",
                 "red",
                 "blue" ))

## Subplot c(2,2)

with( power, plot( x = datetime, 
                   y = global_reactive_power, 
                   type = "n", 
                   xlab = "datetime", 
                   ylab = "Global_reactive_power" ))
with( power, lines( x = datetime, y = global_reactive_power ))

dev.off()