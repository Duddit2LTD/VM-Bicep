param RGPrefix string
param VNetPrefix string
param AzureSub string
param windowsOSVersion string = '2022-Datacenter'
param Location string
param InfrastructureRG string
param VMSize string
param Customer string
param AdminUser string
@secure()
param Password string
@secure()
param domainjoinusername string
@secure()
param domainjoinpassword string
@description('Resource Group VNET is deployed in')
param virtualNetworkResourceGroup string = '${RGPrefix}-${InfrastructureRG}'
param ouPath string = ''
@description('Set of bit flags that define the join options. Default value of 3 is a combination of NETSETUP_JOIN_DOMAIN (0x00000001) & NETSETUP_ACCT_CREATE (0x00000002) i.e. will join the domain and create the account on the domain. For more information see https://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx')
param domainJoinOptions int = 3
param UserManagedID string = '/subscriptions/${AzureSub}/resourceGroups/Management/providers/Microsoft.ManagedIdentity/userAssignedIdentities/UKSouthManagedID'

var virtualNetworkName = '${VNetPrefix}${Location}'
var vnetID = resourceId(virtualNetworkResourceGroup, 'Microsoft.Network/virtualNetworks', virtualNetworkName)
var subnetRef = '${vnetID}/subnets/${virtualNetworkName}_webServerSubnet'
var VMName = 'EVD-VM-${Customer}'





//NICS
resource Nics 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: '${VMName}-nic01'
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetRef
          }
        }
      }
    ]
  }
}

//WebServers VM's
resource VirtualMachines 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: VMName
  location: Location
  dependsOn: [
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserManagedID}': {}
    }
  }
  
  tags: {
    Customer:Customer
    BicepDeployment:'Yes'
    Purpose: 'Web Server'
  } 
  properties: {
    
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: ''
      }
    
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    hardwareProfile: {
      vmSize: VMSize
    }
    licenseType: 'None'
    osProfile: {
      computerName: VMName
      adminUsername: AdminUser
      adminPassword: Password
      windowsConfiguration: {
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
        }
        
        provisionVMAgent: true
        }
      allowExtensionOperations: true
      }
      networkProfile: {
        networkInterfaces: [
          {
            id: Nics.id
          }
        ]
      }
    }
}

//Domain Join
resource virtualMachineExtension 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = {
  parent: VirtualMachines
  name: 'joindomain'
  location: Location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: 'domain'
      ouPath: ouPath
      user: 'domain\\${domainjoinusername}'
      restart: true
      options: domainJoinOptions
    }
    protectedSettings: {
      Password: domainjoinpassword
    }
  }
}
