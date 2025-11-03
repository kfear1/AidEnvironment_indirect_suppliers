"""Script to join clean GTA files with clean SIGEF or SNCI files"""

#comments with a single # are explanations, comments with ### are instructions that must be done before running the code

#import libraries
import pandas as pd
import geopandas as gpd

####Before running make sure either a) this script is in the same folder as all the files we are working with or
### b) to adjust the file paths below to accomadate the different file paths- if you chose option b make sure to be careful when referencing files.

###Also ensure that all file paths fit the frameworks used below (lines 29 & 30), and that the file names created by cleaning scripts have been retained


def joining(shape_file_type:str)-> None:
    """This function will join either SIGEF or SNCI files with GTA files for each state-- takes a string of the type of shape file as an argument"""

    
    Companies= ["FRIGOL"]      #List of the companies  ###Adjust this based off of the companies being analysed

    
    States=['PA']      #List of the states      ###ADJUST this based off of states in GTAs
    
    
   
    for company in Companies:            #For each company, join that company's GTAs with the SIGEF/SNCI file- does this for each file that is separated by state

        for state in States:


            file_GTA= f"GTA_{state}_{company}_cleaned.csv"          # Creates file path framework--make sure your files fit this
            shapefile_file= f"{state}_clean_{shape_file_type}.shp"
    
            shapefile=gpd.read_file(shapefile_file) #reads in the file for current state and company

            GTAfile= gpd.read_file(file_GTA)        #reads in the GTA file 

            if state != "RO":                       #process for all states that are not Rondonia

                if shape_file_type=="SIGEF":        #process for SIGEF files
                    
                    #make sure user entered correct file type for the file being processed, if not, will display an error message
                    assert 'nome_area' in shapefile.columns, "Either the column required for this test is not present in dataset (check name of state identifier column) or file provided does not match file type entered"     
                    
                    #Make all joins between SIGEF and GTA
                    join_nome_area_21_own=shapefile.merge(GTAfile,how='inner',left_on=['nome_area','X2021_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    join_nome_area_19_own=shapefile.merge(GTAfile,how='inner',left_on=['nome_area','X2019_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    join_25_farm_19_own=shapefile.merge(GTAfile,how='inner',left_on=['X2025_farm','X2019_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    join_25_farm_21_own=shapefile.merge(GTAfile,how='inner',left_on=['X2025_farm','X2021_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    join_21_farm_19_own=shapefile.merge(GTAfile,how='inner',left_on=['X2021_farm','X2019_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    join_21_farm_21_own=shapefile.merge(GTAfile,how='inner',left_on=['X2021_farm','X2021_owne'], right_on=['origem_estabelecimento','origem_nome'])

                    all_joins= pd.concat([join_nome_area_21_own,join_nome_area_19_own,join_25_farm_19_own,join_25_farm_21_own,join_21_farm_19_own,join_21_farm_21_own])     #combines all the joins into one large file

                elif shape_file_type=="SNCI":

                    #makes sure user entered correct file type for the file being processed, if not, will display an error message
                    assert '2021 farm' in shapefile.columns, "Either the column required for this test is not present in dataset (check name of state identifier column) or file provided does not match file type entered"   

                    #Make all joins between SNCI and GTA:
                    join_21_farm_own=shapefile.merge(GTAfile,how='inner',left_on=['2021 farm','2021 owner'], right_on=['origem_estabelecimento','origem_nome'])

                    join_25_farm_21_own=shapefile.merge(GTAfile,how='inner',left_on=['2025 farm','2021 owner'], right_on=['origem_estabelecimento','origem_nome'])

                    join_nome_imove_21_own=shapefile.merge(GTAfile,how='inner',left_on=['nome_imove','2021 owner'], right_on=['origem_estabelecimento','origem_nome'])
                    
                    all_joins= pd.concat([join_21_farm_own,join_25_farm_21_own,join_nome_imove_21_own])     #combines all the joins into one large file

            else:
                #If the state is Rondonia the following code will run

                #establishing owner name variable in both SIGEF and SNCI:
                if shape_file_type=="SNCI":     
                    ownername21 ='2021 owner'

                else:
                    ownername21 ='X2021_owne'

               
                all_joins= shapefile.merge(GTAfile,how='inner',left_on=[ownername21], right_on=['origem_nome'])      #performs the join to create a table that contains only rows where the GTA owner name matches the shapefile's owner's name

            #Filters results so that each polygon only has one set of information attached to it:
            geo_filter=all_joins.drop_duplicates('geometry')
            
            #Write to a shape file:
            file_name= (f"joined_{state}_{company}_{shape_file_type}.shp")
            geo_filter.to_file(file_name)

            #print completion message for each state to user:
            print(f"Processsing for {file_name} has completed")

###to call the function, uncomment the code below to run for either SIGEF or SNCI:

joining("SIGEF")
#joining("SNCI")


