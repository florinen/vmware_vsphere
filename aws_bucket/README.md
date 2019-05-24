## Creating bucket on AWS
    
    We will create one bucket with terraform that will be used for vcenter cluster creation with terraform to store tfstate file. 
 In order to do this, the process of creating this bucket on AWS, needs to be independent of the other terraform process, because terraform checks first 
 the state file before making any changes. I am creating bucket and store the state file locally in this case, bucket will be managed independent.  

   