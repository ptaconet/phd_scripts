#require(RSQLite)
#require(dplyr)
#require(lubridate)
#react_gpkg <- dbConnect(RSQLite::SQLite(),path_to_gpkg_database)

raw_bf_dates_hlc<-read_excel("data/react_db/miscellaneous_data/Heure de captures REACT-BF_M1_M7 (copie).xls")
raw_civ_dates_hlc<-read_excel("data/react_db/miscellaneous_data/Dates_capture entomo cote  d'Ivoire.xlsx")

colnames(raw_bf_dates_hlc)<-c("n_mission","nomvillage","codevillage","CSPS","date_de_captures","heure_de_debut","heure_de_fin","n_sac","observations")
raw_bf_dates_hlc$date_de_captures<-as.character(as.Date(raw_bf_dates_hlc$date_de_captures, format="%d/%m/%Y"))
raw_bf_dates_hlc$codepays<-"BF"
raw_bf_dates_hlc$heure_de_debut<-gsub("H",":",raw_bf_dates_hlc$heure_de_debut)
raw_bf_dates_hlc$heure_de_debut<-gsub("h",":",raw_bf_dates_hlc$heure_de_debut)
raw_bf_dates_hlc$heure_de_fin<-gsub("H",":",raw_bf_dates_hlc$heure_de_fin)
raw_bf_dates_hlc$heure_de_fin<-gsub("h",":",raw_bf_dates_hlc$heure_de_fin)
raw_bf_dates_hlc$heure_de_debut<-paste0(raw_bf_dates_hlc$heure_de_debut,":00")
raw_bf_dates_hlc$heure_de_fin<-paste0(raw_bf_dates_hlc$heure_de_fin,":00")
raw_bf_dates_hlc$date_heure_debut<-paste(raw_bf_dates_hlc$date_de_captures,raw_bf_dates_hlc$heure_de_debut,sep=" ")
raw_bf_dates_hlc$date_heure_fin<-paste(as.Date(raw_bf_dates_hlc$date_de_captures)+1,raw_bf_dates_hlc$heure_de_fin,sep=" ")



colnames(raw_civ_dates_hlc)<-c("date_de_captures","nomvillage","n_mission")
raw_civ_dates_hlc$date_de_captures<-as.character(raw_civ_dates_hlc$date_de_captures)
raw_civ_dates_hlc$nomvillage <- raw_civ_dates_hlc$nomvillage %>% str_replace_all(c("Penatiguikaha" = "Penatiguikaha_Gopko", "Logaha" = "Lokaha","Kolékaha"= "Kolekaha","Lagomokaha"= "Lagomounkaha","Yenessonkaha"= "Yenessonkaha_Gofionkaha","Narlougokaha"= "Nalourgokala","Katiorpokaha"= "Katiorkpo","Kogninguekaha"= "Koguin","Tagbarakaha"= "Tagbara","Nongotakaha"= "Nongotanakaha","Karafiné"= "Karafine","Nongowélékaha"= "Nangowelekaha","Kougniguékaha"= "Koungniguékaha","Félékaha"= "Felekaha","Tahouélékaha"= "Tahouelekaha","Blaouara"= "Blawara" ))
query<-"SELECT codepays, nomvillage ,codevillage FROM recensement_villages_l1 WHERE codepays='CI'"
villages<-dbGetQuery(react_gpkg, query)
raw_civ_dates_hlc<-left_join(raw_civ_dates_hlc,villages)
raw_civ_dates_hlc$CSPS<-raw_civ_dates_hlc$heure_de_debut<-raw_civ_dates_hlc$heure_de_fin<-raw_civ_dates_hlc$n_sac<-raw_civ_dates_hlc$observations<-raw_civ_dates_hlc$date_heure_debut<-raw_civ_dates_hlc$date_heure_fin<-NA
raw_dates_hlc<-rbind(raw_bf_dates_hlc,raw_civ_dates_hlc)

# correction sac
raw_dates_hlc$n_sac[which(raw_dates_hlc$codevillage=='SID' & raw_dates_hlc$n_mission==2)]="C"
