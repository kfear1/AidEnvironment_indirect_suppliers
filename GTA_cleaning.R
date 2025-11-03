#This file clean GTA files, producing a clean GTA file, as well as smaller clean files for each state

#To use this code, users must set working directory, insert path of GTA file to be cleaned, and fill in the name of the company the products are sold to, as well as ensuring the column names used in the code are correct

# indicates an explanation of the code, ### indicates an instruction


####Clear all existing variables if needed- only do this if you are sure you don't need them 
#rm(list=ls())

####set the working directory- change this to the source file location 
setwd("~/Documents/Aidenvironment")

####Insert the path of the file you want to clean 
filepath_reading<- "/Users/katiefear/Downloads/gtas_indiretas_frigol.csv"

###establish company name for file naming 
company_name<- "FRIGOL"


#load libraries:    ###the first time, user will need to run install.packages("name of library") in the console
library(utils)
library(gtools)
library(scraEP)
library(dplyr)
library(tm)
library(stringr)
library(tidytext)


#read in the file(s):
#UTF 8 ensures that accented characters will be displayed correctly 
Uncleaned_GTA<- read.csv(filepath_reading,fileEncoding = "UTF-8")

#tokeniser function- to remove punctuation and not replace it with anything
my_tokenizer <- function(x) {
  list(
    str_split(x %>% str_replace_all("[[:punct:]]", ""), "\\s+")[[1]]
  )
}


#Function to harmonise the naming of the farms, ensures abbreviations of Fazenda and Chacara are replaced, and replace roman numerals with arabic numbers
clean_names<- Vectorize(function(to_clean){
  
  c_name<-to_clean
  c_name<- tibble(c_name)
  token_c_name<- unnest_tokens(c_name, "Tokennized", c_name,token = my_tokenizer)
  
  i<- 1 
  
  while (i <= nrow(token_c_name)){
    
    check_word<-token_c_name[i,]%>%unaccent()%>%toupper()
    
    if(!is.na(check_word)){
      
      if (check_word %in% "FAZ"){
        check_word<- "FAZENDA"}
        
      #try this
      if (check_word %in% "S A"){
        check_word<- "SA"}
      
      if (check_word %in% "SIT"){
        check_word<- "SITIO"}
       
      if (check_word %in% "SIT."){
        check_word<- "SITIO"}
      
      if (check_word %in% "AGROP"){
        check_word<- "AGROPECUARIA"}
      
      if (check_word %in% "IND"){
        check_word<- "INDUSTRIA"}
      
      if (check_word %in% "CHAC"){
        check_word<-"CHACARA"}
        
        
      #not cleaning roman numerals because they are present in the SIGEF and SNCI files-- to clean roman numerals uncomment the following code:

      #if (check_word == "I"){
      #  check_word<-"1"}
      #if (check_word == "II"){
      #  check_word<-"2"}
      #if (check_word == "III"){
      # check_word<-"3"}
      # if (check_word == "IV"){
      #   # check_word<-"4"}
      
       if (check_word %in% "LTD"){
         check_word<-"LTDA"}
       else{
         (check_word<- check_word)}
  }
    
    else{
      (check_word<- check_word)}
    
    token_c_name[i,]<- check_word
    i<- i+1
    
  }
  
  final<- paste0(unlist(token_c_name), collapse=" ")
  FINAL<- toupper(final)
  
  
  return(FINAL)
})


#Clean the data by calling the clean_names function, removing accents, punctuation, additional white spaces, capitalizing all letters, and calling farm_name function:
cleaned<- Uncleaned_GTA %>% mutate(origem_nome= origem_nome %>% clean_names() %>% unaccent()%>% removePunctuation()  %>% stripWhitespace() %>% toupper(), origem_estabelecimento = origem_estabelecimento %>% clean_names() %>% unaccent()%>% removePunctuation()  %>% stripWhitespace() %>% toupper(), uf= uf %>% toupper())

#keep only the desired columns:
cleaned_smaller<- select(cleaned, c(
                        "id"
                        # ,"X"
                        ,"uf"                              
                        , "num"                             
                        , "serie"                           
                        , "status"                          
                        , "dest_id"                         
                        ,"dest_uf"                         
                        , "especie"                         
                        ,"dest_mun"                        
                        ,"emitente"                        
                        ,"validade"                        
                        , "dest_nome"                       
                        , "dest_tipo"                       
                        ,"origem_id"                       
                        , "origem_uf"                       
                        ,"protocolo"                       
                        ,"cod_barras"                      
                        ,"finalidade"                      
                        , "observacao"                      
                        ,"origem_mun"                      
                        , "dataEmissao"                     
                        ,"origem_nome"                     
                        ,"origem_tipo"                     
                        , "codigoOrigem"                    
                        ,"emitente_mun"                    
                        ,"grupoEspecie"                    
                        ,"codigoDestino"                   
                        , "emitente_local"                  
                        ,"estratificacao"                  
                        , "dataRecebimento"                 
                        ,"meio_transporte"                 
                        , "vacinas_atestados"               
                        , "dest_estabelecimento"            
                        ,"origem_estabelecimento"          
                        , "dare"                            
                        , "dest_pga"                        
                        , "num_cert"                        
                        ,"num_crmv"                        
                        ,"num_lacre"                       
                        , "valor_doc"                       
                        , "expedidora"                      
                        , "origem_pga"                      
                        , "emitente_nome"                   
                        , "emitente_tipo"                   
                        , "expedidora_mun"                  
                        , "expedidora_telefone"             
                        , "estratificacao_total"            
                        , "idGta"                           
                        ,"qrCode"                          
                        , "valorGta"                        
                        ,"valorNfe"                        
                        , "nomeOrgao"                       
                        , "dataAftosa1"                     
                        , "dataAftosa2"                     
                        , "horaEmissao"                     
                        ,"reimpressao"                     
                        , "retry_times"                     
                        , "codigoBarras"                    
                        , "tipoEmitente"                    
                        , "totalAnimais"                    
                        , "baseHomologacao"                 
                        , "totalAnimaisPorExtenso"          
                        , "valor"                           
                        , "cod_dare"                        
                        , "emitente_id"                     
                        , "dest_cod_estab"                  
                        , "dest_inscr_est"                  
                        , "origem_cod_estab"                
                        , "origem_inscr_est"
                        ,"dataBrucelose"
                        #,"emitente_funcao"
                        , "vacinacoes"                 
                        , "exames"                          
                        # , "found"                           
                        ,"gerencia"                        
                        ,"regional"                        
                        ,"dest_mun_cod"                    
                        , "origem_mun_cod"                  
                        , "subparser_type"                  
                        , "subparser_version"               
                        , "origem_exploracao_pecuaria"      
                        , "dest_exploracao_pecuaria"        
                        #, "transferencia_de_animais"        
                        #, "error"                           
                        #, "dest_aglomeracao"                
                        # , "origem_inspecao"
                        , "rid", "dest_cod"                        
                        , "origem_cod"
                        , "dataBrucelose"                   
                        #,"emitente_funcao"                 
                        , "expedidora_email"                
                        , "emitente_telefone"               
                        #, "emitente_matricula"              
                        , "orgao"                           
                        , "qrcode"                          
                        ,"valor_gta"                       
                        , "valor_nfe"                       
                        , "dest_mun_id"                     
                        , "origem_mun_id"                   
                        , "tipo_emitente"  ))

# writing cleaned file with individual file name

file_name<- paste0("Cleaned_GTA_",company_name,".csv")
write.csv(cleaned_smaller,file_name)

#Separating the cleaned data into a file for each state

#pull state names from GTA

state_names<-unique(cleaned_smaller$uf)

#remove DF and PE

state_names <- subset(state_names, state_names != c("DF","PE"))


#loop through each of the state names, for each name make a subset of the cleaned data, write to a new csv file with identifiable name

for (name in state_names){
  state<- name
  cleaned_by_state<- subset(cleaned_smaller, uf==state)
  file_name<- paste0("GTA_",state,"_", company_name, "_cleaned.csv")
  write.csv(cleaned_by_state,file_name)
}

