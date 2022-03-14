param RGPrefix string
param VNetprefix string
param AzureSub string
param InfrastructureRG string 
param DefaultAdminUsername string
@secure()
param DefaultAdminPassword string
@secure()
param domainjoinusername string
@secure()
param domainjoinpassword string


var Webservers = [

  {
    Name: 'VM-010'
    size: 'Standard_DS2_v2'
    Customer: 'Customer-01'
    Location: 'UKSouth'
    Externaldomain: 'xxxxx.xxxx.xx'
  }
]

module deploywebservers 'VMResource.bicep' = [for VM in Webservers: {
  name: '${VM.Name}-Deploy'
  params: {
  
    Location: VM.Location
    VMSize: VM.size
    Customer: VM.Customer
    AdminUser: DefaultAdminUsername
    Password: DefaultAdminPassword
    RGPrefix: RGPrefix
    InfrastructureRG: InfrastructureRG
    VNetPrefix: VNetprefix
    domainjoinpassword: domainjoinpassword
    domainjoinusername: domainjoinusername
    
    AzureSub: AzureSub


    

  }
}]
