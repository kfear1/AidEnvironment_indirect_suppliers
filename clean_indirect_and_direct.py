# """clean indirect and direct files to improve join between the two"""

#comments with a single # are explanations, comments with ### are instructions that must be done before running the code


#imports libraries
import geopandas as gpd
from unidecode import unidecode

file_path_d= "/Users/katiefear/Documents/Aidenvironment/"                ###INSERT the path to the folder containing direct GTA and indirect shapefiles here 


file_names=['FRIGOL']     #names of direct files       ###CHECK to make sure this is right

def direct(file_path):
    """cleans origem_nome and origem_estabelecimento columns direct GTA files"""
    for name in file_names:      #cleans the origem_nome and origem_estabelecimento columns for each direct file
        file= gpd.read_file(f"{file_path}{name}.csv")

        

        #file = pd.read_csv(f"{file_path}{name}.csv", encoding="utf-8", errors="replace")


        file['origem_estabelecimento'] = file['origem_estabelecimento'].apply(unidecode)
        file['origem_estabelecimento'] = file['origem_estabelecimento'].apply(str.upper)
        file['origem_nome'] = file['origem_nome'].apply(unidecode)
        file['origem_nome'] = file['origem_nome'].apply(str.upper)
        file.to_csv(f"{name}_direct_clean.csv")




###RUN the function like this
direct(file_path_d)

file_path_i= "/Users/katiefear/Documents/Aidenvironment/Indirect_suppliers/scripts/"
def indirect(file_path):
    """function to clean dest_estabelecimento and dest_nome columns of the indirect files"""
        
    #companies project focuses on
    Companies= ["FRIGOL"]          ###Adjust this based off of the companies being analysed

    #List of the states-                                
    States=['PA']          ###ADJUST this based off of states in GTAs

    Shapes= ["SIGEF"]      #removed "SNCI" for this run          


    for company in Companies:
        for state in States:
            for shape in Shapes:

                #read in the file
                file_name= f"{file_path}Difference_{state}_{company}_{shape}.shp"       #not .gpkg this time because not edited in QGIS
                file=gpd.read_file(file_name)

                #clean the files
                file['dest_estab'] = file['dest_estab'].apply(unidecode)        
                file['dest_estab'] = file['dest_estab'].apply(str.upper)
                file['dest_nome'] = file['dest_nome'].apply(unidecode)
                file['dest_nome'] = file['dest_nome'].apply(str.upper)
                file.to_file(f"Difference_{state}_{company}_{shape}.shp")
                print(f"(Difference_{state}_{company}_{shape}.shp has been created)")


###RUN the function with this line
indirect(file_path_i)
