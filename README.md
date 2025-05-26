# HelloID-Conn-Prov-Target-Magister-Student-UpdateEmail

> [!IMPORTANT]
> This repository contains the connector and configuration code only. The implementer is responsible to acquire the connection details such as username, password, certificate, etc. You might even need to sign a contract or agreement with the supplier before implementing this connector. Please contact the client's application manager to coordinate the connector requirements.

<p align="center">
 <img src="assets/logo.png">
</p>

## Table of contents

- [HelloID-Conn-Prov-Target-Magister-Student-UpdateEmail](#helloid-conn-prov-target-connectorname)
  - [Table of contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Connection settings](#connection-settings)
    - [Correlation configuration](#correlation-configuration)
    - [Available lifecycle actions](#available-lifecycle-actions)
    - [Field mapping](#field-mapping)
  - [Remarks](#remarks)
  - [Development resources](#development-resources)
    - [API endpoints](#api-endpoints)
    - [API documentation](#api-documentation)
  - [Getting help](#getting-help)
  - [HelloID docs](#helloid-docs)

## Introduction

_HelloID-Conn-Prov-Target-Magister_ is a _target_ connector.
This connector is currently only used to create or update the de email addresses of existing students in Magister. It does not manage the Magister students lifecycle.

## Getting started

### Prerequisites
- Access to the magister api url.
- The user must be authorized for the function 'UpdateLeerEMail'

### Connection settings

The following settings are required to connect to the API.

| Setting  | Description                        | Mandatory |
| -------- | ---------------------------------- | --------- |
| UserName | The UserName to connect to the API | Yes       |
| Password | The Password to connect to the API | Yes       |
| BaseUrl  | The URL to the API Example: https://mycompany.swp.nl:8800   | Yes       |

### Correlation configuration

The correlation configuration is Not used by this connector as no correlation is done.
The StamNr field in the _fieldmapping_json_ file is used to identify the Magister account to update

| Setting                   | Value                             |
| ------------------------- | --------------------------------- |
| Enable correlation        | `false`                           |
        |


### Available lifecycle actions

The following lifecycle actions are available:

| Action                                  | Description                                                                        |
| --------------------------------------- | -----------------------------------------------------------------------------------|
| create.ps1                              | Sets a (new) email address / Username (NieuweLoginNaam) for the student                                         |
| update.ps1                              | Updates the email addres  / Username (NieuweLoginNaam) of a student.                                            |
| configuration.json                      | Contains the connection settings and general configuration for the connector.      |
| fieldMapping.json                       | Defines mappings between person fields and target system person account fields.    |

### Field mapping

The field mapping can be imported by using the _fieldMapping.json_ file.

## Remarks

- Execute on-premises because of IP whitelisting on Magister site
- The user must be authorized for the function 'UpdateLeerEMail'
- There are no Get-calls available. The Student accounts that is updated in the create script is the account with the specified StamNr. This StamNr is stored as account reference.
- It does use an https POST action to invoke a specific library and function in the magister evironment, but the body of the call is not used.
- currentStudentEmailAddress

      Represents the student's existing email in Magister
      Used to compare against StudentEmailAddress to determine if an email update is needed
      Only triggers UpdateLeerEMail API call when values differ

- currentstudentUsername

      Contains the student's current login name in Magister
      Serves two purposes:
            As the identifier (LoginNaam) for the account to update
            For comparison against StudentUserName to check for changes
      Only executes UpdateGebruiker when a new username is provided

## Development resources

### API endpoints

The following endpoints are used by the connector

| Endpoint | Description               |
| -------- | ------------------------- |
| /doc?Function=UpdateLeerEMail&Library=ADFuncties  | used for the update of the studend email   |


### API documentation

- Documentation can be found at https://<tenant>.swp.nl:8800/doc?, https://<tenant>.nl:8800/doc?#Service_ADFuncties, https://<tenant>.swp.nl:8800/doc?#Service_Data

## Getting help

> [!TIP]
> _For more information on how to configure a HelloID PowerShell connector, please refer to our [documentation](https://docs.helloid.com/en/provisioning/target-systems/powershell-v2-target-systems.html) pages_.

> [!TIP]
>  _If you need help, feel free to ask questions on our [forum](https://forum.helloid.com)_.

## HelloID docs

The official HelloID documentation can be found at: https://docs.helloid.com/
