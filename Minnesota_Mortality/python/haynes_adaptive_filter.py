# -*- coding: utf-8 -*-
"""
For turning haynes_expected_query.sql into something easily altered
Created on Tue Jul 30 16:12:20 2019

@author: luick006 / dhaynes

Restructuring this into a class. There is too much circular repetive logic

"""
from collections import OrderedDict





class mortality(object):
    # assuming that synthetic_population and people have been made into a stand-alone table called people 
    # actually it is called synth_people

    
    def __init__(self, tableName, lowerAge, upperAge, listofYears, geography, popThreshold=50, ):
        """
        This initiates the class keep it short
        """
        self.resultingTableName = tableName
        self.lowerAge = lowerAge
        self.upperAge = upperAge
        self.ageCategories = self.build_ages(self.lowerAge, self.upperAge)
        self.numOfGroups = len(self.ageCategories)
        self.years = listofYears
        #hard coded for the moment
        if geography == 'tract':
            self.geog = "tract"
            self.geogTable = "mn_census_tracts"
            self.geogJoinField = "gid"
        elif geography == 'zcta':
            self.geog = "zcta"
            self.geogTable = "mn_zcta_wgs84"
            self.geogJoinField = "zcta_id"
        
        #This should be a default
        self.theGridTable = "grid_5000"
        self.gridLimit = 0
        self.popThreshold = popThreshold
        
        #logic for getting under5 Doesn't work if the youngest age is above under5
        #self.under5 = [True for k in  self.ageCategories if k['lower'] == 'under5' ][0]
        
        self.youngestAge = min([ k['minAge'] for k in self.ageCategories] )
        self.oldestAge = max([ k['maxAge'] for k in self.ageCategories] )
    
    
    def CreateSQLStatements(self, pretty_print=False):
        """
        Storing all of the sql here
        """
        self.sql_drop_table = self.Drop_table(self.resultingTableName)
        self.sql_create_table = self.Create_table(self.resultingTableName)
        self.sql_base_pop = self.Create_base_population(self.ageCategories, pretty_print)
        self.sql_death = self.deaths(pretty_print)
        self.sql_death_pivot = self.death_pivot(pretty_print)
        self.sql_est_population = self.estimated_population_by_year(pretty_print)
        self.sql_death_rates = self.death_rates(pretty_print)
        self.sql_expected_death_rates = self.expected_deaths(pretty_print)
        self.sql_person_deaths = self.person_deaths(pretty_print)
        self.sql_geog_deaths = self.geog_unit_deaths("{}_id".format(self.geog), pretty_print)
        self.sql_centroid_population = self.centroid_population_deaths("{}_id".format(self.geog), self.geogTable, self.geogJoinField, pretty_print)
        
        
        #New age adjusted functions
        self.sql_age_adjusted_death = self.age_adjusted_death(pretty_print)
        self.sql_age_year_death_rate = self.age_year_death_rate(pretty_print)
        self.sql_person_year_deaths = self.person_death_rates(pretty_print)
        
    
        self.sql_grid_definition = self.define_grid(self.theGridTable, self.gridLimit, pretty_print )
        self.sql_grid_person_cross_join = self.grid_person_cross_join(pretty_print)
        
        self.sql_grid_people = self.grid_people(pretty_print)
        self.sql_buffer_definition = self.buffer_definition(self.popThreshold,pretty_print )
        
        self.sql_filter_expected = self.filter_expected(pretty_print)
        self.sql_observed_calc = self.observed(pretty_print)
        self.sql_filter_observed = self.filter_observed(pretty_print)
        self.sql_spatial_query = self.spatial_filter_query(pretty_print)
        
        self.CreateSQLOut()
    
    def CreateSQLOut(self):
        """
        """
        
        self.sql_tuples = (self.sql_drop_table, self.sql_create_table, self.sql_base_pop, self.sql_death, self.sql_death_pivot,\
                           self.sql_est_population, self.sql_death_rates, self.sql_expected_death_rates,\
                           self.sql_person_deaths, self.sql_geog_deaths, self.sql_centroid_population,\
                           self.sql_grid_definition, self.sql_grid_person_cross_join, self.sql_grid_people,\
                           self.sql_buffer_definition, self.sql_filter_expected, self.sql_observed_calc, \
                           self.sql_filter_observed, self.sql_spatial_query)
        
        self.sql_age_year = (self.sql_drop_table, self.sql_create_table, self.sql_base_pop, self.sql_age_adjusted_death, self.sql_age_year_death_rate,\
                           self.sql_person_year_deaths, self.sql_person_deaths, self.sql_geog_deaths, self.sql_centroid_population,\
                           self.sql_grid_definition, self.sql_grid_person_cross_join, self.sql_grid_people,\
                           self.sql_buffer_definition, self.sql_filter_expected, self.sql_observed_calc, \
                           self.sql_filter_observed, self.sql_spatial_query)
    
    def PrintAllSQL(self, sqlList, pretty_print=False):
        """
        """
        self.CreateSQLStatements(pretty_print)
        
        for i in (sqlList):
            print(i)
            
            
    def WriteSQLtoFile(self, sqlList, outFilePath):
        """
        Doc string
        """
        
        with open(outFilePath, "w", newline="\n") as fout:
            for i in sqlList:
                fout.write(i)
                
    
    def get_age_categories(self, lowerAge, upperAge):
        """
        [('5', '9'), ('10', '14'), ('15', '19')]
        [('20', '24'), ('25', '29'), ('30', '34'), ('35', '39')]
        [('40', '44'), ('45', '49'), ('50', '54'), ('55', '59')]
        [('60', '64'), ('65', '69'), ('70', '74'), ('75', '79'), ('80', '84'), ('85andover', 'NA')]
        [('total_pop', 'NA')]
        """
    
        myAgeRanges = OrderedDict([(i, j) for i,j in enumerate(range(0, 85, 5))] )
        if isinstance(lowerAge, int) and isinstance(upperAge, int):
            if lowerAge < upperAge:
                for k in myAgeRanges:
                    #This logic pops you up an age category if you choose something in the middle
                    if lowerAge <= myAgeRanges[k]:
                        return myAgeRanges[k]
            else:
                print("**********ERROR*****, lower age is greater than upper age")
                
#        elif lowerAge == 'under5' and isinstance(upperAge, int):
#            if upperAge <= 4:
#                return 0
#            else:
#                
#        elif upperAge == '85over' and isinstance(lowerAge, int):
#            if lowerAge < 85:
#                return self.get_age_categories(lowerAge,85)
#            else:
#                return 0
#        elif lowerAge == 'under5' and upperAge =='85over':
##            print("Found it!!")
#            return self.get_age_categories(5,85)
        
            
            


    def build_ages(self, lowerAge, upperAge):
        """
        if age includes 85andover, just have an upper bound over 85
        
        returns list of dictionaries (no longer list of tuples) such as:
        [("under5", 'NA')]
        [('5', '9'), ('10', '14'), ('15', '19')]
        [('20', '24'), ('25', '29'), ('30', '34'), ('35', '39')]
        [('40', '44'), ('45', '49'), ('50', '54'), ('55', '59')]
        [('60', '64'), ('65', '69'), ('70', '74'), ('75', '79'), ('80', '84'), ('85andover', 'NA')]
        [('total_pop', 'NA')]
        
        """
        
    
        
        #Checking that upper is > than lower
        #Standardizing on the 5 year categories       
        age_list = []
        count = self.get_age_categories(lowerAge, upperAge)        
        
        #this is a hacky way to get around the all mortality.
        if lowerAge == 'under5' and upperAge == '85over':
            age_list = [{'lower': 'under5', 'upper': 'NA', 'minAge': 0, 'maxAge': 4, 'ageGrouping': 'under5' }]
            for age in range(5,85,5):
                age_list.append({'lower': age, 'upper':age + 4, 'minAge': age, 'maxAge': age+4, 'ageGrouping': '{}_{}'.format(age, age+4)})
            
            age_list.append({'lower':'85andover', 'upper':'NA', 'minAge': 85, 'maxAge': 99, 'ageGrouping': '85andover'})
            return age_list    
        
        elif isinstance(lowerAge, int) and upperAge == '85over':
            for age in range(lowerAge,85,5):
                age_list.append({'lower': age, 'upper':age + 4, 'minAge': age, 'maxAge': age+4 , 'ageGrouping': '{}_{}'.format(age, age+4)})
            age_list.append({'lower':'85andover', 'upper':'NA', 'minAge': 85, 'maxAge': 99, 'ageGrouping': '85andover'})
            return age_list
        elif isinstance(upperAge, int) and lowerAge == 'under5':
            print("HERE!!!")
            age_list = [{'lower': 'under5', 'upper': 'NA', 'minAge': 0, 'maxAge': 4, 'ageGrouping': 'under5' }]
            for age in range(5,upperAge,5):
                    age_list.append({'lower': age, 'upper':age + 4, 'minAge': age, 'maxAge': age+4, 'ageGrouping': '{}_{}'.format(age, age+4)})
            return age_list
        elif isinstance(upperAge, int) and isinstance(lowerAge, int):
            for age in range(lowerAge,upperAge,5):
                    age_list.append({'lower': age, 'upper':age + 4, 'minAge': age, 'maxAge': age+4, 'ageGrouping': '{}_{}'.format(age, age+4)})
            return age_list
        
#        if upperAge == '85over': 
#            upperAge = 90
#        
#    
#        #print(count, lowerAge, upperAge)
#        #count = lowerAge
#        
#        while count < upperAge:
#            if count == 0 and lowerAge == 'under5':                 # if includes under 5
#                age_list.append({'lower': 'under5', 'upper': 'NA', 'minAge': 0, 'maxAge': 4, 'ageGrouping': 'under5'})
#                return age_list
#            if count == 0 and upperAge  == 90:              # if includes 85andover
#                age_list.append({'lower':'85andover', 'upper':'NA', 'minAge': 85, 'maxAge': 99, 'ageGrouping': '85andover'})
##                print("HERE 85")
#                return age_list            # makes sure age_list doesn't go over 85
#            else:
#                age_list.append({'lower': count, 'upper':count + 4, 'minAge': count, 'maxAge': count+4, 'ageGrouping': '{}_{}'.format(count, count+4) })
#            
#            #Count is the lower bounding value
#            count = count + 5
#        
#            return age_list

    def Print_pretty_sql(self, sqlList,):
        """
        Funtion to make pretty print sql
        """
        return " \n".join(sqlList)

    def print_statements(self, sqlListStatements, prettyPrint):
        """
        
        """
        if prettyPrint:
            return self.Print_pretty_sql(sqlListStatements)
        else:
            return " ".join(sqlListStatements)
        
    def Create_table(self, tableName):
        """
        Doc string
        CREATE TABLE mytable AS
        """
        
        return "CREATE TABLE {} AS \n".format(tableName)
    
    def Drop_table(self, tableName):
        """
        
        """
        return "DROP TABLE IF EXISTS {};".format(tableName)

    def Create_base_population(self, ages, prettyPrint=True):
        """
        What does this do?
        """
        bp_list = []
        bp_list.append('WITH base_population as')
        bp_list.append('(')
        bp_list.append('SELECT')
        
        # all the summing, nested for loop
        count = 0
        for i in ages:
            
            if i['upper'] == 'NA':
                age_section = i['lower']
            elif i['lower'] == 0:
                age_section = "under5"
            elif i['upper'] == '85andover':
                age_section = '85andover'                    
            else:
                age_section = "%s_%s" % (i['lower'], i['upper'])
            #This is using the zipped list of list
#            for j in [['a', '2011'], ['b','2012'], ['c','2013'], ['d','2014'], ['e','2015']]:
            for c,j in enumerate(self.years):
            
                #This is complex you get the line with a comma unless you are the last item.
                if count < ((len(ages) * len(self.years)) -1):
                    line = " SUM(t%s.total_%s) as est_pop_%s_year_%s," % (c+1, age_section, age_section, j)
                else:
                    line = " SUM(t%s.total_%s) as est_pop_%s_year_%s" % (c+1, age_section, age_section, j) # no comma for last line
                bp_list.append(line)
                count = count + 1
        
        for c,j in enumerate(self.years):
            if c == 0: 
                bp_list.append('FROM zcta_age_sex_%s as t%s' % (j, c+1))
                originalTable = c+1
            else:
                bp_list.append(' INNER JOIN zcta_age_sex_%s as t%s ON t%s.zcta = t%s.zcta' % (j, c+1, originalTable, c+1) )
                
        bp_list.append(')')
        

        return self.print_statements(bp_list, prettyPrint)        



    def deaths(self, prettyPrint=True):
        """
        Get the death records
        """
        d_list = []
        d_list.append(', deaths as')
        d_list.append('(')
        d_list.append('SELECT decd_dth_yr as yr, COUNT(1) as num_deaths')
        d_list.append('FROM disparities.decd')
                   
        d_list.append("WHERE decd_age_yr >= %s" % (self.youngestAge))
        d_list.append("AND decd_age_yr <= %s" % (self.oldestAge))       
        d_list.append('GROUP BY decd_dth_yr')
        d_list.append(')')

        return self.print_statements(d_list, prettyPrint)        


    def death_pivot(self, prettyPrint=True):
        """
        Function creats a pivot table 
        Must have tablefun extension installed on postgresql
        
        select *
        from crosstab(
        'with deaths as
        (
        SELECT 1::numeric as for_pivot, decd_dth_yr as yr, COUNT(1) as num_deaths
        FROM disparities.decd
        WHERE decd_age_yr >= 5
        AND decd_age_yr <= 15
        GROUP BY decd_dth_yr
        )
        select 1 as placeholder, yr, num_deaths 
        	from deaths')
        as (placeholder integer, deaths_2011 bigint, deaths_2012 bigint, deaths_2013 bigint, deaths_2014 bigint, deaths_2015 bigint)
        """
        
        dplist = []
        dplist.append(", total_deaths as")
        dplist.append("( ")
        dplist.append("SELECT *")
        dplist.append("FROM crosstab( ")
        dplist.append("'with deaths as")
        dplist.append("(")
        dplist.append("SELECT 1::numeric as for_pivot, decd_dth_yr as yr, COUNT(1) as num_deaths")
        dplist.append("FROM disparities.decd")
        dplist.append("WHERE decd_age_yr >= %s" % (self.youngestAge))
        dplist.append("AND decd_age_yr <= %s" % (self.oldestAge))
        dplist.append("GROUP BY decd_dth_yr")
        dplist.append(")")
        dplist.append("SELECT 1 placeholder, yr, num_deaths")
        dplist.append("FROM deaths') ")
        dplist.append("as (placeholder integer, deaths_2011 bigint, deaths_2012 bigint, deaths_2013 bigint, deaths_2014 bigint, deaths_2015 bigint)")
        dplist.append(")")

        return self.print_statements(dplist, prettyPrint)

    def age_adjusted_death(self, prettyPrint=True):
        """
        This is the age adjusted death groups
        ,death_age_pop as
        (
        SELECT * FROM crosstab($$ 
            with death_records as
            (
            SELECT 1 as place_holder, decd_dth_yr as yr,
                CASE 
                WHEN decd_age_yr >= 0 AND decd_age_yr <= 4 THEN 0
                WHEN decd_age_yr >= 5 AND decd_age_yr <= 9  THEN 5
                END
                as age_category
            FROM disparities.decd 
            WHERE decd_age_yr >= 0 AND decd_age_yr <= 9
            )
            SELECT 1 as rec_id, concat(age_category,'_',yr) as category, count(1)
            FROM death_records
            GROUP BY yr, age_category
        	ORDER BY yr, age_category
            $$) 
        AS piv_results(rec_id int, deaths_1 bigint, deaths_2 bigint, deaths_3 bigint, deaths_4 bigint, deaths_5 bigint, deaths_6 bigint, deaths_7 bigint, deaths_8 bigint, deaths_9 bigint, deaths_10 bigint)
        )        
        """
        
        dplist = []
        dplist.append(", death_age_pop as")
        dplist.append("(")
        dplist.append("SELECT * FROM crosstab($$ ")
        dplist.append("with death_records as")
        dplist.append("(")
        dplist.append("SELECT 1 as place_holder, decd_dth_yr as yr,")
        dplist.append("CASE")
        
            
        for a in self.ageCategories:
            dplist.append( "WHEN decd_age_yr >= {} AND decd_age_yr <= {} THEN {} ".format(a['minAge'], a['maxAge'], a['minAge'] ) )
        
        dplist.append("END as age_category")
        dplist.append("FROM disparities.decd")
        dplist.append("WHERE decd_age_yr >= {} AND decd_age_yr <= {}".format(self.youngestAge, self.oldestAge))
        dplist.append(")")
        dplist.append("SELECT 1 as rec_id, concat(age_category,'_',yr) as category, count(1)")
        dplist.append("FROM death_records")
        dplist.append("GROUP BY yr, age_category")
        dplist.append("ORDER BY yr, age_category")
        dplist.append("$$)")
        dplist.append("AS piv_results ( rec_id int,")
        
        for t, y in enumerate(self.years):
            for c, a in enumerate(self.ageCategories):
                if c+t == 0:
                    dplist.append( "deaths_{}_{} bigint".format(a["ageGrouping"], y) )
                else:
                    dplist.append( ", deaths_{}_{} bigint".format(a["ageGrouping"], y) )   
        #Closing Pivot
        dplist.append(")")
        #Closing the CTE
        dplist.append(")")

        return self.print_statements(dplist, prettyPrint)
  
    
    def age_year_death_rate(self, prettyPrint=True):
        """

        
        """
        
        dplist = []
        dplist.append(",age_year_death_rate as")
        dplist.append("(")
        dplist.append("SELECT ")
        for t, y in enumerate(self.years):
            for c, a in enumerate(self.ageCategories):
                if t+c == 0:
                    dplist.append( "deaths_{}_{} / est_pop_{}_year_{} as death_rate_{}_{}".format(a["ageGrouping"], y, a["ageGrouping"], y, a["ageGrouping"], y) )
                else:
                    dplist.append( ", deaths_{}_{} / est_pop_{}_year_{} as death_rate_{}_{}".format(a["ageGrouping"], y, a["ageGrouping"], y, a["ageGrouping"], y) )   
        dplist.append("FROM death_age_pop, base_population")
        dplist.append(")")

        return self.print_statements(dplist, prettyPrint)


    def estimated_population_by_year(self, prettyPrint):
        """
        
        """
        
        est_pop = []
        est_pop.append(",total_pop as ")
        est_pop.append("( ")
        est_pop.append("SELECT ")
        for c, y in enumerate(self.years):
            statements =  [ "est_pop_%s_year_%s" % (age['lower'], y) if age['lower'] == 'under5' or age['lower'] == '85andover' else "est_pop_%s_%s_year_%s" % (age['minAge'], age['maxAge'], y) for age in self.ageCategories ]     
            if c == 0:
                est_pop.append("SUM(%s) as est_pop_%s" % (" + ".join(statements), y ))   
            else:
                est_pop.append(", SUM(%s) as est_pop_%s" % (" + ".join(statements), y ))   
        est_pop.append("FROM base_population")
        est_pop.append(")")
        
        return self.print_statements(est_pop, prettyPrint)
            
        
    
    def death_rates(self, prettyPrint):
        """
        SELECT 
          deaths_2011/est_pop_5_9_year_2011 as expected_death_rate_5_9_2011, 
          deaths_2012/est_pop_5_9_year_2012 as expected_death_rate_5_9_2012,
          deaths_2013/est_pop_5_9_year_2013 as expected_death_rate_5_9_2013,
          deaths_2014/est_pop_5_9_year_2014 as expected_death_rate_5_9_2014,
          deaths_2015/est_pop_5_9_year_2015 as expected_death_rate_5_9_2015
          FROM total_pop, total_deaths
        """
        
        death_rate = []
        death_rate.append(", death_rates as")
        death_rate.append("(")
        death_rate.append("SELECT ")
        for c, y in enumerate(self.years):
            if c == 0:
                death_rate.append("deaths_%s/est_pop_%s as expected_death_rate_%s" % (y,y,y))
            else:
                death_rate.append(", deaths_%s/est_pop_%s as expected_death_rate_%s" % (y,y,y))
        death_rate.append("FROM total_pop, total_deaths")
        death_rate.append(")")
        
        
        return self.print_statements(death_rate, prettyPrint)
        
            

    def expected_deaths(self, prettyPrint, raceValue=False):
        """
        expected_deaths as
        (
        SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race,
        p.value * expected_death_rate_5_9_2011 as num_deaths_2011,  --################################################################################
        p.value * expected_death_rate_5_9_2012 as num_deaths_2012,
        p.value * expected_death_rate_5_9_2013 as num_deaths_2013,
        p.value * expected_death_rate_5_9_2014 as num_deaths_2014,
        p.value * expected_death_rate_5_9_2015 as num_deaths_2015
        FROM death_rates, synth_people p
        )
        """
        
        num_deaths = []
        num_deaths.append(", expected_deaths as")
        num_deaths.append("(")
        num_deaths.append("SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race")
        for y in self.years:
            num_deaths.append(", p.value * expected_death_rate_%s as num_deaths_%s" % (y,y))
        
        num_deaths.append("FROM death_rates, synth_people p ")
        num_deaths.append("WHERE p.age >= %s" % (self.youngestAge))
        num_deaths.append("AND p.age <= %s" % (self.oldestAge))      
        if raceValue:
            num_deaths.append("AND p.race IN ({})".format(",".join(raceValue))  )
        num_deaths.append(")")
        
        return self.print_statements(num_deaths, prettyPrint)


    def person_death_rates(self, prettyPrint):
        """
        SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race, 
        CASE 
        WHEN p.age >= 0 AND p.age <= 4 THEN 1 * death_rate_under5_2011  
        WHEN p.age >= 5 AND p.age <= 9 THEN 1 * death_rate_5_9_2011  
        WHEN p.age >= 10 AND p.age <= 14 THEN 1 * death_rate_10_14_2011  
        WHEN p.age >= 15 AND p.age <= 19 THEN 1 * death_rate_15_19_2011  
        WHEN p.age >= 20 AND p.age <= 24 THEN 1 * death_rate_20_24_2011  
        WHEN p.age >= 25 AND p.age <= 29 THEN 1 * death_rate_25_29_2011  
        WHEN p.age >= 30 AND p.age <= 34 THEN 1 * death_rate_30_34_2011  
        WHEN p.age >= 35 AND p.age <= 39 THEN 1 * death_rate_35_39_2011  
        WHEN p.age >= 40 AND p.age <= 44 THEN 1 * death_rate_40_44_2011  
        WHEN p.age >= 45 AND p.age <= 49 THEN 1 * death_rate_45_49_2011  
        WHEN p.age >= 50 AND p.age <= 54 THEN 1 * death_rate_50_54_2011  
        WHEN p.age >= 55 AND p.age <= 59 THEN 1 * death_rate_55_59_2011  
        WHEN p.age >= 60 AND p.age <= 64 THEN 1 * death_rate_60_64_2011  
        WHEN p.age >= 65 AND p.age <= 69 THEN 1 * death_rate_65_69_2011  
        WHEN p.age >= 70 AND p.age <= 74 THEN 1 * death_rate_70_74_2011  
        WHEN p.age >= 75 AND p.age <= 79 THEN 1 * death_rate_75_79_2011  
        WHEN p.age >= 80 AND p.age <= 84 THEN 1 * death_rate_80_84_2011  
        WHEN p.age >= 85 AND p.age <= 99 THEN 1 * death_rate_85andover_2011 
        END as rate2011 
        FROM death_rates, synth_people p  
        WHERE p.age >= 0 
        AND p.age <= 99 
        """
        num_deaths = []
        num_deaths.append(", expected_deaths as")
        num_deaths.append("(")
        num_deaths.append("SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race, ")
        for c, y in enumerate(self.years):
            if c == 0 :
                num_deaths.append("CASE")
            else:
                num_deaths.append(",\nCASE")
            for a in self.ageCategories:
                num_deaths.append( "WHEN p.age >= {} AND p.age <= {} THEN 1 * death_rate_{}_{} ".format(a['minAge'], a['maxAge'], a['ageGrouping'], y ) )
            
            num_deaths.append("END as num_deaths_{}".format(y))
        
        num_deaths.append("FROM age_year_death_rate, synth_people p ")
        num_deaths.append("WHERE p.age >= %s" % (self.youngestAge))
        num_deaths.append("AND p.age <= %s" % (self.oldestAge))    
            
        num_deaths.append(")")
        
        return self.print_statements(num_deaths, prettyPrint)
        
    def person_deaths(self, prettyPrint):
        """
        person_deaths as
        (
        SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race,
        (p.num_deaths_2011 + p.num_deaths_2012 + p.num_deaths_2013 + p.num_deaths_2014 + p.num_deaths_2015) as total_deaths
        FROM expected_deaths p
        )
        """
        
        person_deaths = []
        person_deaths.append(", person_deaths as")
        person_deaths.append("(")
        person_deaths.append("SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race ")
        #List comprehension to generate the sql
        yearsList = ["num_deaths_%s" % (y) for y in self.years ]
        person_deaths.append( ",( %s ) as total_deaths " % (" + ".join(yearsList)) )
        person_deaths.append("FROM expected_deaths p")
        person_deaths.append(")")
        
            
        return self.print_statements(person_deaths, prettyPrint)

    def geog_unit_deaths(self, geogUnit, prettyPrint):
        """
        geog_unit_deaths as
        (
        SELECT tract_id, sum(total_deaths) as total_deaths
        FROM person_deaths
        GROUP BY tract_id
        ),
        """
        
        geog_agg = []
        geog_agg.append(", geog_unit_deaths as")
        geog_agg.append("(")
        geog_agg.append("SELECT {}, sum(total_deaths) as total_deaths ".format(geogUnit))
        geog_agg.append("FROM person_deaths")
        geog_agg.append("GROUP BY {}".format(geogUnit))
        geog_agg.append(")")
        
        return self.print_statements(geog_agg, prettyPrint)
        
    def centroid_population_deaths(self, geogUnit, geogTable, geogJoinField, prettyPrint):
        """
        the_population as
        (
        SELECT g.tract_id,  ST_Centroid(t.geom) as geom, g.total_deaths
        FROM geog_unit_deaths g 
        INNER JOIN mn_census_tracts t ON (g.tract_id = t.gid)
        ), 
        """
        
        geog_centroid_deaths = []
        geog_centroid_deaths.append(", the_population as")
        geog_centroid_deaths.append("(")
        geog_centroid_deaths.append("SELECT g.{} as geog_id,  ST_Centroid(t.geom) as geom, g.total_deaths".format(geogUnit))
        geog_centroid_deaths.append("FROM geog_unit_deaths g")
        geog_centroid_deaths.append("INNER JOIN {} t ON (g.{} = t.{})".format(geogTable, geogUnit, geogJoinField))
        geog_centroid_deaths.append(")")
        
        return self.print_statements(geog_centroid_deaths, prettyPrint)

    def define_grid(self, gridTable, limitRecords, prettyPrint): 
        """
        grid as
        (
        SELECT g.gid, geom
        FROM grid_5000 g
        --LIMIT 200  ---------------------- limit is only for testing, to get results quick. If used in final, would only do NW corner of state or some such
        ), 
        """


        grid_sql = []
        grid_sql.append(", grid as")
        grid_sql.append("(")
        grid_sql.append("SELECT g.gid, geom")
        grid_sql.append("FROM {} g".format(gridTable))
        
        if limitRecords: grid_sql.append("LIMIT {}".format(limitRecords))
        
        grid_sql.append(")")
        
        return self.print_statements(grid_sql, prettyPrint)

    def grid_person_cross_join(self, prettyPrint):
        """
        grid_person_join as
        (
        SELECT gid, g.geom, tp.tract_id, ST_Distance(g.geom, ST_Transform(tp.geom,26915)) as distance, tp.total_deaths
        FROM grid g CROSS JOIN the_population tp
        ),
        """
        
        grid_person = []
        grid_person.append(", grid_person_join as")
        grid_person.append("(")
        grid_person.append("SELECT gid, g.geom, tp.geog_id, ST_Distance(g.geom, ST_Transform(tp.geom,26915)) as distance, tp.total_deaths")
        grid_person.append("FROM grid g CROSS JOIN the_population tp")
        grid_person.append(")")
        
        return self.print_statements(grid_person, prettyPrint)

    def grid_people(self,prettyPrint):
        """
        grid_people as
        (
        SELECT gid, geom, distance, sum(total_deaths) OVER w as total_deaths
        FROM grid_person_join
        WINDOW w AS (PARTITION BY gid, geom ORDER BY distance ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
        ), 
        """
        
        grid_people = []
        grid_people.append(", grid_people as")
        grid_people.append("(")
        grid_people.append("SELECT gid, geom, distance, sum(total_deaths) OVER w as total_deaths")
        grid_people.append("FROM grid_person_join")
        grid_people.append("WINDOW w AS (PARTITION BY gid, geom ORDER BY distance ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )")
        grid_people.append(")")

        return self.print_statements(grid_people, prettyPrint)
    
    
    def buffer_definition(self, populationThreshold, prettyPrint): # should there be an input for total_deaths?
        """
        buffer_definition as
        (
        SELECT gid, geom, min(distance) as min_buffer_distance
        FROM grid_people
        WHERE total_deaths >= 50 ------------------------------------------------------- For having 50 deaths in each buffer
        GROUP BY gid, geom
        ),
        """
        
        buffer_definition = []
        buffer_definition.append(", buffer_definition as")
        buffer_definition.append("(")
        buffer_definition.append("SELECT gid, geom, min(distance) as min_buffer_distance")
        buffer_definition.append("FROM grid_people")
        buffer_definition.append("WHERE total_deaths >= {}".format(populationThreshold))
        buffer_definition.append("GROUP BY gid, geom")
        buffer_definition.append(")")
        
        return self.print_statements(buffer_definition, prettyPrint)
    

    def filter_expected(self, prettyPrint):
        """
        filter_expected as
        (
        SELECT b.gid, b.geom, b.min_buffer_distance, sum(gpj.total_deaths) as expected_deaths
        FROM grid_person_join gpj 
        INNER JOIN buffer_definition b ON gpj.gid = b.gid
        WHERE gpj.distance <= b.min_buffer_distance
        GROUP BY b.gid, b.geom, b.min_buffer_distance
        ),
        """

        filter_calc = []
        filter_calc.append(", filter_expected as")
        filter_calc.append("(")
        filter_calc.append("SELECT b.gid, b.geom, b.min_buffer_distance, sum(gpj.total_deaths) as expected_deaths")
        filter_calc.append("FROM grid_person_join gpj")
        filter_calc.append("INNER JOIN buffer_definition b ON gpj.gid = b.gid")
        filter_calc.append("WHERE gpj.distance <= b.min_buffer_distance")
        filter_calc.append("GROUP BY b.gid, b.geom, b.min_buffer_distance")
        filter_calc.append(")")
        
        return self.print_statements(filter_calc, prettyPrint)

    def observed(self, prettyPrint):
        """
        observed as
        (
        SELECT d.decd_res_zip5 as zip, z.geom, COUNT(1) as observed_deaths
        FROM disparities.decd d 
        LEFT JOIN mn_zcta_wgs84 z ON z.zcta5ce10::integer = d.decd_res_zip5::integer
        WHERE decd_age_yr >= 5 --#####################################################################################################################
        AND decd_age_yr <= 9
        AND d.decd_res_zip5 <> 'NA' -- added because got a lot of NA in 0-4 age range
        GROUP BY zip, z.geom
        ),
        """
        
        observed_calc = []
        observed_calc.append(", observed as")
        observed_calc.append("(")
        observed_calc.append("SELECT d.decd_res_zip5 as zip, z.geom, COUNT(1) as observed_deaths")
        observed_calc.append("FROM disparities.decd d ")
        observed_calc.append("INNER JOIN mn_zcta_wgs84 z ON z.zcta5ce10::integer = d.decd_res_zip5::integer")
        observed_calc.append("WHERE decd_age_yr >= {}".format(self.youngestAge))
        observed_calc.append("AND decd_age_yr <= {}".format(self.oldestAge))
        observed_calc.append("AND d.decd_res_zip5 <> 'NA'")
        observed_calc.append("GROUP BY zip, z.geom")
        observed_calc.append(")")
        
        return self.print_statements(observed_calc, prettyPrint)
    
        
    def filter_observed(self, prettyPrint):
        """
        filter_observed as
        (
        SELECT b.gid, count(o.observed_deaths) as number_of_zctas_used, sum(o.observed_deaths) as observed_deaths
        FROM buffer_definition b
        INNER JOIN observed o on ST_DWithin( b.geom,  ST_Transform(ST_Centroid(o.geom), 26915), b.min_buffer_distance) 
        GROUP BY b.gid, b.geom
        )
        """

        filter_obs = []
        filter_obs.append(", filter_observed as")
        filter_obs.append("(")
        filter_obs.append("SELECT b.gid, count(o.observed_deaths) as number_of_zctas_used, sum(o.observed_deaths) as observed_deaths")
        filter_obs.append("FROM buffer_definition b")
        #### This seems wierd we need an index on this with geom 26915 on the centroids?
        filter_obs.append("LEFT JOIN observed o on ST_DWithin( b.geom,  ST_Transform(ST_Centroid(o.geom), 26915), b.min_buffer_distance)")
        filter_obs.append("GROUP BY b.gid, b.geom")
        filter_obs.append(")")
        
        return self.print_statements(filter_obs, prettyPrint)
        
        
    def spatial_filter_query(self, prettyPrint):
        """
        SELECT e.gid, e.geom, e.min_buffer_distance, e.expected_deaths, o.number_of_zctas_used, o.observed_deaths, o.observed_deaths/e.expected_deaths as ratio
        FROM filter_expected e 
        INNER JOIN filter_observed o ON e.gid=o.gid
        """
        
        spatial_filter = []
        spatial_filter.append("SELECT e.gid, e.geom, e.min_buffer_distance, e.expected_deaths, o.number_of_zctas_used, o.observed_deaths, coalesce(o.observed_deaths,0)/e.expected_deaths as ratio")
        spatial_filter.append("FROM filter_expected e ")
        spatial_filter.append("INNER JOIN filter_observed o ON (e.gid = o.gid)")
    
        return self.print_statements(spatial_filter, prettyPrint)



class mortality_race(mortality):
    
    def __init__(self, tableName, baseRace, comparitiveRace, listofYears, geography, popThreshold=50, minAge="under5", maxAge="85over"):
        """
        """
        #Provide all partent object properties
        super().__init__(tableName, minAge, maxAge, listofYears, geography, popThreshold)
        
        self.baseRace = baseRace
        self.baseRaceValue = ["1"]    
        
        

    def CreateSQLStatements(self, pretty_print=False):
        """
        Storing all of the sql here
        """
        self.sql_drop_table = self.Drop_table(self.resultingTableName)
        self.sql_create_table = self.Create_table(self.resultingTableName)
        
        self.sql_race_base_pop = self.Create_race_base_population(self.baseRace, pretty_print)
        self.sql_race_death_pivot = self.death_race_pivot(pretty_print)
        self.sql_est_race_population = self.estimated_race_population_by_year(pretty_print)
        
        self.sql_death_rates = self.death_rates(pretty_print)
        self.sql_expected_death_rates = self.expected_deaths(pretty_print, self.baseRaceValue)
        self.sql_person_deaths = self.person_deaths(pretty_print)
        self.sql_geog_deaths = self.geog_unit_deaths("{}_id".format(self.geog), pretty_print)
        self.sql_centroid_population = self.centroid_population_deaths("{}_id".format(self.geog), self.geogTable, self.geogJoinField, pretty_print)
        
        
        #New age adjusted functions
#        self.sql_age_adjusted_death = self.age_adjusted_death(pretty_print)
#        self.sql_age_year_death_rate = self.age_year_death_rate(pretty_print)
#        self.sql_person_year_deaths = self.person_death_rates(pretty_print)
        
    
        self.sql_grid_definition = self.define_grid(self.theGridTable, self.gridLimit, pretty_print )
        self.sql_grid_person_cross_join = self.grid_person_cross_join(pretty_print)
        
        self.sql_grid_people = self.grid_people(pretty_print)
        self.sql_buffer_definition = self.buffer_definition(self.popThreshold,pretty_print )
        
        self.sql_filter_expected = self.filter_expected(pretty_print)
        self.sql_observed_calc = self.observed(pretty_print)
        self.sql_filter_observed = self.filter_observed(pretty_print)
        self.sql_spatial_query = self.spatial_filter_query(pretty_print)
        
        self.CreateSQLOut()
    
    def CreateSQLOut(self):
        """
        """
        
#        self.sql_tuples = (self.sql_drop_table, self.sql_create_table, self.sql_base_pop, self.sql_death, self.sql_death_pivot,\
#                           self.sql_est_population, self.sql_death_rates, self.sql_expected_death_rates,\
#                           self.sql_person_deaths, self.sql_geog_deaths, self.sql_centroid_population,\
#                           self.sql_grid_definition, self.sql_grid_person_cross_join, self.sql_grid_people,\
#                           self.sql_buffer_definition, self.sql_filter_expected, self.sql_observed_calc, \
#                           self.sql_filter_observed, self.sql_spatial_query)
#        
#        self.sql_age_year = (self.sql_drop_table, self.sql_create_table, self., self.sql_age_adjusted_death, self.sql_age_year_death_rate,\
#                           self.sql_person_year_deaths, self.sql_person_deaths, self.sql_geog_deaths, self.sql_centroid_population,\
#                           self.sql_grid_definition, self.sql_grid_person_cross_join, self.sql_grid_people,\
#                           self.sql_buffer_definition, self.sql_filter_expected, self.sql_observed_calc, \
#                           self.sql_filter_observed, self.sql_spatial_query)

        self.sql_race = (self.sql_drop_table, self.sql_create_table,\
                         self.sql_race_base_pop, self.sql_race_death_pivot, self.sql_est_race_population, \
                         self.sql_death_rates, self.sql_expected_death_rates,\
                           self.sql_person_deaths, self.sql_geog_deaths, self.sql_centroid_population,\
                           self.sql_grid_definition, self.sql_grid_person_cross_join, self.sql_grid_people,\
                           self.sql_buffer_definition, self.sql_filter_expected, self.sql_observed_calc, \
                           self.sql_filter_observed, self.sql_spatial_query)
    

    def Create_race_base_population(self, baseRaces, prettyPrint=True):
        """
        What does this do?
        SUM(a.white) as est_pop_white_year_2011,
        acs_zcta_race_2012
        """
        bp_list = []
        bp_list.append('WITH base_population as')
        bp_list.append('(')
        bp_list.append('SELECT')
        
        for race in baseRaces:
            for c,j in enumerate(self.years):
                bp_list.append("SUM(t{}.{}) as est_pop_{}_{},".format(c+1, race, race, j))
        
        #remove last comma
        bp_list[len(bp_list)-1] = bp_list[len(bp_list)-1][:-1]
        
        
        bp_list.append('FROM')
        for c,j in enumerate(self.years):
            if c == 0: 
                bp_list.append(' acs_zcta_race_{} as t{}'.format(j, c+1))
                originalTable = c+1
            else:
                bp_list.append(' INNER JOIN acs_zcta_race_{} as t{} ON t{}.zcta = t{}.zcta'.format(j, c+1, originalTable, c+1) )
                
        bp_list.append(')')
        

        return self.print_statements(bp_list, prettyPrint)        
    
    def death_race_pivot(self, prettyPrint=True):
        """
        Function creats a pivot table 
        Must have tablefun extension installed on postgresql
        
        SELECT * 
        FROM crosstab(  
        	'with deaths as ( 
        	SELECT 1::numeric as for_pivot, d.decd_dth_yr as yr, COUNT(1) as num_deaths 
        	FROM disparities.decd as d
        	INNER JOIN disparities.race as r ON d.id = r.id
        	WHERE r.acs_race_id = 1
        	GROUP BY decd_dth_yr ) 
        	SELECT 1 placeholder, yr, num_deaths 
        	FROM deaths')  
        	as (placeholder integer, deaths_2011 bigint, deaths_2012 bigint, deaths_2013 bigint, deaths_2014 bigint, deaths_2015 bigint) 
        """
        
        dplist = []
        dplist.append(", total_deaths as")
        dplist.append("( ")
        dplist.append("SELECT *")
        dplist.append("FROM crosstab( ")
        dplist.append("'with deaths as")
        dplist.append("(")
        dplist.append("SELECT 1::numeric as for_pivot, decd_dth_yr as yr, COUNT(1) as num_deaths")
        dplist.append("FROM disparities.decd d")
        dplist.append("INNER JOIN disparities.race as r ON d.id = r.id")
        dplist.append("WHERE r.acs_race_id IN ({})".format(",".join(self.baseRaceValue) )  )
        dplist.append("GROUP BY decd_dth_yr")
        dplist.append(")")
        dplist.append("SELECT 1 placeholder, yr, num_deaths")
        dplist.append("FROM deaths') ")
        dplist.append("as (placeholder integer")
        
        for t, y in enumerate(self.years):
#            for c, a in enumerate(self.baseRace):
#                if t == 0:
#                    dplist.append( "deaths_{} bigint".format( y) )
#                else:
                    dplist.append( ", deaths_{} bigint".format( y) )
        
        dplist.append(")")
        #closing CTE
        dplist.append(")")
            
        return self.print_statements(dplist, prettyPrint)
    
    def estimated_race_population_by_year(self, prettyPrint):
        """
        
        """
        
        est_pop = []
        est_pop.append(", total_pop as ")
        est_pop.append("( ")
        est_pop.append("SELECT ")
        for c, y in enumerate(self.years):
            
            statements =  [ "est_pop_{}_{}".format(race, y) for race in self.baseRace ]     
            if c == 0:
                est_pop.append("SUM(%s) as est_pop_%s" % (" + ".join(statements), y ))   
            else:
                est_pop.append(", SUM(%s) as est_pop_%s" % (" + ".join(statements), y ))   
        est_pop.append("FROM base_population")
        est_pop.append(")")
        
        return self.print_statements(est_pop, prettyPrint)

    