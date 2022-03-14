param RGPrefix string
param VNetprefix string
param CurrentSubscription string
param AzureSub string
param InfrastructureRG string 
param DefaultAdminUsername string
@secure()
param DefaultAdminPassword string
param StorageAccPrefix string
param StorageURIPrefix string
@secure()
param domainjoinusername string
@secure()
param domainjoinpassword string
param AppGatewayPrefix string
param EviidUKSouthKeyVault string
param VMAutomationURL string
@secure()
param VMAutomationKEY string

//  Standard_DS2_v2  Small - Testing
//  Standard_F8s_v2  low end prod
//  Standard_F4s_v2  medium prod
//  Standard_F2s_v2  Large Prod


//Once you create a server in a region, you cant simply move it to another section of this file to change region
//You can change the size of the VM by simply altering the size field
//Changing the name will create a new server with that name - dont do this



//WEBSERVERS
var Webservers = [

  {
    Name: 'Dev-VM-010'
    size: 'Standard_DS2_v2'
    Customer: 'Dev Customer-01'
    Location: 'UKSouth'
    Externaldomain: 'appgwtest01.eviid.com'
  }

  


]
















module deploywebservers 'VMResource.bicep' = [for VM in Webservers: {
  name: '${VM.Name}-Deploy'
  params: {
    Name: VM.Name
    Location: VM.Location
    Size: VM.size
    
    Customer: VM.Customer
    AdminUser: DefaultAdminUsername
    Password: DefaultAdminPassword
    CurrentSubscription: CurrentSubscription
    RGPrefix: RGPrefix
    InfrastructureRG: InfrastructureRG
    VNetPrefix: VNetprefix
    StorageAccPrefix: StorageAccPrefix
    StorageURIPrefix: StorageURIPrefix
    domainjoinpassword: domainjoinpassword
    AppGatewayPrefix: AppGatewayPrefix
    ExternalDomainName: VM.Externaldomain
    domainjoinusername: domainjoinusername
    EviidUKSouthKeyVault: EviidUKSouthKeyVault
    AzureSub: AzureSub
    VMAutomationKEY: VMAutomationKEY
    VMAutomationURL: VMAutomationURL

    

  }
}]
