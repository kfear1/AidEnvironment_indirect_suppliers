"""This script joins the indirect suppliers with the direct suppliers GTA in order to obtain the location of the slaughterhouse"""

#comments with a single # are explanations of what the code does, comments with ### are instructions that must be done before running the code

#importing necessary libraries:
import geopandas as gpd
import pandas as pd

folder_path="/Users/katiefear/Documents/Aidenvironment/Indirect_suppliers/scripts/"            ###ENTER the path to the folder in which both your indirect and direct files are stored

def add_final():
    """function that performs the join between the direct supplier GTA and the indirect shapefile"""

    #establishing the different combinations of files that there can be:
    States=['PA']          ###ADJUST this based off of states in GTAs

    Companies= ["FRIGOL"]          ###ADJUST this based off of the companies being analysed

    shape_file_type=["SIGEF"] #add SNCI if necessary

    #reads and adjusts the direct GTA files:

    for company in Companies:   #will loop through each file and make sure there are no accents and all letters are uppercase

        #read in direct files:
        direct_file= gpd.read_file(f"{folder_path}{company}_direct_clean.csv")        ###CHECK that the direct file name has this file structure (e.g. JBS_direct_clean.csv)- should be correct if the script clean_indirect_and_direct.py was used 
        direct_file=direct_file.drop_duplicates() #drop any duplicate rows  

        for state in States:
            
            for shape in shape_file_type:
                
                #reads in the indirect files:   Difference_GO_JBS_SNCI.gpkg
                indirect_file_path= f"{folder_path}Difference_{state}_{company}_{shape}.shp" ###CHECK file extension-- .gpkg comes from files saved in QGIS, if cleaning file has been run, use .shp
                indirect_file= gpd.read_file(indirect_file_path)      

                if company =='JBS':     #for JBS this code wil run                                                          
                    #reads in extra JBS file         
                    JBS_confinamento_direct= gpd.read_file(f"{folder_path}JBS confinamento_direct_clean.csv")     ###MAKE sure this is the right file name 
                    direct_file_2= JBS_confinamento_direct[['origem_estabelecimento','origem_nome','dest_mun']]   #extracting the important columns from the direct file
                    direct_file_2=direct_file_2.rename(columns={'dest_mun':'final_mun'})                          #renames the column dest_mun to be final_mun
                    join_indirect_direct_2=indirect_file.merge(direct_file_2,how='left',left_on=['dest_estab','dest_nome'], right_on=['origem_estabelecimento','origem_nome'])  #creating the join between the direct and indirect files


                direct_file_narrow=direct_file[['origem_estabelecimento','origem_nome','dest_mun']]           #extracting the important columns from the direct file
                direct_file_narrow=direct_file_narrow.rename(columns={'dest_mun':'final_mun'})                #renames the column dest_mun to be final_mun

                #joins files on the farm and owner name:
                join_indirect_direct=indirect_file.merge(direct_file_narrow,how='left',left_on=['dest_estab','dest_nome'], right_on=['origem_estabelecimento','origem_nome'])

                if company=="JBS":
                    join_indirect_direct=pd.concat([join_indirect_direct_2,join_indirect_direct])                 #combines the joins from both JBS files

                # Sort so rows with final_mun information come before NA values
                join_indirect_direct = join_indirect_direct.sort_values(by='final_mun', na_position='last')

                # Drop duplicates, keeping the first occurrence (which now has final_mun if available)-- makes sure each polygon only has one set of information
                join_indirect_direct = join_indirect_direct.drop_duplicates(subset=['geometry'], keep='first')
                

                #removes unused columnsin the dataset:
                reduced_columns= join_indirect_direct.drop(columns=['dare', 'dest_pga', 'num_cert', 'num_crmv', 'num_lacre', 'valor_doc',
                'expedidora', 'origem_pga', 'emitente_n', 'emitente_t', 'expedido_1',
                'expedido_2', 'estratif_1', 'idGta', 'qrCode', 'valorGta', 'valorNfe',
                'nomeOrgao', 'dataAftosa', 'dataAfto_1', 'horaEmissa', 'reimpressa',
                'retry_time', 'codigoBarr', 'tipoEmiten', 'totalAnima', 'baseHomolo',
                'totalAni_1', 'valor', 'cod_dare', 'emitente_i', 'dest_cod_e',
                'dest_inscr', 'origem_cod', 'origem_ins', 'dataBrucel', 
                'vacinacoes', 'exames', 'gerencia', 'regional', 'dest_mun_c',
                'origem_m_1'])
                
                #removes columns that are only present in some files
                extra_cols= ['found', 'subparser_', 'subparse_1', 'origem_exp',
                'dest_explo', 'transferen', 'error', 'dest_aglom', 'origem_i_1', 'rid',
                'dest_cod', 'origem_c_1', 'expedido_3', 'emitente_1', 'emitente_2',
                'orgao', 'qrcode_1', 'valor_gta', 'valor_nfe', 'dest_mun_i',
                'origem_m_2', 'tipo_emite', 'area','emitente_f']


                for column in extra_cols:
                    if column in list(reduced_columns.columns):
                        reduced_columns=reduced_columns.drop(columns=column)

                #creates a shapefile out of the resulting table
                reduced_columns.to_file(f"{folder_path}Indirect_suppliers_{state}_{company}_{shape}.shp")
                print(f"Indirect_suppliers_{state}_{company}_{shape}.shp has been created")

###USE the following line to call the function
add_final()

                
