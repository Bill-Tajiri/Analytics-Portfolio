# -*- coding: utf-8 -*-

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
plt.style.use('ggplot')

movies = pd.read_csv('MoviesData.csv')
sample = movies.sample(100)


#To Find And Delete Missing Data 
movies.isnull().sum()
movies.dropna(how='any', inplace=True)


#To Inspect The Datatypes Of The Columns
movies.dtypes


#To Change The 'Budget' And 'Gross' Columns To 'int64' Datatype
movies['budget'] = movies.budget.astype('int64')
movies['gross'] = movies.gross.astype('int64')


#To Create A New Column With The Correct Year Of Release
movies_date = movies.released.str.split(' ', expand = True)
column_names = ['one', 'two', 'year_correct', 'three', 'four', 'five']
movies_date.columns = column_names
movies['year_correct'] = movies_date.year_correct

del column_names, movies_date
'''These objects are deleted to keep the environment uncluttered after 
adding thr correct date column'''


#To Sort The Values
movies.sort_values('gross', inplace=False, ascending=False)


#To Check For And Drop Any Duplicate Values
movies.drop_duplicates(inplace=True)


#To Create A Scatterplot Of The 'Budget' vs 'Gross' Columns
plt.scatter(x=movies['budget'], y=movies['gross'])
plt.title('Budget vs Gross Earnings')
plt.xlabel('Gross Earnings (Hundreds of Millions USD)')
plt.ylabel('Budget for Film (Hundreds of Millions USD)')
plt.show()


#To Create A Regression Plot To Visualize The Correlation Between Budget And Gross Earnings
sns.regplot(x='budget', y='gross', data=movies, scatter_kws={'color': 'black'}, line_kws={'color':'purple'})


#To Create a Correlation Matrix Showing The Relationships Between Different Values
correlation_matrix = movies.corr(method='spearman')
'''This is a pearson correlation by default (pearson, kendall, spearman)
This only works on numeric values in the dataframe'''


#To Create A Heatmap Using The Correlation Matrix
sns.heatmap(correlation_matrix, annot=True)
plt.title('Correlation Matrix for Numeric Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')


#To Convert All Non-Numeric Values (Such As Company Names) To Integers
movies_sorted = movies.sort_values('gross', ascending = False)
'''This creates a dataframe of sorted values that can be used to confirm the conversion using 
the loop below was successful'''

df_numeric = movies

for col_name in df_numeric.columns:
    if (df_numeric[col_name].dtype == 'object'):
        df_numeric[col_name] = df_numeric[col_name].astype('category')
        df_numeric[col_name] = df_numeric[col_name].cat.codes

'''This for-loop cycles through each column and changes each object datatype into 
a category datatype. The cat.codes part of the loop returns a unique integer for each unique 
value in a column. The result is a dataframe consisting only of integers that can then be 
analyzed in a correlation matrix
'''

#To Sort And Compare The New Dataframe To The Original Data To Confirm The Conversion Was Successful
sorted_numeric_values = df_numeric.sort_values('gross', ascending=False)


#To Create A Correlation Matrix And Heatmap Using The Entire Dataframe
correlation_matrix_full_dataframe = df_numeric.corr(method='pearson')

sns.heatmap(correlation_matrix_full_dataframe, annot=True)
plt.title('Correlation Matrix for All Features')
plt.xlabel('Movie Features')
plt.ylabel('Movie Features')


#To Unstack The Correlation Matrix To Find The Strongest Relationships
correlation_pairs = correlation_matrix_full_dataframe.unstack()
correlation_pairs_sorted = correlation_pairs.sort_values()

high_positive_correlations = correlation_pairs_sorted[(correlation_pairs_sorted > 0.5) & (correlation_pairs_sorted < 1)]
high_negative_correlations = correlation_pairs_sorted[(correlation_pairs_sorted < -0.2) & (correlation_pairs_sorted > -1)]

'''Removed the correlations equal to one, as it was confirmed these values were only present when 
each value was measured against itself'''
