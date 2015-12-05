'''
Created on Dec 5, 2015

This product includes GeoLite2 data created by MaxMind, available from
<a href="http://www.maxmind.com">http://www.maxmind.com</a>.

@author: mdaaaa
'''

import geoip2.database
import socket
import pandas
import sys
import argparse

csv_file = 'csv/top-1m.csv'

try:
    country_reader = geoip2.database.Reader('db/GeoLite2-Country.mmdb')
    city_reader = geoip2.database.Reader('db/GeoLite2-City.mmdb')
except (OSError, IOError) as e:
    print(e)
    print('GeoLite2 Free Downloadable Databases: http://dev.maxmind.com/geoip/geoip2/geolite2/')
    

def getIPfromURL(url):
    ip = None
    try:
        ip = socket.gethostbyname(url)
    except socket.error as e:
        pass
    
    return ip
        
def getCountryByIP(ip):
    country_name = None
    
    if ip is not None:
        try:
            response = country_reader.country(ip)
            country_name = response.country.name
        except geoip2.errors as e:
            print(e)
   
    return country_name

def getCityByIP(ip):
    city_name = None
    
    if ip is not None:
        try:
            response = city_reader.city(ip)
            city_name = response.city.name
        except geoip2.errors as e:
            print(e)
        
    return city_name

def open_with_pandas_read_csv(csv_file):
    
    df = pandas.read_csv('csv/top-1m.csv', sep=',')
    data = df.values
    urls = []
    broken_urls = []
    
    for row in data:
        
        ip = getIPfromURL(row[1])
        if ip is not None:
            urls.append(row[1])
        else:
            broken_urls.append(row[1])
            print(row[1] + ' is not working!')

    df = pandas.DataFrame(urls, columns = ['URL'])
    df.to_csv('csv/example.csv')
    dfb = pandas.DataFrame(broken_urls, columns = ['broken URL'])
    dfb.to_csv('csv/example_broken.csv')
    

class TerminalMenu:
    
    @staticmethod
    def foo(urls):
            for u in urls:
                ip = getIPfromURL(url=u)
                country = getCountryByIP(ip)
                city = getCityByIP(ip)
                
                print('#'  
                      + ' | url: ' + str(u) 
                      + ' | ip: ' + str(ip) 
                      + ' | country: ' + str(country)
                      + ' | city: ' + str(city))
                
    def __init__(self, sys_argv):
        """ The constructor of TerminalMenu:
        This constructor takes the arguments from the command line, use -h for more help.
        :param sys_argv:
        :return:
        """
        self.parser = argparse.ArgumentParser(description="Input URLs to get host-IP, host-Country and host-City.")

        # When parse_args() is called, argparse will make sure that only one of the arguments in the mutually
        # exclusive group was present on the command line
        self.group = self.parser.add_mutually_exclusive_group()
        # Container 1 (only one allowed)
        self.group.add_argument("-u", "--url", nargs="+", type=str, help="input URLs, separate by space.")
        
        args = self.parser.parse_args()

        if len(sys_argv) > 1:

            if args.url:
                TerminalMenu.foo(urls=args.url)                                                  
        else:
            self.parser.print_help()

def main():
    TerminalMenu(sys_argv=sys.argv)
    
if __name__ == '__main__':
    main()