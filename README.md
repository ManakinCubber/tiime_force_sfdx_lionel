# Tiime Force deployment for circleci

# Overview
CircleCI is a Continuous Integration service. This project is used to demonstrate the ability to make an integration continue development
with Salesforce DX and the Tiime process development.

# Environment variables
First you need to set somes variables on the Circle CI environment :
- DEPLOY_TIMEOUT :	time to wait after the deployment (set to 5)
- SFDC_CONSUMER_KEY : your Connected App consumer key
- SFDC_CONSUMER_SECRET :	your Connected App consumer secret
- SFDC_SERVER_IV	xxxxA668	
- SFDC_SERVER_KEY	xxxx7F08	
- SFDC_URL  :	https://login.salesforce.com or https://test.salesforce.com
- SFDC_USER : your username to the connected sandbox