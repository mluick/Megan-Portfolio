# -*- coding: utf-8 -*-
"""
Created on Sat Nov 23 15:06:58 2019

@author: melui
"""

# for counties
# for reading the csvs and outputting only a file with the winner of each area

import csv

in_csv = r'C:\Users\melui\Documents\fall_2019\cartography\labs\final\data_usable\county_dem_repub_only.csv'
out_csv = r'C:\Users\melui\Documents\fall_2019\cartography\labs\final\data_usable\county_winners.csv'

#write results to file. Note that mode='a' means the results will be appended.
#If I want to create an entirely new version, I need to clear the old file.
def appendValues(write_values):
    with open(out_csv, mode='a') as out_file:
        csv_writer = csv.writer(out_file, delimiter=',')
        csv_writer.writerow(write_values)
        
with open(in_csv, mode='r') as in_file:
    csv_reader = csv.reader(in_file, delimiter=',')
    #skip header row
    next(csv_reader)
    
    previous_row = [0,0,0,0,0,0,0,0,0,0,0]
    
    for row in csv_reader:
        #row[0] = id
        #row[8] = vote count
        
        #if both rows have same ID, compare and write higher values
        if row[0] == previous_row[0]:
            if row[10] > previous_row[10]:
                appendValues(row)
            else:
                appendValues(previous_row)
                
            #reset previous_row
            previous_row = [0,0,0,0,0,0,0,0,0,0,0]
        
        # if previous_row is empty, write values to previous_row
        elif previous_row == [0,0,0,0,0,0,0,0,0,0,0]:
            previous_row = row
        
        #if previous row is not empty but does not have same ID:
        #write previous row to CSV, then overwrite with new row 
        #if row[0] != previous_row[0] and previous_row != [0,0,0,0,0,0,0,0,0,0]) 
        else:
            appendValues(previous_row)
            previous_row = row
            
            
  