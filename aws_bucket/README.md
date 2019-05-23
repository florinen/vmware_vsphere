## Creatin bucket on AWS

 We will create one bucket with terraform that will be used for vcenter cluster creation with terraform to store tfstate file. I order to do this, the proces of creatin this bucket on AWS, needs to be independent of the other terraform process, because terraform chechs first the state file before making any changes.
 I am creatin bucket and store the state file localy in this case, bucket will be managed independent.   