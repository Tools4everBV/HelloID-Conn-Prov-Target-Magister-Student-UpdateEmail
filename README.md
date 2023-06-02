# HelloID-Conn-Prov-Target-magister

| :information_source: Information |
|:---------------------------|
| This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.       |

<br />

<p align="center">
  <img src="https://www.tools4ever.nl/connector-logos/magister-logo.png">
</p>

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
  - Execute on-premises because of IP whitelisting on Magister site
  - The user must be authorized for the function 
  - Documentation can be found at https://<tenant>.swp.nl:8800/doc?, https://<tenant>.nl:8800/doc?#Service_ADFuncties, https://<tenant>.swp.nl:8800/doc?#Service_Data 
 

## Getting help

> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/hc/en-us/articles/360012557600-Configure-a-custom-PowerShell-source-system) pages_

> _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_

## HelloID Docs

The official HelloID documentation can be found at: https://docs.helloid.com/
