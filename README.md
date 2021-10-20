# HelloID-Conn-Prov-Target-magister



## Table of contents

- [Introduction](#Introduction)
- [Getting started](#Getting-started)
  + [Connection settings](#Connection-settings)
  + [Prerequisites](#Prerequisites)
  + [Remarks](#Remarks)
- [Setup the connector](Setup-The-Connector)
- [Getting help](Getting-help)

## Introduction
The HelloID-Conn-Prov-Target-magister can be used update user accounts in Magister. You can update for example the email addres and password.

## Getting started

### Prerequisites
- URL to the webservice. Example: https://tools4ever.swp.nl:8800
 - username
 - password
 - library
 - function

### Actions
|Library| function     | Description |
| ------------| ------------ | ----------- |
| ADFuncties     | UpdatePersEMail  | update mailadres of employee|
| ADFuncties     | UpdateLeerEMail  | update mailadres of student|
| Data     | Set.Password  | set password|




### Connection settings
The following settings are required to connect to the API.


| Setting     | Description |
| ------------ | ----------- |
| username     | The username   |
| Password   | The password  |
| BaseUrl    |    The URL to the Magister environment. Example: https://tools4ever.swp.nl:8800|
| Library    |  Name of the library off the function |
| Function   | Name of the function to execute |


### Remarks
  - Execute on-premises
  - The user must be authorized for the function 
  - Documentation can be found at https://<tenant>.swp.nl:8800/doc?, https://<tenant>.nl:8800/doc?#Service_ADFuncties, https://<tenant>.swp.nl:8800/doc?#Service_Data 
 

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012557600-Configure-a-custom-PowerShell-source-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID Docs

The official HelloID documentation can be found at: https://docs.helloid.com/
