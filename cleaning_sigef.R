#This file cleans SIGEF files, creating a clean SIGEF dbf. This file will have to be manually renamed to match the SIGEF shape file name, and added to the shapefile folder before processing of the clean data can occur

#To use this code, users must set working directory, insert path of file to be cleaned, and fill in the name of the company the products are sold to, as well as ensuring the column names used in the code are correct

# indicates an explanation of the code, ### indicates an instruction


###Clear all exisiting variables if needed- only do this if you are sure you don't need them 
#rm(list=ls())

###set the working directory- change this to the source file location 
setwd("~/Documents")


file_path="Sigef Brasil_sncr25_21_19/Sigef Brasil_sncr25_21_19.dbf"  ###Insert the SIGEF file path here


#load packages    ###will have to use install.packages("package_name") if never used these before

library(stringr)
library(dplyr)
library(foreign)
library(scraEP)
library(tm)
library(tidytext)
library(sf)

#read in file
sigef<- read.dbf(file_path)


#List mis-encodings and their replacements
replacements <- c(
  # E
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â " = "E",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â°" = "E",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â°" = "E",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â©" = "E",
  "ÃƒÆ’Ã‚Â©" = "E",
  "ÃƒÂ©" = "E",
  "ÃƒÂ‰" = "E",
  "Ã‰" = "E",
  "ÃƒÆ’Ã¢â‚¬Â°" = "E",
  "ÃŠ" = "E",
  "ÃƑÆ’Ã¢Â‚¬Â°"="E",
  "ÃƑÆ’Ã‚Â©\""="E",
  "I©"="E",
  "Iª"="E",
  "ÃƑÆ’Ã…Â"="E", 
  "ÃƑÆ’Ã…Â "="E",
  "ÃƒÆ’Ã…Â "="E",
  "ÃƒÆ’Ã…Â "="E",
  "ÃƒÆ’Ã…Â\u00d"="E",
  
# O
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¯Ã‚Â¿Ã‚Â½"= "O",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã¢â‚¬Å“" = "O",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢" = "O",
  "ÃƒÆ’Ã¢â‚¬ï¿½" = "O",
  "Ã“" = "O",
  "Ã”" = "O",
  "ÃƒÂ•" = "O",
  "Ã•" = "O",
  "ÃƒÆ’Ã‚Â´" = "O",
  "ÃƑÆ’Ã‚Â´" = "O",
  "I³"="O",
  "ÃƑÆ’Ã¢Â‚¬Å“"="O",
  "ÃƑÆ’Ã¢Â‚¬Â\u009d"="O",
  "ÃƑÆ’Ã¢Â‚¬Â¢"="O",
  "ÃƑÆ’Ã¢Â‚¬Â„¢"="O",
  
  # C
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¡" = "C",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â§" = "C",
  "ÃƒÆ’Ã‚Æ’Ãƒâ€šÃ‚Â§" = "C",
  "ÃƒÂ‡" = "C",
  "ÃƒÆ’Ã‚Â§" = "C",
  "ÃƑÆ’Ã‚Â§" ="C",
  "AÃƑÂ€ŠÃ†Â€™ÃƑÆ’Ã¢Â‚¬Å¡ÃƑÂ€ŠÃ‚Â§"="C",
  "ÃƑÆ’Ã¢Â‚¬Â¡"="C",
  "¢Â‚¬Â¡"="C",
  "AÃƑÂ€ŠÃC"="C",
  "‚Â§"="C",
"Æ’Ã¢â‚¬Â¡"="C",
  
  # A
  "?Ãƒâ€¦Ã‚Â¸" = "A",
  "ÃƒÆ’Ã†â€™" = "A",
  "?ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¸" = "A",
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¡" = "A",
  "ÃƒÂ£" = "A",
  "ÃƒÂ" = "A",
  "Ãƒ" = "A",
  "A" = "A",
  "AÃƒÆ’Ã‚Â£" = "A",
  "ÃƒÆ’Ã‚Â¢" = "A",
  "ÃƒÆ’Ã‚Â" = "A",
  "ÃƒÆ’Ã‚Â£" = "A",
  "AÆ’Ã‚Â" = "A",
  "ÃƒÆ’Ã‚Â¡" = "A",
  "ÃƑÆ’Ã‚Â£" ="A",
  "ÃƑÆ’Ã‚Â\u0081" ="A",
  "ÃƑÆ’Ã†Â€™"="A",
  "AÃƑÂ€ŠÃ†Â€™"="A",
  "I¢"="A",
  "I¡"="A",
  "ÃƑÆ’Ã¢Â€ŠÂ¬"="A",
  "ÃƑÆ’Ã¢Â‚¬Å¡"="A",
  "ÃƑÂ€ŠÃ‚Âª"="A",
  "AAÃƑÂ€ŠÃ‚Â\u0081"="A",
  "AAÃƑÂ€ŠÃ"="A",
  "AÃƑÂ€ŠÃ‚Â£"="A",
  "AÃƑÂ€ŠÃ‚Â\u0081"="A",
  "AA¢Â‚¬Å¡A"="A",
  
  
  # I
  "AÃƒâ€šÃ¯Â¿Â½" = "I",
  "ÃƒÂ­" = "I",
  "ÃƒÆ’Ã‚Â­" = "I",
  "ÃƑÆ’Ã‚Â\u008d"="I",
  "ÃƑÆ’Ã‚Â\u008d"="I",
  "ÃƑÆ’Ã‚Â"="I",
  "ÃƑÂ€ŠÃ‚Â­I"="I",
  "ÃƑÂ€ŠÃ‚Â"="I",
  "AI\u008d"="I",
  "II\u008d"="I",
  "A‚Â\u008d"="I",
  "\\xef"="I",
  
  # U
  "ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Âº" = "U",
  "Ãš­" = "U",
  "ÃƑÆ’Ã…Â¡"="U",
  "Iº"="U",
  
#Space
"I¿"= " ",
"?C?,"="",

#Full stop
"I°"=".",
"ÃƑÂ€ŠÃ‚Âº"="."

)

#Make sure the replacements run from the longest to the shortest to avoid creating more misencoding problems
replacements <- replacements[order(nchar(names(replacements)), decreasing = TRUE)]


#make quick function that makes the characters uppercase and replaces misencoded characters


clean_encoding <- function(column, replacements) {
  column %>%
    str_to_upper() %>%                            
    str_replace_all(fixed(replacements))
}


#First clean misencodings:
sigef_clean <- sigef %>%
  mutate(nome_area = clean_encoding(nome_area, replacements), X2025.farm.= clean_encoding(X2025.farm., replacements), X2021.owner= clean_encoding(X2021.owner, replacements),X2019.owner= clean_encoding(X2019.owner, replacements),X2021.farm.= clean_encoding(X2021.farm., replacements))



#Second remove any weird characters that remain and remove accents, punctuation and additional whitespace:
sigef_clean <- sigef_clean %>%
  mutate(nome_area = iconv(nome_area, from = "", to = "UTF-8", sub = "") %>% unaccent()%>% removePunctuation()  %>% stripWhitespace(),X2025.farm.= iconv(X2025.farm., from = "", to = "UTF-8", sub = "") %>% unaccent()%>% removePunctuation()  %>% stripWhitespace(),X2021.owner= iconv(X2021.owner, from = "", to = "UTF-8", sub = "") %>% unaccent()%>% removePunctuation()  %>% stripWhitespace(),X2019.owner= iconv(X2019.owner, from = "", to = "UTF-8", sub = "") %>% unaccent()%>% removePunctuation()  %>% stripWhitespace(),X2021.farm.= iconv(X2021.farm., from = "", to = "UTF-8", sub = "") %>% unaccent()%>% removePunctuation()  %>% stripWhitespace())



#Write clean SIGEF file with a different name to the unclean file, this ensures that running this code will NOT overwrite the original file
write.dbf(sigef_clean, "cleanlargesigef.dbf")     ###WILL have to be manually renamed to match the shape file and added to the same folder as the shapefile-- recommended to save the original dbf file somewhere else just incase issues arise
