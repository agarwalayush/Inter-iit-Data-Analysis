from bs4 import BeautifulSoup
import re
import urllib2
import json
basic_url = "http://www.tripadvisor.in"
cn=0

def get_review(page_url):									#Given a url : page_url, this function goes into the page and extracts the article from it
	bn=0
	page_url = basic_url + page_url
	url=urllib2.urlopen(page_url)
	cont=url.read()
	soup=BeautifulSoup(cont)
	main=soup.find("div",{"class" : " non_hotels_like desktop bg_f8"})	
	if (main is not None):
		
		stats=main.find("div",{"class":"col2of2 composite"})
		if (stats is not None):
			handle=stats.findAll("div",{"class":"wrap row"})	
			if (handle is not None):
				for h in handle:
					print h.find("span",{"class":"text"}).text,h.find("span",{"class":"compositeCount"}).text
		

		r=main.findAll("div",{"class":"innerBubble"})
		for review in r:
			review=review.findAll("div",{"class":"wrap"})
			if (review is not None):	
				for m in review:
					if(bn < 400):
						div=m.find("div",{"class":"quote isNew"})
						if(div is not None):
							div=div.find("a");
							name=div.find("span",{"class":"noQuotes"})
							if(name is not None):
								print bn, name.text
							links=m.find(alt=re.compile('of 5'))
							if (links is not None):
								print links['alt']
							links=m.find("div",{"class":"entry"})
							if (links is not None):
								print links.text,
								bn+=1
						# 	else:
						# 		print "link is none"
						# else:
						# 	print "div is none"

	return True




for i in range(30,420,30):
	page_url="http://www.tripadvisor.in/Hotels-g297604-oa"+str(i)+"-Goa-Hotels.html"

	url=urllib2.urlopen(page_url)
	cont=url.read()
	soup=BeautifulSoup(cont)
	main=soup.find("div",{"class" : "meta_hotels hotels_like desktop bg_trans"})
	if (main is not None):	
		main=main.findAll("div",{"class":"quality wrap"})
		if (main is not None):	
			for m in main :
				name=m.find("a")
				print cn, name.text
				links=m.find(alt=re.compile('of 5'))
				if (links is not None):
					print links['alt']
				links=m.find(href=re.compile('Hotel'))
				if (links is not None):
					print links['href']	
				get_review(links['href'])
				cn+=1
				print "\n\n"


	        
	# main=soup.find("div",{"class" : "deckA hacTabLIST"})
	# div=main.findAll("div",{"class":"quality wrap"})
	# for d in div:
	# 	print d
	# for i in links:
	# 	k=i['href']
	# 	print k
	# 	cn+=1
	# 	print cn
