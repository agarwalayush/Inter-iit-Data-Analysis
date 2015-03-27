from bs4 import BeautifulSoup
import re
import urllib2
import json
import time
basic_url = "http://www.tripadvisor.in"
cn=0
def get_review(page_url,file):                                   #Given a url : page_url, this function goes into the page and extracts the article from it
    bn=0
    page_url = basic_url + page_url
    url=urllib2.urlopen(page_url)
    cont=url.read()
    soup=BeautifulSoup(cont)
    f=open(file+".txt","w")
    main=soup.find("div",{"class" : " non_hotels_like desktop bg_f8"})  
    if (main is not None):
        
        stats=main.find("div",{"class":"gridA hr_tabs"})
        if (stats is not None):
            handle=stats.findAll("div",{"class":"col balance"})    
            if (handle is not None):
                r=main.findAll("div",{"class":"reviewSelector"})
                for review in r:
                    review=review.find("div",{"class":"col2of2"})
                    if (review is not None):
                        review=review.find("div",{"class":"wrap"})
                        title=review.find("div",{"class":"quote isNew"})
                        if(title is None):
                            title=review.find("div",{"class":"quote"})
                        body=review.find("div",{"class":"entry"});
                        f.write(title.text.encode("utf-8"))
                        f.write(body.text.encode("utf-8"))

        nextpage=stats.find("div",{"class":"pgLinks"})
        if(nextpage is not None):
            next_page = nextpage.find("a",{"class":"guiArw sprite-pageNext  pid4181"})
            if(next_page is not None):
                a = next_page.get('href')
                print a
                more_reviews(a,f,1)
    f.close()
    return True

def more_reviews(page_url,f,count):                                   #Given a url : page_url, this function goes into the page and extracts the article from it
    print "next function reached"
    page_url = basic_url + page_url
    url=urllib2.urlopen(page_url)
    cont=url.read()
    soup=BeautifulSoup(cont)
    main=soup.find("div",{"class" : " non_hotels_like desktop bg_f8"})  
    if (main is not None):
        stats=main.find("div",{"class":"gridA hr_tabs"})
        if (stats is not None):
            handle=stats.findAll("div",{"class":"col balance"})    
            if (handle is not None):
                r=main.findAll("div",{"class":"reviewSelector"})
                for review in r:
                    review=review.find("div",{"class":"col2of2"})
                    if (review is not None):
                        review=review.find("div",{"class":"wrap"})
                        title=review.find("div",{"class":"quote isNew"})
                        if(title is None):
                            title=review.find("div",{"class":"quote"})
                        body=review.find("div",{"class":"entry"});
                        f.write(title.text.encode("utf-8"))
                        f.write(body.text.encode("utf-8"))
            nextpage=stats.find("div",{"class":"pgLinks"})
       # next_link=link.find(href=re.compile('Hotel'))
        nextpage=stats.find("div",{"class":"pgLinks"})
        next_page = nextpage.find("a",{"class":"guiArw sprite-pageNext  pid4181"})
        if(next_page is not None):
            a = next_page.get('href')
            print a
            if(count < 5):
                count+=1
                more_reviews(a,f,count)
    return True


for i in range(0,420,30):
    if(i==0):
        page_url="http://www.tripadvisor.in/Hotels-g297604-Goa-Hotels.html"    
    else:
        page_url="http://www.tripadvisor.in/Hotels-g297604-oa"+str(i)+"-Goa-Hotels.html"
    url=urllib2.urlopen(page_url)
    print page_url
    cont=url.read()
    soup=BeautifulSoup(cont)
    main=soup.find("div",{"class" : "meta_hotels hotels_like desktop bg_trans"})
    if (main is not None):  
        print "hi"
        main=main.findAll("div",{"class":"quality wrap"})
        if (main is not None):  
            for m in main :
                name=m.find("a")
                links=m.find(href=re.compile('Hotel'))
                if (links is not None):
                    print cn
                get_review(links['href'],m.text)
                cn+=1
                if(cn==30 or cn==29 or cn==59 or cn==90 or cn==120):
                    time.sleep(30)
                print "\n \n\n"
