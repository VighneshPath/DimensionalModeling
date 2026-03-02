
## Types of Fact Tables

### Transaction Fact Tables
Row in fact table = Event in real world in space and time -> Enables maximum slicing and dicing.
Rows only exist if measurements are taken.

### Periodict Snapshot Fact Tables
Summarizes measurements/events occuring over a standard period. Grain is not the period but individual transaction.


### Accumulating Snapshot Fact Tables
Summarizes the measurement events occurring at predictable steps between the beginning and the end of a process. There is a date foreign key in the fact table for each critical milestone in the process. 

https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/accumulating-snapshot-fact-table/
