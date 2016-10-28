# Docker CKAN image for use with dockerized CKAN

- checkout
- docker build -t picturae/ckan:2.5.2 .
- docker run -d --name picturae-ckan -p 80:80 --link picturae-ckan-solr --link picturae-ckan-postgres picturae/ckan:2.5.2
- etc...