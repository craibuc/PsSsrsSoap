# PsSsrsSoap
PowerShell (5.1) wrapper of SSRS' SOAP service.

## Usage

### Test a connection

```powershell
Import-Module PsSsrsSoap

'instance0.domain.tld','instance1.domain.tld' | Test-SsrsConnection
True
True
```

### Test a connection (without PsSsrsSoap)

```powershell
Import-Module ReportingServicesTools

'instance0.domain.tld','instance1.domain.tld' | % {

    $Uri = "https://$_/ReportServer/ReportService2010.asmx?wsdl"
    $Proxy = New-RsWebServiceProxy -ReportServerUri $Uri
    $Proxy.GetItemType('/')
    
}
Folder
Folder
```

## References

- [How to Download All Your SSRS Report Definitions (RDL files) Using PowerShell](https://sqlbelle.wordpress.com/2011/03/28/how-to-download-all-your-ssrs-report-definitions-rdl-files-using-powershell/)