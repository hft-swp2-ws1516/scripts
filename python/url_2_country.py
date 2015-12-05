#!/usr/bin/env python
"""
Created on Dec 5, 2015

This product includes GeoLite2 data created by MaxMind, available from
<a href="http://www.maxmind.com">http://www.maxmind.com</a>.

Example:
    
    $ python3 url_2_country.py -u www.hft-stuttgart.de
    URL: www.hft-stuttgart.de, IP: 193.196.136.111, COUNTRY: Germany, CITY: Stuttgart

@author: mdaaaa
"""

import geoip2.database
import socket
import pandas
import sys
import argparse

try:
    country_reader = geoip2.database.Reader('db/GeoLite2-Country.mmdb')
    city_reader = geoip2.database.Reader('db/GeoLite2-City.mmdb')
except (OSError, IOError) as e:
    print(e)
    print('GeoLite2 Free Downloadable Databases: \
            http://dev.maxmind.com/geoip/geoip2/geolite2/')

def getIPfromURL(url):
    """"
    
    Args:
        url (string): like 'hft-stuttgart.de' or 'www.hft-stuttgart.de'
    
    Returns:
        ip (string): Format '193.196.136.111'
        None: If no connection can be established
    
    Example:
        >>> getIPfromURL('hft-stuttgart.de')
        '193.196.136.111'
        
    """
    ip = None
    try:
        ip = socket.gethostbyname(url)
    except socket.error as e:
        print(str(url) + ': ' + str(e))
        return ip
    
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


def open_with_pandas_read_csv():
    """
    read and write example using csv, not used at all but maybe useful for 
    further development.
    """
    csv_file = 'csv/top-1m.csv'
    df = pandas.read_csv(csv_file, sep=',')
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
    """
    TerminalMenu is used as a handler for sys.argv inputs. 
    """
    
    @staticmethod
    def foo(urls):
        """
        checking all input URLs for their IP, COUNTRY, CITY - 
        If connection can be established this method will print the output to
        the shell.
        """
        for u in urls:
            ip = getIPfromURL(url=u)
            if ip is not None:
                country = getCountryByIP(ip)
                city = getCityByIP(ip)
                print('URL: ' + str(u)
                      + ', IP: ' + str(ip) 
                      + ', COUNTRY: ' + str(country)
                      + ', CITY: ' + str(city))
    
                        
    def __init__(self, sys_argv):
        """
        initialization for shell inputs / handling
        """

        self.parser = argparse.ArgumentParser(description="Input URLs to get \
            host-IP, host-Country and host-City.")
        self.group = self.parser.add_mutually_exclusive_group()
        self.group.add_argument("-u", "--url", nargs="+", type=str, help="input\
             URLs, separate by space.")
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