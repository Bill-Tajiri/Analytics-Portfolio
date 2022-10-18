# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import requests as requests 
import datetime as dt


#To Create A Template For The URL To Be Used In A Function
template = 'https://www.simplyhired.ca/search?q={}&l={}'


#To Create A Function That Generates A URL From Position And Location
def get_url(position, location):
    template = 'https://www.simplyhired.ca/search?q={}&l={}'
    url = template.format(position, location)
    return url

url = get_url('data analyst', 'Calgary, AB')


#To Extract The Raw HTML From SimplyHired
headers = {"User-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:105.0) Gecko/20100101 Firefox/105.0"}
"""This defines to the website from where the URL will be accessed from. 
Headers for a particular machine can be found at: httpbin.org/get"""

response = requests.get(url, headers=headers)
response.reason
"""Confirms the operation was successful"""


#To Use BeautifulSoup To Parse The Results For All Related Postings
soup = BeautifulSoup(response.text, 'html.parser')
cards = soup.find_all('div', 'SerpJob-jobCard card')
len(cards)


#To Create A Model Of The Desired Output Using A Single Entry
card = cards[0]
"""The entry to be modeled"""

atag = card.h3.a
print(atag)
job_title = atag.get('aria-label')

job_url = 'https://www.simplyhired.ca' + atag.get('href')

location = card.find('span', {'class': 'jobposting-location'}).text.strip()

company = card.find('span', {'class': 'JobPosting-labelWithIcon jobposting-company'}).text.strip()

job_summary = card.find('p', {'class': 'jobposting-snippet'}).text.strip()

post_date = card.find('span', {'class': 'SerpJob-timestamp'}).text

current_date = dt.date.today().strftime('%y-%m-%d')


#To Generalize The Model With A Function
def get_record(card):
    """Exctract job data from a single card"""
    atag = card.h3.a
    job_title = atag.get('aria-label')
    company = card.find('span', {'class': 'JobPosting-labelWithIcon jobposting-company'}).text.strip()
    job_url = 'https://www.simplyhired.ca' + atag.get('href')
    location = card.find('span', {'class': 'jobposting-location'}).text.strip()
    job_summary = card.find('p', {'class': 'jobposting-snippet'}).text.strip()
    post_date = card.find('span', {'class': 'SerpJob-timestamp'}).text
    current_date = dt.date.today().strftime('%y-%m-%d')
    
    record = (job_title, job_url, location, company, job_summary, post_date, current_date)
    return record

records = []

for card in cards:
    record = get_record(card)
    records.append(record)
    

#To Get To The Next Page Of Results
soup.find('a', {'class': 'Pagination-link next-pagination'}).get('href')
print(soup.find('a', {'class': 'Pagination-link next-pagination'}))
url = 'https://www.simplyhired.ca' + soup.find('a', {'class': 'Pagination-link next-pagination'}).get('href')
"""NA if using the 24 hour job filter. Not enough postings for multiple pages"""


#To Create A While Loop That Will Cycle Though The Pages Until It Reaches The End
while True:
    try: 
        url = 'https://www.simplyhired.ca' + soup.find('a', {'class': 'Pagination-link next-pagination'}).get('href')
    except AttributeError:
        break
    
    response =requests.get(url)
    soup = BeautifulSoup(response.text, 'html.parser')
    cards = soup.find_all('div', 'SerpJob-jobCard card')
    
    for card in cards:
        record = get_record(card)
        records.append(record)
    
len(records)




#Combine Everything Into One Place For Easy Use --Final Product--   
from bs4 import BeautifulSoup
import requests as requests 
import datetime as dt
import csv
import time
import pandas as pd 

   

def get_url(position, location):
    template = 'https://www.simplyhired.ca/search?q={}&l={}'
    url = template.format(position, location)
    return url


def get_record(card):
    """Exctract job data from a single card"""
    atag = card.h3.a
    job_title = atag.get('aria-label')
    company = card.find('span', {'class': 'JobPosting-labelWithIcon jobposting-company'}).text.strip()
    job_url = 'https://www.simplyhired.ca' + atag.get('href')
    location = card.find('span', {'class': 'jobposting-location'}).text.strip()
    job_summary = card.find('p', {'class': 'jobposting-snippet'}).text.strip()
    post_date = card.find('span', {'class': 'SerpJob-timestamp'}).text
    current_date = dt.date.today().strftime('%y-%m-%d')
    record = (job_title, job_url, location, company, job_summary, post_date, current_date)
    return record


def main(position, location):
    """Run the main program routine"""
    records = []
    url = get_url(position, location)
    
    while True:
        response =requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        cards = soup.find_all('div', 'SerpJob-jobCard card')
        
        for card in cards:
            record = get_record(card)
            records.append(record)
            
        try: 
            url = 'https://www.simplyhired.ca' + soup.find('a', {'class': 'Pagination-link next-pagination'}).get('href')
        except AttributeError:
            break
    
    #To Save The Job Data
    with open('SimplyHired_Scraped_Data.csv', 'w', newline='', encoding='utf-8') as f:
        writer=csv.writer(f)
        writer.writerow(['Job_Title', 'Job_Url', 'Location', 'Company', 'Job_Summary', 'Days_Since_Post', 'Current_Date'])        
        writer.writerows(records)



#Run The Main Program
while(True):
    main('Data Analyst', 'Calgary')
    time.sleep(43200)
"""This automatically generates a new list of jobs every day"""



#Script To Clean The CSV
raw_csv = pd.read_csv('SimplyHired_Scraped_Data.csv')

raw_csv.describe()
raw_csv.drop_duplicates(inplace=True)
"""Drop duplicate rows"""


raw_csv.dtypes
raw_csv['Job_Title'] = raw_csv['Job_Title'].astype("string")
raw_csv['Job_Title'] = raw_csv['Job_Title'].str.replace('Full description:', " ").str.strip()
"""Clean Job_Title column to only show the job title in a string"""


raw_csv.isnull().sum()
raw_csv.fillna('Nodate', inplace=True)
"""Only missing values in the dataframe are those in the Days_Since_Post Column"""


#Summary of Cleaning
"""Dataframe has:
    No Missing Values
    No Duplicates
    Cleaned Job Titles
"""


