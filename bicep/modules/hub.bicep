param location string
param tags object
param vnetName string
param addressPrefix string
param subnetMgmtPrefix string
param subnetFwPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: { addressPrefixes: [addressPrefix] }
    subnets: [
      {
        name: 'snet-mgmt'
        properties: { addressPrefix: subnetMgmtPrefix }
      }
      {
        name: 'snet-fw'
        properties: { addressPrefix: subnetFwPrefix }
      }
    ]
  }
}

output vnetId string = vnet.id
