"""Script to separate large clean SIGEF or SNCI file into smaller files for each state"""

#comments with a single # are explanations, comments with ### are instructions that must be done before running the code

#import libraries
import geopandas as gpd           #package for manipulating files
import fiona                      #package for reading in files even if they have uncleaned encoding issues



def separating(file_path, file_type)-> None:
    """This function will separate create either SIGEF or SNCI files for each state depending on the file it is given"""

    #read in the file
    with fiona.open(file_path, encoding='latin1') as all_states:
        all_states = gpd.GeoDataFrame.from_features(all_states)

    
    #establishes whether we are working with SIGEF or SNCI:
    if file_type=="SNCI":

        #makes sure user entered correct file type for the file being processed:
        assert 'uf_municip' in all_states.columns, "Either the column required for this test is not present in dataset (check name of state identifier column) or file provided does not match file type entered"   
        
        print("SNCI files being created") #prints message to user
        state_info= ['SP', 'TO', 'GO', 'MS', 'MT', 'PA', 'RO', 'MG'] #establishes how states are identified in the shapefile ###MAKE sure all the states being examined are present in this list

    elif file_type=="SIGEF":
        #makes sure user entered correct file type for the file being processed
        assert 'uf_id' in all_states.columns, "Either the column required for this test is not present in dataset (check name of state identifier column) or file provided does not match file type entered"   
        
        print("SIGEF files being created") #prints message to user
        state_info= { "MT": 51, "PA": 15, "RO": 11, "MS":50, "GO":52, "MG":31, "TO":17, "SP":35 } #establishes how states are identified in the shapefile        ###MAKE sure all the states being examined are present in this list

    else: 
        print("There is something wrong with the type of file you specified, please check you entered either \"SNCI\" or \"SIFEF\"")
        return None
    
    for state in state_info:
        
        if file_type=="SNCI":
            #for SNCI makes a file with all the rows for that state
            file=all_states[all_states['uf_municip'] == str(state)] 

        elif file_type=="SIGEF":
            #for SIGEF makes a file with all the rows for that state
            state_code=state_info[state]
            file=all_states[all_states['uf_id'] == state_code]

        file_name=f"{state}_clean_{file_type}.shp" 

        file.to_file(file_name)               #creating the file

        print(f"File {file_name} has finished processing")
    
    return None

###call this function like this:
#separating("path/to.file", "SIGEF")



