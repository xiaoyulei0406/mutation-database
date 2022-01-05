#!/usr/bin/env Rscript
suppressWarnings(suppressMessages(library("optparse")))
optionList = list(make_option(c("-i", "--input_dir"), type="character", default=NULL, help="inputdir: file or working folder.\n"),
                  make_option(c("-o","--out_dir"),type="character",default=NULL,help="output folder")
);

opt_parser = OptionParser(option_list=optionList)
opt = parse_args(opt_parser)

if (is.null(opt$input_dir)||is.null(opt$out_dir)){
  print_help(opt_parser)
  stop("Parameter errors!", call.=FALSE)
}

suppressWarnings(suppressMessages(library("dplyr")))
suppressWarnings(suppressMessages(library("stringr")))
suppressWarnings(suppressMessages(library("pdftools")))
suppressWarnings(suppressMessages(library("tidyr")))
suppressWarnings(suppressMessages(library('tidyverse')))
suppressWarnings(suppressMessages(library("dplyr")))
suppressWarnings(suppressMessages(library("magrittr")))
suppressWarnings(suppressMessages(library("tibble")))
suppressWarnings(suppressMessages(library("tm")))
options( warn = -1 )

input_dir=opt$input_dir
out_dir=opt$out_dir

dir <- input_dir
files <-list.files(dir)
pdfs<-paste0(dir,files[grep(".pdf",files)])

df_all <-data.frame(matrix(ncol = 7, nrow = 0))
colnames(df_all)<-c("patientID","Gene","Standardized Nomenclature (HGVS)","Location","DNA change","Protein change","COSMIC ID and dbSNP ID")
#print(df_all)
for (pdf in pdfs){
  ##read pdf
  pdf_file<-file.path(pdf)
  ##extract file name from full path
  pdfname=sub('\\..*$', '', basename(pdf))
  text <- pdf_text(pdf_file)
  ##read first page
  tab<-str_split(text, "\n")[[1]][6:55]
  tab<-gsub("\\s+ ", "\t", tab)
  
  for (page in 2:length(text)){
    tmp <- str_split(text, "\n")[[page]][6:55]
    tmp <-gsub("\\?","\\?\t",tmp)   ##replace ? with ? + '\t"
    ##footer name
    footer_row_1<-which(tmp=="_________________________________________________________________________________________________")
    footer_row_2 <- grep("TARIQUE, ZAINAB",tmp)
    footer_row_3<- grep("Case Number:",tmp)
    footer_row_4<-grep("Med Rec Number:",tmp)
    footer_row_5<-grep("Report Request ID:",tmp)
    footer_row_6<-grep("Page", tmp)
    footer_row_7 <- grep("Unless otherwise noted, all labs were performed at MD Anderson", tmp)
    ## header name
    header_1 <- grep("Molecular Diagnostics", tmp)
    header_2<-grep("FINDINGS:", tmp)
    header_3<-grep("Copy Number Variations", tmp)
    header_4<-grep("None identified", tmp)
    header_5<-grep("Somatic Mutations", tmp)
    ##remove header and footer
    tmp<-data.frame(tmp)
    tmp_1<-tmp[-c(header_1,header_2,header_3,header_4,header_5,footer_row_1,footer_row_2,footer_row_3,footer_row_4,footer_row_5,footer_row_6,footer_row_7),]
    tmp_1<-as.character(tmp_1)
    tmp_1<-gsub("\\s+ ", "\t", tmp_1)
    tmp_1<-data.frame(tmp_1)
    tab <- rbind(tab, tmp_1)
  }
  
  ##remove NA
  suppressMessages(library(tidyr))
  tab_1<-tab %>% drop_na()
  #remove other rows
  remove_flag=which(tab_1=="GUIDE TO STANDARDIZED NOMENCLATURE AND EXPLANATION OF CHANGES:")
  tab_2<-data.frame(tab_1[-(remove_flag:nrow(tab_1)),])
  
  # tab_3 takes the next non-empty piece of text
  tab_3 <- tab_2[tab_2 != ""] 
  # remove first line
  tab_3 <- as.data.frame(tab_3)
  tab_4 <- tab_3[-1,]
  
  header="Gene\tStandardized Nomenclature (HGVS)\tLocation\tDNA change\tProtein change\tCOSMIC ID and dbSNP ID"
  out_txt=paste(out_dir,pdfname,".txt")
  write.table(tab_4,out_txt,sep="\t",quote=F,row.names = F,col.names = header)
  ## convert txt to excel
  suppressMessages(library(openxlsx))
  df <- read.table(out_txt,sep='\t',fill=TRUE)

  df$patientID<-c("patientID",rep(pdfname,(nrow(df)-1)))
  ##change column order
  df<-df[c(7,1,2,3,4,5,6)]
  df<-df[!grepl("change", df$V2),]
  print(paste(pdfname,".pdf has been processed",sep=""))
  names(df) <- lapply(df[1, ], as.character)
  df <- df[-1, ] 
  df_all=rbind(df_all,df)
#  out_xls=paste(out_dir,pdfname,".xlsx",sep='')
#  write.xlsx(df_all,out_xls,sep="\t",colNames = FALSE,rowNames=FALSE)
  ##remove internal txt files
  file.remove(out_txt)
}
out_xls=paste(out_dir,"merged.xlsx",sep='')
out_csv=paste(out_dir,"merged.csv",sep='')
write.xlsx(df_all,out_xls,sep="\t",colNames = TRUE,rowNames=FALSE)
write.csv(df_all,out_csv, row.names = FALSE)

print("All the pdf files have been merged.")



#Rscript /Users/cyu/Documents/work/database/scripts/pdf2excel.R -i /Users/cyu/Documents/work/database/testfile/ -o /Users/cyu/Documents/work/database/testfile/tables/

