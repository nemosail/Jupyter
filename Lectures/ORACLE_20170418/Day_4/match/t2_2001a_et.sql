DROP TABLE t2_2001a_et;                                                      
CREATE TABLE t2_2001a_et                                                     
(                                                                               
	 "CODE"                           VARCHAR2(12)                                 
	,"SOURCE_ID"                      NUMBER                                       
	,"SOURCE_ACCOUNT"                 NUMBER                                       
	,"PROGRAM_ID"                     VARCHAR2(12)                                 
	,"TRANSACTION_DATE"               DATE                                         
	,"TRANSACTION_NUMBER"             NUMBER                                       
	,"VALUE"                          NUMBER                                       
	,"FUNCTION"                       NUMBER                                       
	,"INDICATOR"                      VARCHAR2(1)                                  
	,"COMMENTS"                       VARCHAR2(50)                                 
)                                                                               
ORGANIZATION EXTERNAL                                                           
(                                                                               
	TYPE oracle_loader                                                             
	DEFAULT DIRECTORY DATA                                                  
	ACCESS PARAMETERS                                                              
	(                                                                              
		RECORDS DELIMITED BY X'A'                                                     
		BADFILE LOG_DIR:'t2_2001a_%a+%p.bad'                                       
		LOGFILE LOG_DIR: 't2_2001a_%a+%p.log'                                      
		FIELDS TERMINATED BY X'7C'                                                    
		MISSING FIELD VALUES ARE NULL                                                 
		(                                                                             
			 "CODE"                                                                      
			,"SOURCE_ID"                                                                 
			,"SOURCE_ACCOUNT"                                                            
			,"PROGRAM_ID"                                                                
			,"TRANSACTION_DATE"  DATE mask "dd-mon-yy"                                   
			,"TRANSACTION_NUMBER"                                                        
			,"VALUE"                                                                     
			,"FUNCTION"                                                                  
			,"INDICATOR"                                                                 
			,"COMMENTS"                                                                  
		)                                                                             
	)                                                                              
	LOCATION (                                                                     
  't2_2001a.dat'
  )
)
REJECT LIMIT UNLIMITED
;
